//
//  InputTextView.h
//  LittleBirdTales
//
//  Created by Mac on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InputTextViewDelegate 
@required 
    -(void)inputedText:(NSString*)text;
@end

@interface UserInputTextView : UIView <UITextViewDelegate> {
    IBOutlet UILabel* textLeftLabel;
}
@property (nonatomic, assign) BOOL limited;
-(void)showInView:(UIView*)aView;
+(UserInputTextView*)viewFromNib:(id)owner;
@property (nonatomic, assign) id <InputTextViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView* textView;
-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
@end
