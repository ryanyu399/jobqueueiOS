//
//  AppDelegate.m
//  Articles
//
//  Created by Marcin on 02.02.2015.
//  Copyright (c) 2015 Marcin. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MasterViewController *mainController = [[MasterViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    self.window.rootViewController = self.navController;
    
    
    // Initialize RestKit
    NSURL *baseURL = [NSURL URLWithString:@"https://api.myjson.com"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    
    // Initialize managed object model from bundle
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    // Initialize managed object store
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    
    // Complete Core Data intitialization for mapping
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"JobQueue.sqlite"];
    NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Create cache to handle duplicates
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    //Mapping to Queue
    RKEntityMapping *queueMapping = [RKEntityMapping mappingForEntityForName:@"Queue" inManagedObjectStore:managedObjectStore];
    queueMapping.identificationAttributes = @[@"title"];
    [queueMapping addAttributeMappingsFromDictionary:@{ @"title" : @"title"}];
    
    //Mapping to Jobs
    RKEntityMapping *jobMapping = [RKEntityMapping mappingForEntityForName:@"Job" inManagedObjectStore:managedObjectStore];
    jobMapping.identificationAttributes = @[@"title"];
    [jobMapping addAttributeMappingsFromArray:@[ @"title", @"open", @"date"]];
    
    //Establish relationship for Mapping JSON to CORE DATA
    [queueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"jobs" toKeyPath:@"jobs" withMapping:jobMapping]];
    
    // Register jobs mapping with the provider
    RKResponseDescriptor *QueueDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:queueMapping
                                                                                                       method:RKRequestMethodGET
                                                                                                  pathPattern:@"/bins/1r41z"
                                                                                                      keyPath:nil
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:QueueDescriptor];
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
