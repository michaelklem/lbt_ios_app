//
//  PageCell.m
//  LittleBirdTales
//
//  Created by Mac on 02/01/12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PageCell.h"

@implementation PageCell
@synthesize thumbnail, pageNumber, pageNumberBackground, textIndicator, soundIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
        
        [thumbnail.layer setMasksToBounds:YES];
        [thumbnail.layer setCornerRadius:2.0];
        [thumbnail.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
        if (IsIdiomPad) {
            [thumbnail.layer setBorderWidth:3.0];
        } else {
            [thumbnail.layer setBorderWidth:2.0];
        }
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        [self setBackgroundColor:UIColorFromRGB(0x8FD866)];
        [thumbnail.layer setMasksToBounds:YES];
        [thumbnail.layer setCornerRadius:2.0];
        [thumbnail.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        if (IsIdiomPad) {
            [thumbnail.layer setBorderWidth:3.0];
        } else {
            [thumbnail.layer setBorderWidth:2.0];
        }
        [pageNumberBackground setImage:[UIImage imageNamed:@"ipad_bg_circle_small_selected"]];
        pageNumber.textColor = UIColorFromRGB(0x8FD866);
    }
    else {
        [self setBackgroundColor:[UIColor whiteColor]];
        [thumbnail.layer setMasksToBounds:YES];
        [thumbnail.layer setCornerRadius:2.0];
        [thumbnail.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
        if (IsIdiomPad) {
            [thumbnail.layer setBorderWidth:3.0];
        } else {
            [thumbnail.layer setBorderWidth:2.0];
        }
        [pageNumberBackground setImage:[UIImage imageNamed:@"ipad_bg_circle_small"]];
        pageNumber.textColor = [UIColor whiteColor];
    }
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
