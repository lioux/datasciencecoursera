# Set correct working directory
setwd("~/RStudio/gettingDataCleaningData/UCI HAR Dataset");

####
## Load Data
####

##
# Read data definitions
features <- read.table("./features.txt");
activityLabels <- read.table("./activity_labels.txt");

# Rename columns
colnames(features) = c("id", "description");
colnames(activityLabels) = c("activityId", "activityDescription");

# Add column to features featuring unique names appropriate to be used as column names
features$uniqueDescription <- make.names(features$description, unique = TRUE)


##
# Read the training data
subjectTrain <- read.table("./train/subject_train.txt");
xTrain <- read.table("./train/X_train.txt");
yTrain <- read.table("./train/y_train.txt");

# Rename columns
colnames(subjectTrain) = "subjectId";
colnames(xTrain) = tolower(features$uniqueDescription);
colnames(yTrain) = "activityId";

# Merge 
trainData <- cbind(subjectTrain, yTrain, xTrain);


##
# Read the test data
subjectTest <- read.table("./test/subject_test.txt");
xTest <- read.table("./test/X_test.txt");
yTest <- read.table("./test/y_test.txt");

# Rename columns
colnames(subjectTest) = "subjectId";
colnames(xTest) = tolower(features$uniqueDescription);
colnames(yTest) = "activityId";

# Merge 
testData <- cbind(subjectTest, yTest, xTest);


##
# Consolidate all data

# 1. Merges the training and the test sets to create one data set.
mergedData <- rbind(trainData, testData);

library(dplyr)

# 3. Uses descriptive activity names to name the activities in the data set
# Add activityDescription column from activityLabels
mergedData <- left_join(mergedData, activityLabels, by = c("activityId" = "activityId"));

# 2. Extracts only the measurements on the mean and standard deviation for each measurement
meanAndStdDeviationData <- select(mergedData, subjectId, activityDescription, contains("mean"), contains("std"));

# 4. Appropriately labels the data set with descriptive variable names.
# Item 4 honored by the previous commands:
# colnames(xTrain) = tolower(features$uniqueDescription);
# colnames(xTest) = tolower(features$uniqueDescription);

library(reshape2)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
meanAndStdDeviationData_melted <- melt(meanAndStdDeviationData, id.vars = c("subjectId", "activityDescription"));
tidyData <- dcast(meanAndStdDeviationData_melted, subjectId + activityDescription ~ variable, mean);

# Record data set
# write.table(tidyData, "tidy.txt", row.names = FALSE);
