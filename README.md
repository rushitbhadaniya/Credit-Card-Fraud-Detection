# Credit-Card-Fraud-Detection 
In this project I build machine learning models to identify fraud in credit card transactions. 
## Requirements
Install R (and RStudio)
If you don’t already have them, download and install R https://www.r-project.org/ and RStudio https://www.rstudio.com/products/rstudio/download/.

## Data Source
Here, I am using a dataset that is available on <a href="https://www.kaggle.com/mlg-ulb/creditcardfraud">Kaggle</a>.
It's a CSV file, contains 31 features, the last feature is used to classify the transaction whether it is a fraud or not.
### Information regarding data
It contains only numerical input variables which are the result of a PCA transformation. Unfortunately, due to confidentiality issues, they cannot provide the original features and more background information about the data. Features V1, V2, … V28 are the principal components obtained with PCA, the only features which have not been transformed with PCA are 'Time' and 'Amount'. Feature 'Time' contains the seconds elapsed between each transaction and the first transaction in the dataset. The feature 'Amount' is the transaction Amount, this feature can be used for example-dependant cost-senstive learning. Feature 'Class' is the response variable and it takes value 1 in case of fraud and 0 otherwise.
## Acknowledgements
The dataset has been collected and analysed during a research collaboration of Worldline and the Machine Learning Group (http://mlg.ulb.ac.be) of ULB (Université Libre de Bruxelles) on big data mining and fraud detection.
