//
//  TextLayer.m
//  pickerSample
//
//  Created by Mac on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextLayer.h"
#import "DrawSettings.h"
@implementation TextLayer
@synthesize textLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, self.frame.size.width - 2*PADDING, self.frame.size.height - 2 * PADDING)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = @"";
        if (IsIdiomPad) {
            textLabel.font = [UIFont systemFontOfSize:24];
        }
        textLabel.textColor = [DrawSettings shared].fillColor;
        [self addSubview:textLabel];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
