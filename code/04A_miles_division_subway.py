# Join NHTS trip with HH data to analyze total weighted trips per HH
veh_hh_21 = pd.merge(vehpub, hh_21, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_22 = pd.merge(vehpub, hh_22, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_31 = pd.merge(vehpub, hh_31, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_32 = pd.merge(vehpub, hh_32, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_51 = pd.merge(vehpub, hh_51, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_52 = pd.merge(vehpub, hh_52, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_62 = pd.merge(vehpub, hh_62, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_63 = pd.merge(vehpub, hh_63, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_91 = pd.merge(vehpub, hh_91, left_on='HOUSEID', right_on='HOUSEID')
veh_hh_92 = pd.merge(vehpub, hh_92, left_on='HOUSEID', right_on='HOUSEID')

# NHTS annual miles by state and weighted total
veh_21_weight_sum = veh_hh_21['ANNMILES'].sum()
veh_22_weight_sum = veh_hh_22['ANNMILES'].sum()
veh_31_weight_sum = veh_hh_31['ANNMILES'].sum()
veh_32_weight_sum = veh_hh_32['ANNMILES'].sum()
veh_51_weight_sum = veh_hh_51['ANNMILES'].sum()
veh_52_weight_sum = veh_hh_52['ANNMILES'].sum()
veh_62_weight_sum = veh_hh_62['ANNMILES'].sum()
veh_63_weight_sum = veh_hh_63['ANNMILES'].sum()
veh_91_weight_sum = veh_hh_91['ANNMILES'].sum()
veh_92_weight_sum = veh_hh_92['ANNMILES'].sum()

# Calculate weighted trip per household by state
veh_per_hh_21 = veh_21_weight_sum / hh_21_weight_sum
veh_per_hh_22 = veh_22_weight_sum / hh_22_weight_sum
veh_per_hh_31 = veh_31_weight_sum / hh_31_weight_sum
veh_per_hh_32 = veh_32_weight_sum / hh_32_weight_sum
veh_per_hh_51 = veh_51_weight_sum / hh_51_weight_sum
veh_per_hh_52 = veh_52_weight_sum / hh_52_weight_sum
veh_per_hh_62 = veh_62_weight_sum / hh_62_weight_sum
veh_per_hh_63 = veh_63_weight_sum / hh_63_weight_sum
veh_per_hh_91 = veh_91_weight_sum / hh_91_weight_sum
veh_per_hh_92 = veh_92_weight_sum / hh_92_weight_sum

# Create dataframe for trips by division
veh_hh_divisions = {
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
    'veh_per_hh': [
        veh_per_hh_21,
        veh_per_hh_22,
        veh_per_hh_31,
        veh_per_hh_32,
        veh_per_hh_51,
        veh_per_hh_52,
        veh_per_hh_62,
        veh_per_hh_63,
        veh_per_hh_91,
        veh_per_hh_92
    ]
}
veh_hh_divisions_plot = pd.DataFrame(
    veh_hh_divisions,
    columns = ['division', 'veh_per_hh']
)

ax = veh_hh_divisions_plot[['veh_per_hh']].plot(
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
plt.title('Annual Miles per Houshold by Division', fontsize=16)
ax.set_xlabel("Division, Household Count and Subway System", fontsize=12)
ax.set_ylabel("Annual Miles per Division (Count)", fontsize=12)
ax.set_xticklabels(x_labels)
plt.show()
