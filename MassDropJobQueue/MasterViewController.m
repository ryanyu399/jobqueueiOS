//
//  MasterViewController.m
//  Articles
//
//  Created by Marcin on 02.02.2015.
//  Copyright (c) 2015 Marcin. All rights reserved.
//

#import "MasterViewController.h"
#import "AddData.h"
#import "JobTableViewCell.h"

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#import "Job.h"
#import "Queue.h"

@interface MasterViewController ()

@property NSArray *jobs;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:22],
      NSFontAttributeName, nil]];
    
    self.title = @"Job Queue";
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 15, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    
    // add to canvas
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                              target:self action:@selector(addData)];
    
    [self requestData];
}

-(void)viewDidAppear:(BOOL)animated
{

    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addData
{
    AddData *add = [[AddData alloc] init];
    [self.navigationController pushViewController:add animated:YES ];
}


#pragma mark - Segues
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Article *article = self.articles[indexPath.row];
        [[segue destinationViewController] setDetailItem:article.summary];
    }
}
*/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.jobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"JobTableViewCell";
    
    JobTableViewCell *cell = [[JobTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[JobTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //get each job in Queue and display in table view
    Job *job = self.jobs[indexPath.row];
    cell.textLabel.text = job.title;
    cell.status.text = job.open;
    return cell;
}


#pragma mark - RESTKit

- (void)requestData {
    //get new data from database
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
    
    //map new data into CORE DATA
    NSString *requestPath = @"/bins/1r41z";
    
    [[RKObjectManager sharedManager]
     getObjectsAtPath:requestPath
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //jobs have been saved in core data by now
         
         [self fetchArticlesFromContext];
         
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
     }
     ];
}

- (void)fetchArticlesFromContext {
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Queue"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    //get objects in CORE DATA Queue
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Queue *qu = [fetchedObjects firstObject];
    //get all jobs objects in Queue
    NSArray *arr = [qu.jobs allObjects];
    
    //Sort array based on date assigned
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = @[dateDescriptor];
    self.jobs = [arr sortedArrayUsingDescriptors:sortDescriptors];
    //reload the table view
    [self.tableView reloadData];
    
}

@end
