# Sum all weighted households by division
hh_21_weight_sum = hh_21['WTHHFIN'].sum()
hh_22_weight_sum = hh_22['WTHHFIN'].sum()
hh_31_weight_sum = hh_31['WTHHFIN'].sum()
hh_32_weight_sum = hh_32['WTHHFIN'].sum()
hh_51_weight_sum = hh_51['WTHHFIN'].sum()
hh_52_weight_sum = hh_52['WTHHFIN'].sum()
hh_62_weight_sum = hh_62['WTHHFIN'].sum()
hh_63_weight_sum = hh_63['WTHHFIN'].sum()
hh_91_weight_sum = hh_91['WTHHFIN'].sum()
hh_92_weight_sum = hh_92['WTHHFIN'].sum()

# Join NHTS trip with HH data to analyze total weighted trips per HH
tr_hh_21 = pd.merge(trippub, hh_21, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_22 = pd.merge(trippub, hh_22, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_31 = pd.merge(trippub, hh_31, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_32 = pd.merge(trippub, hh_32, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_51 = pd.merge(trippub, hh_51, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_52 = pd.merge(trippub, hh_52, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_62 = pd.merge(trippub, hh_62, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_63 = pd.merge(trippub, hh_63, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_91 = pd.merge(trippub, hh_91, left_on='HOUSEID', right_on='HOUSEID')
tr_hh_92 = pd.merge(trippub, hh_92, left_on='HOUSEID', right_on='HOUSEID')

# NHTS trip data by division and weighted total
tr_21_weight_sum = tr_hh_21['WTTRDFIN'].sum()
tr_22_weight_sum = tr_hh_22['WTTRDFIN'].sum()
tr_31_weight_sum = tr_hh_31['WTTRDFIN'].sum()
tr_32_weight_sum = tr_hh_32['WTTRDFIN'].sum()
tr_51_weight_sum = tr_hh_51['WTTRDFIN'].sum()
tr_52_weight_sum = tr_hh_52['WTTRDFIN'].sum()
tr_62_weight_sum = tr_hh_62['WTTRDFIN'].sum()
tr_63_weight_sum = tr_hh_63['WTTRDFIN'].sum()
tr_91_weight_sum = tr_hh_91['WTTRDFIN'].sum()
tr_92_weight_sum = tr_hh_92['WTTRDFIN'].sum()

# Calculate weighted trip per household by division
tr_per_hh_21 = tr_21_weight_sum / hh_21_weight_sum
tr_per_hh_22 = tr_22_weight_sum / hh_22_weight_sum
tr_per_hh_31 = tr_31_weight_sum / hh_31_weight_sum
tr_per_hh_32 = tr_32_weight_sum / hh_32_weight_sum
tr_per_hh_51 = tr_51_weight_sum / hh_51_weight_sum
tr_per_hh_52 = tr_52_weight_sum / hh_52_weight_sum
tr_per_hh_62 = tr_62_weight_sum / hh_62_weight_sum
tr_per_hh_63 = tr_63_weight_sum / hh_63_weight_sum
tr_per_hh_91 = tr_91_weight_sum / hh_91_weight_sum
tr_per_hh_92 = tr_92_weight_sum / hh_92_weight_sum

# Create dataframe for trips by division
tr_hh_divisions = {
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
    'trip_per_hh': [
        tr_per_hh_21,
        tr_per_hh_22,
        tr_per_hh_31,
        tr_per_hh_32,
        tr_per_hh_51,
        tr_per_hh_52,
        tr_per_hh_62,
        tr_per_hh_63,
        tr_per_hh_91,
        tr_per_hh_92
    ]
}
tr_hh_divisions_plot = pd.DataFrame(tr_hh_divisions, columns = ['division', 'trip_per_hh'])

# Create bar chart for trips by division
ax = tr_hh_divisions_plot[['trip_per_hh']].plot(
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
plt.title('Annual Weighted Trips per Houshold by Division', fontsize=16)
ax.set_xlabel("Division, Household Count and Subway System", fontsize=12)
ax.set_ylabel("Annual Weighted Trips per Division (Count)", fontsize=12)
ax.set_xticklabels(x_labels)
plt.show()
