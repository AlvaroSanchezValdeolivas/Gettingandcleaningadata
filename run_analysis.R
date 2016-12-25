# Load Libraries
library(reshape2)

filename <- "getdata_dataset.zip"

# Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Step 2 Extract only the measurements on the mean and standard deviation for each measurement.
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Step 3 Uses descriptive activity names to name the activities in the data set.
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Step 4 Appropriately labels the data set with descriptive variable names.
resultData <- rbind(train, test)
colnames(resultData) <- c("subject", "activity", featuresWanted.names)

resultData$activity <- factor(resultData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
resultData$subject <- as.factor(resultData$subject)

resultData.melted <- melt(resultData, id = c("subject", "activity"))
resultData.mean <- dcast(resultData.melted, subject + activity ~ variable, mean)

# Step 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
write.table(resultData.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)