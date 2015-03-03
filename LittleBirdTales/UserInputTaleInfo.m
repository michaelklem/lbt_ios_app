//
//  InputTaleInfo.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInputTaleInfo.h"

@implementation UserInputTaleInfo

@synthesize delegate, titleField, authorField;
+(UserInputTaleInfo*)viewFromNib:(id)owner {
    NSString* nibName = @"InputTaleInfo";
    if (IsIdiomPad) {
        nibName = @"UserInputTaleInfo-iPad";
    } else {
        nibName = @"UserInputTaleInfo-iPhone";
    }
    
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:nibName
                                                    owner:owner options:nil];
    for (id object in bundle) {
        if ([object isKindOfClass:[UserInputTaleInfo class]]) {
            return object;
        }
    }   
    return nil;
}

-(IBAction)save:(id)sender { 
    if (authorField.text.length > 0 && titleField.text.length > 0) {
        if (self.delegate) {
            [self.delegate inputedTitle:titleField.text author:authorField.text];
            [self cancel:sender];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:titleField]) {
        [authorField becomeFirstResponder];
    } else {
        if (authorField.text.length > 0 && titleField.text.length > 0) {
            [self save:nil];
        }
    }
    return YES;
}


-(void)showInView:(UIView*)aView {
    CGRect frame = self.frame;
    frame.origin.x = frame.origin.y = 0.0;
    self.frame = frame;
    
    [aView addSubview:self];
    [titleField becomeFirstResponder];
}

-(IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
