

## First I have to download the dataset:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
## Then I have to unzip the dataset and get a list of the files:
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files
## At this point, I will want to read/review the files:
## There are activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

##there are subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

##There are feature files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

##I am going to use the str function to create dataframes 
##for the activity, subject and feature files
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTest)
str(dataSubjectTrain)
str(dataFeaturesTest)
str(dataFeaturesTrain)

##I also need to merge the datasets to one dataset 
## first I will group the rows and columns together
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

##almost forgot! (correction) - I have to add names for the variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

##Next I have to name each varible so I can run reports easily
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## So far I have downloaded the data
## I have merged the training and test data
## Now I need to extract only the measurements on the mean 
## and standard deviation for each 
## so I have to make a way where I can pull names of features
## with the word "mean" or "std"
subdataFeaturesNames <-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)",
  dataFeaturesNames$V2)]
## next I create a subset of data by names of features like "subject" or "activity"
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
## and I create a way to call on that data
Data<-subset(Data,select=selectedNames)
## I can check the structure of the datafram by just using str()
str(Data)
## I still have to set up descriptive names to describe the activity names
## First I need to list the activity names
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

head(Data$activity,30)
## Appropriately labels the data set with descriptive variable names
##In the former part, variables activity and subject and names of the activities have been labelled using descriptive names.In this part, Names of Feteatures will labelled using descriptive variable names.

##prefix t is replaced by time
##Acc is replaced by Accelerometer
##Gyro is replaced by Gyroscope
##prefix f is replaced by frequency
##Mag is replaced by Magnitude
##BodyBody is replaced by Body

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

## next I will check to make sure this works
names(Data)

##From the data set in step 4, creates a second, independent tidy data set 
##with the average of each variable for each activity and each subject.

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

##last, I need to create a code book
library(knitr)
knit2html("codebook.Rmd")
