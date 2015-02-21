//
//  UITableViewCell+JobTableViewCell.m
//  MassDropQueue
//
//  Created by Ryan Yu on 2/21/15.
//  Copyright (c) 2015 Ryan Yu. All rights reserved.
//

#import "JobTableViewCell.h"

@implementation JobTableViewCell : UITableViewCell

@synthesize textLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    [self layoutSubviews];
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        //self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 300, 30)];
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0f];
        
        self.textLabel.textColor = [UIColor blackColor];
        
        [self addSubview:self.textLabel];
        
        self.status = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 10, 10, 300, 30)];
        self.status.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0f];
        self.status.textColor = [UIColor blackColor];
        [self addSubview:self.status];
    }
    
    // Initialization code
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end


