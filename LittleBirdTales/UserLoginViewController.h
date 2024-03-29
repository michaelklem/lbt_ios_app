//
//  ViewController.h
//  LittleBirdTales
//
//  Created by Mac on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Tale.h"
#import "Lesson.h"

@interface UserLoginViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate> {
    IBOutlet UITextField* emailText;
    IBOutlet UITextField* pwdText;
    IBOutlet UITextField* schoolText;
    
    IBOutlet UILabel *loadingText;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    IBOutlet UIButton *backButton;
    
    IBOutlet UIView *loginView;
    IBOutlet UIView *loadingView;
    
    IBOutlet UISwitch *rememberMe;
    
    NSString *storyId;
    NSString *userId;
    NSString *bucketPath;
    NSString *isTeacher;
    NSString *isStudent;
}

@property (nonatomic, retain) Tale* tale;
@property (nonatomic, assign) NSInteger taleNumber;
@property (nonatomic, assign) BOOL downloadRequest;

- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)guest:(id)sender;
- (IBAction)viewOnWeb:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)toggleRemember:(id)sender;
- (void)uploadTale;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;
@end
