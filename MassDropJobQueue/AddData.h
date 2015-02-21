//
//  UIViewController+DetailViewController.h
//  MassDropQueue
//
//  Created by Ryan Yu on 2/21/15.
//  Copyright (c) 2015 Ryan Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddData : UIViewController <UITextFieldDelegate>

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UITextField *job;
@property (nonatomic, strong) UIButton *add;

@end
