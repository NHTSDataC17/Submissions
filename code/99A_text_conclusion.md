### Conclusion

The study answered the questions posed in the introduction as follows:

1. What are the most influential factors to trash collection volume?
<br></br>
**Field crew is the most influence factor followed by resources spent (hours, labor, amount) based on feature selection model developed in AML. The importance of crews indicate that highway geometry affects trash collection and efficiency rates. The importance of resources indicate their correlation with trash volume collection.**
<br></br>

2. Can we predict trash collection volume based on these influential factors?
<br></br>
**Yes, regression models were the best suited to predict trash volume which is a continuous variable. Specifically, the boosted tree regression was used to create an estimate.**
<br></br>

3. Does trash collection efficiency rates vary between different highways?
<br></br>
**Yes, efficiency rates vary between highway corridors based on the results of feature selection and clustering model. Specifically, the clustering model provides estimated efficiency rates during future trash collection and pilot study.**
<br></br>

These results provide additional insight to the conjecture that trash collection volume was assumed to be influenced by labor/amount spent and efficiency rates would vary due to different trash generation levels and roadway geometry.

The predictive model will help forecast trash volume based on important features identified in the analysis. These results will help improve the trash control strategy in the SF Bay Area which will be improved further prior to statewide implementation.

### Next Steps

The following steps can be taken to further improve the model based on data exploration, visualization and modeling:

1. As discussed with Caltrans field staff, the variance observed within the dataset can be reduced by improving consistency of data entry methods; as a result, doing so would lower variance and observed error within the regression models.
2. Trash levels may be re-prioritized by other features instead of labor and amount spent to observe whether doing so would improve predictive model performance.
3. These results should improve future trash collection efforts; as a result, the data collected from future efforts will create a positive feedback loop for achieving compliance with the Trash Provisions more quickly.
