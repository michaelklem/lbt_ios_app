//
//  InputTextView.m
//  LittleBirdTales
//
//  Created by Mac on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InputTextView.h"

@implementation InputTextView
@synthesize limited;

@synthesize delegate, textView;
+(InputTextView*)viewFromNib:(id)owner {
    NSString* nibName = @"InputTextView";
    if (IsIdiomPad) {
        nibName = @"InputTextView-iPad";
    } else {
        nibName = @"InputTextView-iPhone";
    }
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:nibName
                                                    owner:owner options:nil];
    for (id object in bundle) {
        if ([object isKindOfClass:[InputTextView class]]) {
            [(InputTextView*)object setLimited:YES];
            return object;
        }
    }   
    return nil;
}

-(void)setLimited:(BOOL)_limited {
    limited = _limited;
    textLeftLabel.hidden = !limited;
}
-(IBAction)save:(id)sender { 
    if (self.delegate) {
        [self.delegate inputedText:textView.text];
        [self cancel:sender];
    }        
}

-(void)textViewDidChange:(UITextView *)_textView {
    textLeftLabel.text = [NSString stringWithFormat:@"%u characters left", 400-_textView.text.length];
}

-(void)showInView:(UIView*)aView {
    CGRect frame = self.frame;
    frame.origin.x = frame.origin.y = 0.0;
    self.frame = frame;
    [self textViewDidChange:self.textView];
    [aView addSubview:self];
    [self.textView becomeFirstResponder];
}

-(IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        textLeftLabel.text = [NSString stringWithFormat:@"%u characters left", 400-textView.text.length];
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self save:nil];
        return NO;
    }
    return YES;
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
