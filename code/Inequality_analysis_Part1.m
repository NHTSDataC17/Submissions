% /*******************************************************
%  This file is of Mobility Inequality Analysis for New York State and 
%  was prepared for 2018 NHTS Data Challenge.
% 
%  Written by Bumjoon Bae <baeb@ornl.gov>, September 2018
% 
%  *******************************************************/

clear all;
close all;
fclose('all');
clc;

%% Preprocessing the NHTS data
%%% The initial run of this preprocessing data module may take several 
%%% hours to generate the input datasets for the inequality analysis.

state = inputdlg('Input state initial to analyze (e.g., NY)','Input',[1 70])
state = upper(state{:});
if length(state) ~= 2
    error('Please enter the state initial with two-digit alphabet')
end

folder = '\\ORNLData.ornl.gov\Home\03. Dropbox_extra\02.coming_NHTS_Data_Challenge_(due 20181001)\NHTS Analysis\NHTS NYS datasets';
all_files = dir(folder);
all_dir = all_files([all_files(:).isdir]);
all_dir = all_dir(3:end);

for yr = 1:length(all_dir)
    disp(['Processing the ' all_dir(yr).name ' data ...'])
    disp(datetime('now'));
    
    % check if the processed file exists already
    cd(folder);
    file_out_name = [all_dir(yr).name '_NYS.csv'];
    file_out_name = strrep(file_out_name,' ','_');
    if exist(file_out_name, 'file') == 2
        continue;
    end
    
    % locate to the given year's NHTS csv data folder
    cd([folder '\' all_dir(yr).name]);
    
    % trip file will be a base for combining files
    if yr < 3
        trip_file = dir('DAY*.csv');
    else
        trip_file = dir('trip*.csv');
    end
    trip_file = trip_file.name;
    
    trip_data_table = readtable(trip_file,'Delimiter',',',...
        'ReadVariableNames',true,'HeaderLines',0);
    
    ind_state = cellfun(@(x)isequal(x,state),trip_data_table.HHSTATE);
    state_trip_data_table = trip_data_table(ind_state,:);
    clear trip_data_table
    
    % household (HH) file
    hh_file = dir('HH*.csv');
    hh_file = hh_file.name;
    
    hh_data_table = readtable(hh_file,'Delimiter',',',...
        'ReadVariableNames',true,'HeaderLines',0);
    
    ind_state = cellfun(@(x)isequal(x,state),hh_data_table.HHSTATE);
    state_hh_data_table = hh_data_table(ind_state,:);
    clear hh_data_table
    
    % person (PER) file
    per_file = dir('PER*.csv');
    per_file = per_file.name;
    
    per_data_table = readtable(per_file,'Delimiter',',',...
        'ReadVariableNames',true,'HeaderLines',0);
    
    ind_state = cellfun(@(x)isequal(x,state),per_data_table.HHSTATE);
    state_per_data_table = per_data_table(ind_state,:);
    clear per_data_table
    
    % combine three tables together
    %%% 1. extract column names from each table
    col_name_trip = state_trip_data_table.Properties.VariableNames;
    col_name_hh = state_hh_data_table.Properties.VariableNames;
    col_name_per = state_per_data_table.Properties.VariableNames;
    
    %%% 2. find the HH table's columns which not included in trip table.
    ind_col_name_hh = zeros(length(col_name_hh),1);
    for i = 1:length(col_name_hh)
        col_name_temp_str = col_name_hh(i);
        col_name_temp_str = col_name_temp_str{:};
        if strcmp(col_name_temp_str,'HOUSEID') == 1
            ind_col_name_hh(i) = 1;
        elseif isempty(find(strcmp(col_name_trip,col_name_hh(i))==1))==1
            ind_col_name_hh(i) = 1;
        end
    end
    state_hh_data_table=state_hh_data_table(:,find(ind_col_name_hh==1));
    
    %%% 3. find the PER table's columns which not included in trip table.
    ind_col_name_per = zeros(length(col_name_per),1);
    for i = 1:length(col_name_per)
        col_name_temp_str = col_name_per(i);
        col_name_temp_str = col_name_temp_str{:};
        if strcmp(col_name_temp_str,'HOUSEID') == 1 | strcmp(col_name_temp_str,'PERSONID') == 1
            ind_col_name_per(i) = 1;
        elseif isempty(find(strcmp(col_name_trip,col_name_per(i))==1))==1
            ind_col_name_per(i) = 1;
        end
    end
    state_per_data_table=state_per_data_table(:,find(ind_col_name_per==1));
    %%%% 3-1. create a HOUSEID+PERSONID column
    person_id_new = [];
    for i = 1:length(state_per_data_table.PERSONID)
        if iscell(state_per_data_table.PERSONID) & yr ==3
            person_id_new = [person_id_new; {[state_per_data_table.HOUSEID{i} state_per_data_table.PERSONID{i}]}];
        else
            if state_per_data_table.PERSONID(i) < 10
                if iscell(state_per_data_table.HOUSEID)
                    person_id_new = [person_id_new; {[state_per_data_table.HOUSEID{i} '0' num2str(state_per_data_table.PERSONID(i))]}];
                else
                    person_id_new = [person_id_new; {[num2str(state_per_data_table.HOUSEID(i)) '0' num2str(state_per_data_table.PERSONID(i))]}];
                end
            else
                if iscell(state_per_data_table.HOUSEID)
                    person_id_new = [person_id_new; {[state_per_data_table.HOUSEID{i} num2str(state_per_data_table.PERSONID(i))]}];
                else
                    person_id_new = [person_id_new; {[num2str(state_per_data_table.HOUSEID(i)) num2str(state_per_data_table.PERSONID(i))]}];
                end
            end
        end
    end
    person_id_new_table = cell2table(person_id_new,'VariableNames',{'HHPERID'});
    state_per_data_table = [person_id_new_table state_per_data_table]; % add the new id as the first column.
    state_per_data_table = removevars(state_per_data_table,{'HOUSEID','PERSONID'}); % remove the old id columns.
%     col_name_per = state_per_data_table.Properties.VariableNames; % update the column name 

    
    %%% 4. concatenate the HH table columns to the trip table
    col_hh_to_add = col_name_hh(find(ind_col_name_hh==1));
    empty_table_to_add = cell2table(cell(size(state_trip_data_table,1),length(col_hh_to_add)-1),...
        'VariableNames',col_hh_to_add(2:end)); % exclude HOUSEID column
    state_combined_data = [state_trip_data_table empty_table_to_add];

    for i = 1:size(state_combined_data,1)
        hh_id_temp = table2array(state_combined_data(i,1));
        if iscell(state_hh_data_table.HOUSEID)==1
            ind_hh_temp = cellfun(@(x)isequal(x,hh_id_temp{:}),state_hh_data_table.HOUSEID);
            if sum(ind_hh_temp) > 1 % There must no duplicate household records in the household data.
                error('There are at least two matches in the HH data. Please Check the data.')
            end
        else
            ind_hh_temp = find(state_hh_data_table.HOUSEID==hh_id_temp);
            if length(ind_hh_temp) > 1 % There must no duplicate household records in the household data.
                error('There are at least two matches in the HH data. Please Check the data.')
            end
        end
        
        state_combined_data{i,length(col_name_trip)+1:end}=table2cell(state_hh_data_table(ind_hh_temp,2:end)); 
        
        percent_progress = round(i/size(state_combined_data,1)*100,0);
        if rem(percent_progress,5) == 0 & percent_progress ~= 0
            display(['Completed ', num2str(percent_progress) '%']);
            disp(datetime('now'));
        elseif i == size(state_combined_data,1)
            display('Completed 100%');
            disp(datetime('now'));
        end
    end
    
    col_name_combined_data = state_combined_data.Properties.VariableNames;
    
    %%% 5. concatenate the per table columns to the trip table
    col_per_to_add = col_name_per(find(ind_col_name_per==1));
    col_per_to_add =[{'HHPERID'} col_per_to_add];
%     ind_exclusion_temp = strcmp(col_per_to_add,'HOUSEID') + strcmp(col_per_to_add,'PERSONID');
    ind_exclusion_temp = strcmp(col_per_to_add,'HOUSEID') + strcmp(col_per_to_add,'PERSONID') + strcmp(col_per_to_add,'VARSTRAT');
    col_per_to_add = col_per_to_add(ind_exclusion_temp ~= 1);
    
    empty_table_to_add = cell2table(cell(size(state_trip_data_table,1),length(col_per_to_add)-1),...
        'VariableNames',col_per_to_add(2:end)); % exclude HHPERID column
    state_combined_data = [state_combined_data empty_table_to_add];

    %%%% 5-1. Create HHPERID column again
    person_id_new2 = [];
    for i = 1:length(state_combined_data.PERSONID)
        if iscell(state_combined_data.PERSONID) & yr ==3
            person_id_new2 = [person_id_new2; {[state_combined_data.HOUSEID{i} state_combined_data.PERSONID{i}]}];
        else
            if state_combined_data.PERSONID(i) < 10
                if iscell(state_combined_data.PERSONID)
                    person_id_new2 = [person_id_new2; {[state_combined_data.HOUSEID{i} '0' num2str(state_combined_data.PERSONID(i))]}];
                else
                    person_id_new2 = [person_id_new2; {[num2str(state_combined_data.HOUSEID(i)) '0' num2str(state_combined_data.PERSONID(i))]}];
                end
            else
                if iscell(state_combined_data.PERSONID)
                    person_id_new2 = [person_id_new2; {[state_combined_data.HOUSEID{i} num2str(state_combined_data.PERSONID(i))]}];
                else
                    person_id_new2 = [person_id_new2; {[num2str(state_combined_data.HOUSEID(i)) num2str(state_combined_data.PERSONID(i))]}];
                end
            end
        end
    end
    person_id_new_table2 = cell2table(person_id_new2,'VariableNames',{'HHPERID'});
    state_combined_data = [person_id_new_table2 state_combined_data];
    
    for i = 1:size(state_combined_data,1)

        
        per_id_temp = table2array(state_combined_data(i,1));
        ind_per_temp = cellfun(@(x)isequal(x,per_id_temp{:}),state_per_data_table.HHPERID);
        if sum(ind_per_temp) > 1 % There must no duplicate household records in the household data.
            error('There are at least two matches in the HH data. Please Check the data.')
        end
        
        if sum(ind_exclusion_temp) == 2
            if yr == 1
                state_combined_data{i,length(col_name_combined_data)+2:end}=table2cell(state_per_data_table(ind_per_temp,2:end)); 
            elseif yr ==3
                state_combined_data{i,length(col_name_combined_data)+2:end}=table2cell(state_per_data_table(ind_per_temp,3:end)); % 'VARSTRAT' should be the second column in state_per_data_table.
            end
        elseif ind_exclusion_temp == 3 & yr == 2 % for the case where 'VARSTRAT' is excluded (e.g., for 2009 dataset)
            state_combined_data{i,length(col_name_combined_data)+2:end}=table2cell(state_per_data_table(ind_per_temp,3:end)); % 'VARSTRAT' should be the second column in state_per_data_table.
        end
        
        percent_progress = round(i/size(state_combined_data,1)*100,0);
        if rem(percent_progress,10) == 0 & percent_progress ~= 0
            display(['Completed ', num2str(percent_progress) '%']);
            disp(datetime('now'));
        elseif i == size(state_combined_data,1)
            display('Completed 100%');
            disp(datetime('now'));
        end
    end
    
    %%% save the combined matrix as an csv file. (This may take an hour.)
    cd ..
    writetable(state_combined_data,file_out_name,'Delimiter',',');
end

% clear all variables except a few.
clearvars -except folder

disp('The proprocessing the raw NHTS data completed.')
disp(datetime('now'));

%% Mobility inequality analysis
prompt = {'Enter the NYS population index to analyze (0-All; 1-Elderly; 2-NonElderly; 3-White; 4-NonWhite):',...
    'Enter the year of NHTS data to analyze among [2017, 2009, 2001]:'};
title = 'Input';
dims = [1 70];
input = inputdlg(prompt,title,dims)
selection_id = str2num(input{1});  %0-All; 1-Elderly; 2-NonElderly; 3-White; 4-NonWhite
year = str2num(input{2});
clear title; 

%%% Data Collection and Preprocess
% This code requires three years (2017, 2009, and 2001) of NHTS data in csv
% format.
% The raw data can be downloaded at: https://nhts.ornl.gov/downloads

% The input dataset of this code for each year had been made in EXCEL, consisting of trippub.csv +
% hhpub.csv + perpub.csv files (for 2017) or DAYV2PUB +
% HHV2PUB + PERV2PUB.cvs files (for 2009 & 2001) for all NYS records.
% To combine those csv files together, HOUSEID or HOUSEID&PERSONID was used as an index.
% To whom wants to skip the above preprocessing, one can import the raw csv
% files individually, extract the variables requred to run this code, and
% create the "data" matrix. Note that each record in the "data" matrix
% represents an individual trip.


if year == 2017
    
    cd(folder);
    file_list = dir(['*' num2str(year) '*.csv']);
    if length(file_list) == 0
        error(['There is no csv file named ''*' num2str(year) '*.csv''.'])
    elseif length(file_list) > 1
        error(['There are more than one csv files named ''*' num2str(year) '*.csv''.'])
    end
    file = file_list.name;

    data_table = readtable(file,'Delimiter',',',...
        'ReadVariableNames',true,'HeaderLines',0);

    % 120,207 trip records
    data = [data_table.HOUSEID ...          % HH ID
        data_table.HHSIZE ...               % HH size
        data_table.HHFAMINC ...         % HH Income
        data_table.TRPMILES ...         % Trip length
        data_table.WTTRDFIN ...   % this column is the weight of this trip data to represent the population.
        data_table.HH_RACE ...          % Respondent's race
        data_table.R_AGE ...            % Respondent's age
        data_table.WTHHFIN ...            % HH weight
        data_table.WTPERFIN];           % Person weight
    
elseif year == 2009

    cd(folder);
    file_list = dir(['*' num2str(year) '*.csv']);
    if length(file_list) == 0
        error(['There is no csv file named ''*' num2str(year) '*.csv''.'])
    elseif length(file_list) > 1
        error(['There are more than one csv files named ''*' num2str(year) '*.csv''.'])
    end
    file = file_list.name;

    data_table = readtable(file,'Delimiter',',',...
        'ReadVariableNames',true,'HeaderLines',0);

    data = [data_table.HOUSEID ...          % HH ID
        data_table.HHSIZE ...               % HH size
        data_table.HHFAMINC ...         % HH Income
        data_table.TRPMILES ...         % Trip length
        data_table.WTTRDFIN ...   % this column is the weight of this trip data to represent the population.
        data_table.HH_RACE ...          % Respondent's race
        data_table.R_AGE ...            % Respondent's age
        data_table.WTHHFIN ...            % HH weight
        data_table.WTPERFIN];           % Person weight
    
elseif year == 2001

    cd(folder);
    file_list = dir(['*' num2str(year) '*.csv']);
    if length(file_list) == 0
        error(['There is no csv file named ''*' num2str(year) '*.csv''.'])
    elseif length(file_list) > 1
        error(['There are more than one csv files named ''*' num2str(year) '*.csv''.'])
    end
    file = file_list.name;

    data_table = readtable(file,'Delimiter',',',...
        'ReadVariableNames',true,'HeaderLines',0);

    data = [data_table.HOUSEID ...          % HH ID
        data_table.HHSIZE ...               % HH size
        data_table.HHFAMINC ...         % HH Income
        data_table.TRPMILES ...         % Trip length
        data_table.WTTRDFIN ...   % this column is the weight of this trip data to represent the population.
        data_table.HHR_RACE ...          % Respondent's race
        data_table.R_AGE ...            % Respondent's age
        data_table.WTHHFIN ...            % HH weight
        data_table.WTPERFIN];           % Person weight
else
    error('Please check the input data.');
end

% add elderly household flag
age = data_table.R_AGE;
HHID = data_table.HOUSEID;
unique_HHID = unique(HHID);
elderlyHH_flag = zeros(length(unique_HHID),1);
pre_HHID = 0;
elderlyHH_temp = zeros(length(data),1); % this column will be added to the data
for i = 1:length(data)
    if age(i) >= 65 & pre_HHID ~= HHID(i)
        elderlyHH_flag(unique_HHID==HHID(i))=1;
        pre_HHID = HHID(i);
        
        elderlyHH_temp(HHID == pre_HHID) = 1;
        
    end
end


% 10 columns [HH_ID, HH size, HH Income, Trip length, Trip weight, Race, Age, HH weight, Person weight, Elderly HH flag]
data = [data elderlyHH_temp]; % add the elderly household flag (if 65+, flag = 1)

% Exclude negative trip-mile indices (including 'not ascertained', 'don't
% know', and 'refused' cases)
ind_nonneg_miles = find(data(:,4)>=0);
data = data(ind_nonneg_miles,:);
% 120,207 -> 120,083 trip records

% Exclude 0-4 yr persons' trip records in 2001 NYS (*There's no record for
% 0-4 yr people in 2009 data)
if year == 2001
    ind_nonyonger_age = find(data(:,7)>=5);
    data = data(ind_nonyonger_age,:);
end

% Calculate the weighted trip length
data = [data data(:,4).*data(:,5)];  % trip length * trip weight
% 11 columns from now
% [HH_ID, HH size, HH Income, Trip length, Trip weight, Race, Age, HH weight, Person weight, Elderly HH flag, Weighted Trip length]

%%%%%%%%%%%%%%%%%%%% data segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind_elderlyHH = find(data(:,10)==1);
ind_nonelderlyHH = find(data(:,10)==0);
ind_white = find(data(:,6)==1);
ind_nonwhite = find(data(:,6)>1);  % remove all the negative index rows

if selection_id == 0
    selection_keyword = 'All'
elseif selection_id == 1
    data = data(ind_elderlyHH,:);
    selection_keyword = 'Elderly'
elseif selection_id == 2
    data = data(ind_nonelderlyHH,:);
    selection_keyword = 'NonElderly'
elseif selection_id == 3
    data = data(ind_white,:);
    selection_keyword = 'White'
elseif selection_id == 4
    data = data(ind_nonwhite,:);
    selection_keyword = 'NonWhite'
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% population size (total number of trips, people, households)
n_trips = sum(data(:,5)); % sum of trip weight

[~,ia,~]=unique(data(:,1)); % 15,429 households for 2017 All
n_household = sum(data(ia,8)); % sum of HH weight

[unique_id,ia,ic]=unique(data(:,1));    % get unique HH ID.

data_PER = [unique_id data(ia,2:3) accumarray(ic,data(:,4)) data(ia,6:10)]; % accumarray(ic,data(:,11))]; 
% Exclude the trip weight (fifth) and weighted trip length by trip weight (11th) columns
% because this is a household-based data now.
% 9 columns from now

%%%% Weighted trip length by HH
HHsize_adjustment = 1  % if want to adjust hh trip length by hh size
if HHsize_adjustment == 1
    data_PER(:,4) = data_PER(:,4)./data_PER(:,2); % hh trip length / hhsize
end
data_PER = [data_PER data_PER(:,4).*data_PER(:,7)]; % hh trip length / hhsize * hh weight
% 10 columns from now
% [HH_ID, HH size, HH Income, Trip length, Race, Age, HH weight, Person weight, Elderly HH flag, weighted trip length by HH weight]


%% Concentration analysis

data_PMT = data_PER;
data_PMT = sortrows(data_PMT,4);  % sorted by PMT
data_PMT = [data_PMT data_PMT(:,4)/sum(data_PMT(:,10))]; % proportion of each hh's daily trip length wrt total PMT
data_PMT_acc_n_people = cumsum(data_PMT(:,7));  % cumulative number of hh


% manual calculation of Gini coefficient
data_PMT_add=[data_PMT data_PMT_acc_n_people/max(data_PMT_acc_n_people) ...
    data_PMT(:,4).*data_PMT(:,7)/sum(data_PMT(:,10))]; % add relative proportion and relative PMT in 12th & 13th column
data_PMT_add=[data_PMT_add cumsum(data_PMT_add(:,13))]; % cumulative PMT in 14th column
data_PMT_add=[data_PMT_add data_PMT_add(:,12)-data_PMT_add(:,14)];
gini_pmt=sum(data_PMT_add(:,15))/sum(data_PMT_add(:,12))

% calculate the percentiles
prctl = []; prctl_actual = [];
for i = 1:10
    person_num = n_household /10 * i;
    
    % find the closest value in data_PER_acc_n_people
    [~,index] = min(abs(data_PMT_acc_n_people-person_num));
    if data_PMT_acc_n_people(index)-person_num < 0 & index < length(data_PMT_add)
        index = index + 1;
    end
    
    prctl(i) = data_PMT_add(index,14);
    prctl_actual(i) = round(data_PMT_add(index,4),1);
end
prctl=[0 prctl];
prctl_actual=[0 prctl_actual];

% Plot an Approximate Lorenz Curve Using Deciles Information
Proportion = 0:0.1:1;

title_str1 = ['Lorenz Curve for ' selection_keyword ' NYS Population (Gini Index = ' sprintf('%.2f',gini_pmt) ')'];
title_str2 = ['PMT Proportion for ' selection_keyword ' All NYS Population by Decile'];
title_str3 = ['PMT Proportion for ' selection_keyword ' All NYS Population by Household Income'];

figure('defaultAxesFontSize',12);
subplot(2,1,1)
area(Proportion',[prctl' Proportion'-prctl'])
axis([0 1 0 1])
title(title_str1);
xlabel('Cumulative proportion of people from lowest to highest PMT')
ylabel('Cumulative proportion of PMT')

