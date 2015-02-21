# jobqueueiOS
A job Queue using REST API written in Objective-C for iOS 8.0

This Project utilizes RESTKIT, so project has to be opened from MassDropJobQueue.xcworkspace

All data is fetched from a URL. The data is fetched in and mapped and saved as CORE DATA objects in the 
application. Any new jobs will be saved to the database in the URL and also fetched again once the 
MasterViewController is pushed again.

The application works as the MasterViewController with a TableViewController that displays the job and the 
status of the application (open/close) and any new job opening will be set automatically to open. 

The data of the objects are designed as a Dictionary with {"title", "open", "date"}