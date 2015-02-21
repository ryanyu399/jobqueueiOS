//
//  UIViewController+DetailViewController.m
//  MassDropQueue
//
//  Created by Ryan Yu on 2/21/15.
//  Copyright (c) 2015 Ryan Yu. All rights reserved.
//

#import "AddData.h"
#import "Queue.h"
#import "Job.h"

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@implementation AddData
CGFloat animatedDistance;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/10, 125, 60)];
    self.label.text = @"Enter new job: ";
    [self.view addSubview:self.label ];
    self.job = [[UITextField alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/4, self.view.frame.size.width - 20, 60)];
    self.job.borderStyle = UITextBorderStyleRoundedRect;
    self.job.keyboardType = UIKeyboardTypeDefault;
    self.job.returnKeyType = UIReturnKeyDone;
    //self.job.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.job.delegate = self;
    [self.view addSubview:self.job];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (void)hideKeyboard
{
    [self.job resignFirstResponder];
}

- (void)showKeyboard
{
    // NSLog(@"\n**** SHOWING KETBOaRD ****");
    
}

-(void)save
{
    //get todays date for job posting
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:162000];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    //set url for saving url
    NSURL *url = [NSURL URLWithString:@"http://api.myjson.com/bins/1r41z"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //set method as post to send to database
    [request setHTTPMethod:@"POST"];
    //get json data ready
    NSData *jsonData = [[NSString stringWithFormat:@"{ \"title\": %@, \"open\": open, \"date\": %@ }",self.job.text, formattedDateString]  dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:jsonData];
    //set values of request to ready for sending
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    //asynchronous method to send request to database
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSLog(@"POST sent!");
     }];
    
    //go back to master view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end