subplot(2,1,2)
bar(diff(prctl))
axis([0 11 0 1])
title(title_str2);
xlabel('PMT Range by Decile (person-mile)')
ylabel('Proportion of PMT')
xtick={};
for i = 1:10
    if i < 10
        tick_temp = [sprintf('%.1f',prctl_actual(i)) '-' sprintf('%.1f',prctl_actual(i+1))];
    else
        tick_temp = [sprintf('%.1f',prctl_actual(i)) '+'];
    end
    xtick{i} = tick_temp;
end
xticklabels(xtick);
xtickangle(30)

labels=arrayfun(@(value) num2str(value,'%2.2f'),diff(prctl),...
    'UniformOutput',false);
text(1:1:10,diff(prctl),labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom');



%% Convert the income index to average income in $
% Exclude negative income indices (including 'not ascertained', 'don't
% know', and 'refused' cases)
ind_nonneg_inc = find(data_PER(:,3)>=0);
data_PER2 = data_PER(ind_nonneg_inc,:);

% update the total number of HHs
n_household = sum(data_PER2(:,7)); % sum of HH weight

%%% Since the household income level definition changed from the 2017 NHTS
%%% data, the median income values for 2017 and the previous years need to
%%% be matched.
if year == 2017
%     income_code = [5000 12500 20000 30000 42500 62500 87500 ...
%         112500 137500 175000 250000]; % the median of the highest income group was determined based on the 2009 ACS data. (Need to update later!!!)
    income_code = [5000 12500 20000 30000 42500 62500 87500 ...
        140000 140000 140000 140000]; % the median of the highest income group was determined based on the 2009 ACS data. (Need to update later!!!)
else
%     income_code = [2500 7500 12500 17500 22500 27500 ...
%         32500 37500 42500 47500 52500 57500 ...
%         62500 67500 72500 77500 90000 140000]; % the median of the highest income group was determined based on the 2009 ACS data.
    income_code = [5000 5000 12500 20000 20000 30000 ...
        30000 42500 42500 42500 62500 62500 62500 ...
        62500 62500 87500 87500 140000]; % the median of the highest income group was determined based on the 2009 ACS data.
end

data_PER2_inc = [];
for i = 1:length(data_PER2)
    inc_temp = income_code(data_PER2(i,3));
    data_PER2_inc = [data_PER2_inc; inc_temp];
end


%% Lorenz curve wrt PMT with HH income
% [HHPER_ID, HH_ID, HH Income($), Trip length, Race, Age, HH weight, Person weight, Elderly HH flag, weighted trip length by person weight]
data_PER2(:,3) = data_PER2_inc;
% data_PER2 = sortrows(data_PER2,3);  % sorted by income
data_PER2 = sortrows(data_PER2,[3 4]);  % sorted by income and trip length
data_PER2 = [data_PER2 data_PER2(:,4)/sum(data_PER2(:,10))]; % proportion of each person's daily trip length wrt total PMT
data_PER2_acc_n_people = cumsum(data_PER2(:,7));  % cumulative number of people


% manual calculation of Gini coefficient
data_PER2_add=[data_PER2 data_PER2_acc_n_people/max(data_PER2_acc_n_people) ...
    data_PER2(:,4).*data_PER2(:,7)/sum(data_PER2(:,10))]; % add relative proportion and relative HH weighted PMT in 12th & 13th column
data_PER2_add=[data_PER2_add cumsum(data_PER2_add(:,13))]; % cumulative HH weighted PMT in 14th column
data_PER2_add=[data_PER2_add data_PER2_add(:,12)-data_PER2_add(:,14)];
gini_pmt=sum(data_PER2_add(:,15))/sum(data_PER2_add(:,12))


% ** % calculate the percentiles
num_segment = 10;
prctl = []; prctl_actual = [];
for i = 1:num_segment
    person_num = n_household /num_segment * i;
    
    % find the closest value in data_PER_acc_n_people
    [~,index] = min(abs(data_PER2_acc_n_people-person_num));
    if data_PER2_acc_n_people(index)-person_num < 0 & index < length(data_PER2_acc_n_people)
        index = index + 1;
    end
    
    prctl(i) = data_PER2_add(index,14);
    if data_PER2_add(index,3) <= 80000 
        prctl_actual(i) = data_PER2_add(index,3)+2500;
    elseif data_PER2_add(index,3) < 100000
        prctl_actual(i) = data_PER2_add(index,3)+10000;
    else
        prctl_actual(i) = data_PER2_add(index,3);
    end
end
prctl=[0 prctl];
prctl_actual=[0 prctl_actual];

%% save the Lorenz curve value matrix
lorenz_curve = ['C:\Users\2bb\Dropbox\00. NTRC\02. Research\20171208_Mobility inequality_2018 TRB\'...
    'Gini_index_result\20180924\prctl_' num2str(year) '_' selection_keyword '.mat'];
cd ..
lorenz_curve = ['prctl_' num2str(year) '_' selection_keyword '.mat'];

prctl_gini = [prctl gini_pmt];
save(lorenz_curve,'prctl_gini');

