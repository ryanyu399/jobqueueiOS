//
//  Queue.h
//  MassDropJobQueue
//
//  Created by Ryan Yu on 2/21/15.
//  Copyright (c) 2015 Ryan Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Job;

@interface Queue : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *jobs;
@end

@interface Queue (CoreDataGeneratedAccessors)

- (void)addJobsObject:(Job *)value;
- (void)removeJobsObject:(Job *)value;
- (void)addJobs:(NSSet *)values;
- (void)removeJobs:(NSSet *)values;

@end
