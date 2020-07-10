# Install & Load Library ---------------------------------------------------------
#install.packages("caret")
#install.packages("ggcorrplot")
#install.packages("ROSE")
#install.packages("smotefamily")
#install.packages("rpart.plot")
#install.packages("e1071")
library(caret)
library(dplyr)
library(ggplot2)
library(caTools)
library(ggcorrplot)
library(ROSE)
library(smotefamily)
library(rpart)
library(rpart.plot)
library(e1071)

# Import Dataset ---------------------------------------------------------------
credit_card<-read.csv('D:\\M.Tech\\Credit_Card_fraud_detection\\creditcard_dataset.csv')


# Analyze Dataset ---------------------------------------------------------
#str(dataset) helps in understanding the structure of the data set, data type of each attribute and number of rows and columns present in the data.
str(credit_card)

credit_card$Class = factor(credit_card$Class, levels = c(0,1))
#Summary() is one of the most important functions that help in summarising each attribute in the dataset. It gives a set of descriptive statistics, depending on the type of variable.
summary(credit_card)

#check for missing values
sum(is.na(credit_card))

#visualisation for credit card transaction...
table(credit_card$Class)
prop.table(table(credit_card$Class))
#pie chart for credit card transaction
labels<-c("Legit","Fraud")
labels<-paste(labels,round(100*prop.table(table(credit_card$Class)),2))
labels<-paste(labels,"%")

pie(table(credit_card$Class),labels,col = c("green","red"),
                            main = "Pie chart of Transactions" )

set.seed(1)
#here, we use smaple_frac() function to get a smaller fraction from our dataset.
#here, we are taking small fraction of our dataset to train and build the mode.so that it is computationally faster.
credit_card <- credit_card %>%sample_frac(0.1)
table(credit_card$Class)

ggplot(data=credit_card,aes(x=V14 ,y=V10,col= Class))+
  geom_point()+
  theme_bw()+
  scale_color_manual(values = c('dodgerblue2','red'))

# Splitting data into Training and Test data ------------------------------
#here, we use caTool library to slpit our data

set.seed(123)
data_sample = sample.split(credit_card$Class,SplitRatio = 0.80)

train_data= subset(credit_card,data_sample== TRUE)
test_data= subset(credit_card,data_sample== FALSE)

dim(train_data)
dim(test_data)

# Balance the Imbalanced dataset ------------------------------------------
# #1. Random over-sampling(Ros)
# table(train_data$Class)
# n_legit<-22750
# new_frac_legit <-0.50 #so,after oversampling class 0 and 1 will be 50-50% in our data set.
# new_no_total<- n_legit/new_frac_legit
# #we use ROSE library to for balancing our dataset
# 
# oversampling_result <- ovun.sample(class ~ .,
#                                    data=train_data,
#                                    method = "over",
#                                    N=new_no_total,
#                                    Seed=2020)
# oversampling_credit <- oversampling_result
# table(oversampling_credit)
# # this method will copy and paste class 1 data rendomly to oversample the dataset.
# #So, this method endup creating duplicate data.
# 
# #2.Random Under-sampling (RUS)
# table(train_data$Class)
# n_fraud<-35
# new_frac_fraud <-0.50 #so,after under-sampling class 0 and 1 will be 50-50% in our data set.
# new_no_total<- n_fraud/new_frac_fraud
# 
# undersampling_result <- ovun.sample(class ~ .,
#                                    data=train_data,
#                                    method = "under",
#                                    N=new_no_total,
#                                    Seed=2020)
# undersampling_credit <- undersampling_result
# table(undersampling_credit)
# #This method will decrease the number of legitimate cases.
# #Problem here, is that we endup loosing lots of data.
# 
# #3.Use Both Method
# table(train_data$Class)
# n_new<-nrow(train_data) #=22785
# new_fraction_fraud <-0.50 #so,after under-sampling class 0 and 1 will be 50-50% in our data set.
# 
# sampling_result <- ovun.sample(class ~ .,
#                                     data=train_data,
#                                     method = "both",
#                                     N=n_new,
#                                     p= new_fraction_fraud,
#                                     Seed=2020)
# 
# sampling_credit <- sampling_result$data
# table(sampling_credit)

#4. SMOTE method for unbalanced data
#it will generate a new "SMOTEd" data set that addresses the class unbalance problem.
table(train_data$Class)
n_legit<-22750
n_fraud<-35
wanted_ratio<-0.6 #so,after smote 60% will be legit transaction and 40% will be fraud transaction 
#calculate the value for the dup_size parameter of SMOTE
ntimes <- ((1- wanted_ratio)/wanted_ratio)*(n_legit/n_fraud)-1

smote_output = SMOTE(X= train_data[ ,-c(1,31)],
                     target = train_data$Class,
                     K=5,
                     dup_size = ntimes)

credit_smote <- smote_output$data

colnames(credit_smote)[30]<-"Class"
# see the distribution of class column
prop.table(table(credit_smote$Class))
#pie chart
labels<-c("Legit","Fraud")
labels<-paste(labels,round(100*prop.table(table(credit_smote$Class)),2))
labels<-paste(labels,"%")
pie(table(credit_smote$Class),labels,col = c("green","red"),
    main = "Pie chart of Transactions after smote" )

#scatter plot
ggplot(data=credit_smote
       ,aes(x=V14 ,y=V10,col= Class))+
  geom_point()+
  theme_bw()+
  scale_color_manual(values = c('dodgerblue2','red'))

# Build Decision Tree  ----------------------------------------------------
#we use Rpart library to build decision tree

CART_model = rpart(Class ~ .,credit_smote)

rpart.plot(CART_model,extra = 0,type = 5,tweak = 1.2)
#Predict fraud classes 
predicted_val <-predict(CART_model,test_data,type = 'class')

#build confusion matrix 
confusionMatrix(predicted_val,test_data$Class)

#Let's build same model using original train data--------------------------
CART_model = rpart(Class ~ .,train_data[,-1])

rpart.plot(CART_model,extra = 0,type = 5,tweak = 1.2)
#Predict fraud classes 
predicted_val <-predict(CART_model,test_data[-1],type = 'class')

#build confusion matrix 
confusionMatrix(predicted_val,test_data$Class)

#Check Accuracy on whole somte data ----------------------------------------
CART_model = rpart(Class ~ .,credit_smote)
predicted_val <-predict(CART_model,credit_card[-1],type = 'class')
confusionMatrix(predicted_val,credit_card$Class)


# Check Accuracy on whole unbalanced data ---------------------------------
CART_model = rpart(Class ~ .,train_data[,-1])
predicted_val <-predict(CART_model,credit_card[-1],type = 'class')
confusionMatrix(predicted_val,credit_card$Class)


