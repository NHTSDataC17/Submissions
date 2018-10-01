% /*******************************************************
%  This file is of Mobility Inequality Analysis for New York State and 
%  was prepared for 2018 NHTS Data Challenge.
% 
%  Written by Bumjoon Bae <baeb@ornl.gov>, September 2018
% 
%  *******************************************************/


clear all

file = dir('prctl*.mat');

proportion = 0:0.1:1;
prctl_all = [];
legend_name = {};
fig = figure('defaultAxesFontSize',12);

prompt = {'Enter the NYS population index to analyze (0-All; 1-Elderly; 2-NonElderly; 3-White; 4-NonWhite):'};
title = 'Input';
dims = [1 70];
input = inputdlg(prompt,title,dims)
selection_id = str2num(input{1});  %0-All; 1-Elderly; 2-NonElderly; 3-White; 4-NonWhite
clear title; 

if selection_id == 0
    list = [11 6 1]; % 2017 all, 2009 all, 2001 all
    selection_keyword = 'All'
elseif selection_id == 1
    list = [12 7 2]; % 2017 & 2009 & 2001 elderly
    selection_keyword = 'Elderly'
elseif selection_id == 2
    list = [13 8 3]; % 2017 & 2009 & 2001 Non elderly
    selection_keyword = 'NonElderly'
elseif selection_id == 3
    list = [15 10 5]; % 2017 & 2009 & 2001 white
    selection_keyword = 'White'
elseif selection_id == 4
    list = [14 9 4]; % 2017 & 2009 & 2001 Non white
    selection_keyword = 'NonWhite'
end


for i = 1:length(list)
    
    fname_temp = file(list(i)).name;
    load(fname_temp);
    prctl_all = [prctl_all prctl_gini(1:end-1)'];
    fname_temp2 = [fname_temp(7:10) ' ' fname_temp(12:end-4) ...
        ' (\itGini\rm=' num2str(round(prctl_gini(end),2)) ')'];
    
    if i == 1
        plot(proportion',proportion','k-','LineWidth',2);
        hold on;
        plot(proportion',prctl_gini(1:end-1)','LineWidth',2);
        legend_name = [legend_name 'Perfect equality' fname_temp2];
        xlabel('Cumulative proportion of households from lowest to highest income');
        ylabel('Cumulative proportion of PMT');
    else
        plot(proportion',prctl_gini(1:end-1)','LineWidth',2);
        legend_name = [legend_name fname_temp2];
    end
    hold on;
    
end

title('Lorenz Curve Comparison')
legend(legend_name,'Location','northwest');
hold off;
grid on;

plot_name = ['Gini_NYS_' selection_keyword '.png'];
saveas(fig,plot_name)

