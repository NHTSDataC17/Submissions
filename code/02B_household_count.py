# Create dataframe for trips by division
# print('hh_21 shape:')
# print(hh_21.shape)
# print('')
# print('hh_22 shape:')
# print(hh_22.shape)
# print('')
# print('hh_31 shape:')
# print(hh_31.shape)
# print('')
# print('hh_32 shape:')
# print(hh_32.shape)
# print('')
# print('hh_51 shape:')
# print(hh_51.shape)
# print('')
# print('hh_52 shape:')
# print(hh_52.shape)
# print('')
# print('hh_62 shape:')
# print(hh_62.shape)
# print('')
# print('hh_63 shape:')
# print(hh_63.shape)
# print('')
# print('hh_91 shape:')
# print(hh_91.shape)
# print('')
# print('hh_92 shape:')
# print(hh_92.shape)
# print('')

hh_divisions = {
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
    'hh': [
        5865,
        1989,
        904,
        3932,
        4404,
        2048,
        275,
        376,
        7394,
        7245
    ]
}
hh_divisions_plot = pd.DataFrame(
    hh_divisions,
    columns = ['division', 'hh']
)

# Create bar chart for trips by division
ax = hh_divisions_plot['hh'].plot(
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
plt.title('Weighted Houshold Count by Division', fontsize=16)
ax.set_xlabel("Division, Household Count and Subway System", fontsize=12)
ax.set_ylabel("Weighted Households per Division (Count)", fontsize=12)
ax.set_xticklabels(x_labels)
plt.show()
