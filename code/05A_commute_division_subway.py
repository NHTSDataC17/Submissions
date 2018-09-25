# Include only trips for work
# print("Before data clean:")
# print("")
# print("trippub shape:")
# print(trippub.shape)
# print("")
#
# trippub.loc[trippub['TRIPPURP'] == 'HBW']
#
# print("After data clean:")
# print("")
# print("trippub shape:")
# print(trippub.shape)
# print("")
#
# print("Columns after sort:")
# print("")
# print("TRIPPURP column:")
# print(trippub['TRIPPURP'])
# print("")

# Join NHTS trip with HH data to analyze total weighted trips per HH
trip_hh_21 = pd.merge(trippub, hh_21, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_22 = pd.merge(trippub, hh_22, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_31 = pd.merge(trippub, hh_31, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_32 = pd.merge(trippub, hh_32, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_51 = pd.merge(trippub, hh_51, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_52 = pd.merge(trippub, hh_52, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_62 = pd.merge(trippub, hh_62, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_63 = pd.merge(trippub, hh_63, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_91 = pd.merge(trippub, hh_91, left_on='HOUSEID', right_on='HOUSEID')
trip_hh_92 = pd.merge(trippub, hh_92, left_on='HOUSEID', right_on='HOUSEID')

# NHTS annual miles by state and weighted total
trip_hh_21['COMMUTE'] = trip_hh_21['ENDTIME'] - trip_hh_21['STRTTIME']
trip_hh_22['COMMUTE'] = trip_hh_22['ENDTIME'] - trip_hh_22['STRTTIME']
trip_hh_31['COMMUTE'] = trip_hh_31['ENDTIME'] - trip_hh_31['STRTTIME']
trip_hh_32['COMMUTE'] = trip_hh_32['ENDTIME'] - trip_hh_32['STRTTIME']
trip_hh_51['COMMUTE'] = trip_hh_51['ENDTIME'] - trip_hh_51['STRTTIME']
trip_hh_52['COMMUTE'] = trip_hh_52['ENDTIME'] - trip_hh_52['STRTTIME']
trip_hh_62['COMMUTE'] = trip_hh_62['ENDTIME'] - trip_hh_62['STRTTIME']
trip_hh_63['COMMUTE'] = trip_hh_63['ENDTIME'] - trip_hh_63['STRTTIME']
trip_hh_91['COMMUTE'] = trip_hh_91['ENDTIME'] - trip_hh_91['STRTTIME']
trip_hh_92['COMMUTE'] = trip_hh_92['ENDTIME'] - trip_hh_92['STRTTIME']

trip_hh_mean_21 = trip_hh_21['COMMUTE'].mean()
trip_hh_mean_22 = trip_hh_22['COMMUTE'].mean()
trip_hh_mean_31 = trip_hh_31['COMMUTE'].mean()
trip_hh_mean_32 = trip_hh_32['COMMUTE'].mean()
trip_hh_mean_51 = trip_hh_51['COMMUTE'].mean()
trip_hh_mean_52 = trip_hh_52['COMMUTE'].mean()
trip_hh_mean_62 = trip_hh_62['COMMUTE'].mean()
trip_hh_mean_63 = trip_hh_63['COMMUTE'].mean()
trip_hh_mean_91 = trip_hh_91['COMMUTE'].mean()
trip_hh_mean_92 = trip_hh_92['COMMUTE'].mean()

# Create dataframe for trips by division
trip_hh_divisions = {
    'division': [
        21,
        22,
        31,
        32,
        51,
        52,
        62,
        63,
        91,
        92
    ],
    'trip_hh_mean': [
        trip_hh_mean_21,
        trip_hh_mean_22,
        trip_hh_mean_31,
        trip_hh_mean_32,
        trip_hh_mean_51,
        trip_hh_mean_52,
        trip_hh_mean_62,
        trip_hh_mean_63,
        trip_hh_mean_91,
        trip_hh_mean_92
    ]
}
trip_hh_divisions_plot = pd.DataFrame(
    trip_hh_divisions,
    columns = ['division', 'trip_hh_mean']
)

ax = trip_hh_divisions_plot[['trip_hh_mean']].plot(
    kind='bar',
    title ="Weighted Value",
    figsize=(12, 6),
    legend=True,
    fontsize=12
)
x_labels = [
    'Mid-Atlantic > 1M with Subway',
    'Mid-Atlantic > 1M w/o Subway',
    'East North Central > 1M with Subway',
    'East North Central > 1M w/o Subway',
    'South Atlantic > 1M with Subway',
    'South Atlantic > 1M w/o Subway',
    'East South Central > 1M with Subway',
    'East South Central > 1M w/o Subway',
    'Pacific > 1M with Subway',
    'Pacific > 1M w/o Subway'
]
plt.title('Average Commute Time per Houshold by Division', fontsize=16)
ax.set_xlabel("Division, Household Count and Subway System", fontsize=12)
ax.set_ylabel("Average Commute Time per Division (Minutes)", fontsize=12)
ax.set_xticklabels(x_labels)
plt.show()
