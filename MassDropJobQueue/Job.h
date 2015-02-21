//
//  Job.h
//  MassDropJobQueue
//
//  Created by Ryan Yu on 2/21/15.
//  Copyright (c) 2015 Ryan Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Job : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * open;
@property (nonatomic, retain) NSDate * date;

@end
