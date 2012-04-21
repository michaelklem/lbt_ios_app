//
//  InputTaleInfo.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InputTaleInfoDelegate 
@required 
-(void)inputedTitle:(NSString*)title author:(NSString*)author;
@end

@interface InputTaleInfo : UIView <UITextFieldDelegate> {
    
}
-(void)showInView:(UIView*)aView;
+(InputTaleInfo*)viewFromNib:(id)owner;
@property (nonatomic, assign) id <InputTaleInfoDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField* titleField;
@property (nonatomic, retain) IBOutlet UITextField* authorField;

-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
@end
