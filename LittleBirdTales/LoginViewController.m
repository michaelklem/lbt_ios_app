//
//  ViewController.m
//  LittleBirdTales
//
//  Created by Deep Blue on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "DownloadTalesController.h"
#import "AppDelegate.h"
#import "ServiceLib.h"
#import "SBJson.h"
#import "Lib.h"

@implementation LoginViewController

@synthesize tale, taleNumber, downloadRequest;

-(IBAction)login:(id)sender {
    
    [emailText resignFirstResponder];
    [pwdText resignFirstResponder];
    [schoolText resignFirstResponder];
    
    NSString* email = [[emailText text] stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* password = [pwdText text];

    if (email.length <2 || password.length < 2) {
        [Lib showAlert:@"Little Bird Tale" withMessage:@"Please enter your email and password"];
        return;
    }
    
    [loadingText setText:@"Logging In..."];
    
    [NSTimer scheduledTimerWithTimeInterval: 0
                                     target: self
                                   selector: @selector(showLoadingViewOn)
                                   userInfo: nil
                                    repeats: NO];
    [NSTimer scheduledTimerWithTimeInterval: 0.5f
                                     target: self
                                   selector: @selector(authenticate)
                                   userInfo: nil
                                    repeats: NO];
}

- (void)authenticate {
    NSString* email = [[emailText text] stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* password = [pwdText text];
    NSString *code = [schoolText text];
    NSString *encryptedUserId;
    
    NSString* strData;
    
    if (code.length > 0) {
        strData = [ServiceLib sendRequest:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           email,@"email",
                                           password,@"password",
                                           code,@"schoolcode",
                                           nil] 
                                   andUrl:[NSString stringWithFormat:@"%@/services/authenticate.php",servicesURLPrefix]];
    }
    else {
        strData = [ServiceLib sendRequest:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           email,@"email",
                                           password,@"password",
                                           nil] 
                                   andUrl:[NSString stringWithFormat:@"%@/services/authenticate.php",servicesURLPrefix]];
    }
    BOOL sucessed = FALSE;
    //NSLog(@"--%@",strData);
    
    if (strData) {
        id obj = [strData JSONValue];
        if ([obj isKindOfClass:[NSDictionary class]] && 
            [obj objectForKey:@"id"]) {
            userId = [obj objectForKey:@"id"];
            [Lib setValue:userId forKey:@"user_id"];
            bucketPath = [obj objectForKey:@"bucket_path"];
            [Lib setValue:bucketPath forKey:@"bucket_path"];
            encryptedUserId = [obj objectForKey:@"encrypted_id"];
            [Lib setValue:encryptedUserId forKey:@"encrypted_user_id"];
            sucessed = TRUE;
        }
        else if ([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"error"]) {
            NSString *error = [obj objectForKey:@"error"];
            [Lib showAlert:@"Error" withMessage:error];
        } else {
            [Lib showAlert:@"Error" withMessage:@"Could not connect to our server"];
        }
    } else {
        [Lib showAlert:@"Error" withMessage:@"Could not connect to our server"];
    }
    
    if (sucessed) {
        
        if (rememberMe.on) {
            [Lib setValue:emailText.text forKey:@"username"];
            [Lib setValue:pwdText.text forKey:@"password"];
            [Lib setValue:schoolText.text forKey:@"schoolcode"];
        } else {
            [Lib setValue:@"" forKey:@"username"];
            [Lib setValue:@"" forKey:@"password"];
            [Lib setValue:@"" forKey:@"schoolcode"];
        }
        
        if(downloadRequest) {
            uploadingView.hidden = YES;
            loginView.hidden = YES;
            DownloadTalesController* controller;
            if (IsIdiomPad) {
                controller = [[DownloadTalesController alloc] initWithNibName:@"DownloadTalesController-iPad" bundle:nil];
            } else {
                controller = [[DownloadTalesController alloc] initWithNibName:@"DownloadTalesController-iPhone" bundle:nil];
            }
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        else {
            uploadingView.hidden = NO;
            loginView.hidden = YES;
            backButton.enabled = NO;
            [loadingText setText:@"Uploading..."] ;

            [NSTimer scheduledTimerWithTimeInterval: 0.5f
                                         target: self
                                       selector: @selector(uploadTale)
                                       userInfo: nil
                                        repeats: NO];
        }
    } else {
        [activityIndicator stopAnimating];
        uploadingView.hidden = YES;
        loginView.hidden = NO;
        backButton.enabled = YES;
    }
}

- (void)showLoadingViewOn {
    [activityIndicator startAnimating];
    uploadingView.hidden = NO;
    loginView.hidden = YES;
    backButton.enabled = NO;
}

- (void)uploadTale {
    storyId = [tale uploadWithUserId:userId andBucketPath:bucketPath];
    
    if ([storyId isEqualToString:@""]) {
        uploadingView.hidden = YES;
        loginView.hidden = NO;
        backButton.enabled = YES;
    } else {
        uploadingView.hidden = YES;
        loginView.hidden = YES;
        sharingView.hidden = NO;
        backButton.enabled = YES;
    }
}

- (IBAction)signup:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:servicesURLPrefix]];
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)viewOnWeb:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", servicesURLPrefix, @"tales/view/story_id", storyId]];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)sendEmail: (id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Little Bird Tale" message:@"Your iDevice doesn't support in-app email. Would you like to open Mail App instead?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
			alert.tag = 111;
            [alert show];
		}
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Little Bird Tale" message:@"Your iDevice doesn't support in-app email. Would you like to open Mail App instead?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = 111;
        [alert show];
	}
}

#pragma mark - View lifecycle

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad
{
    [super viewDidLoad];
    [emailText becomeFirstResponder];
    
    NSString *userName = [Lib getValueOfKey:@"username"];
    NSString *password = [Lib getValueOfKey:@"password"];
    NSString *schoolCode = [Lib getValueOfKey:@"schoolcode"];
    
    if (userName != @"" && password != @"" && userName!= NULL & password != NULL) {
        [rememberMe setOn:YES];
        [emailText setText:userName];
        [pwdText setText:password];
        [schoolText setText:schoolCode];
    } else {
        [rememberMe setOn:NO];
    }
    
    if (!IsIdiomPad) {
        rememberMe.transform = CGAffineTransformMakeScale(0.5, 0.5);

    } else {
        rememberMe.transform = CGAffineTransformMakeScale(0.75, 0.75);
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	// Fill out the email body text
	//NSString *emailBody = [[noteList objectAtIndex:currentId] objectForKey:@"content"];
	NSString *subject = @"Sharing a Little Bird Tale with you";
    NSString *viewUrl = [NSString stringWithFormat:@"%@/%@/%@", servicesURLPrefix, @"tales/view/story_id", storyId];
    NSString *emailBody = [NSString stringWithFormat:@"<a href='%@'>Click here to view the story.</a>",viewUrl];
    
    [picker setSubject:subject];
    [picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:?subject='Sharing a Little Bird Tale with you'";
    NSString *viewUrl = [NSString stringWithFormat:@"%@/%@/%@", servicesURLPrefix, @"tales/view/story_id", storyId];
	NSString *body = [NSString stringWithFormat:@"<a href='%@'>Click here to view the story.</a>",viewUrl];
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 111) {
        switch (buttonIndex) {
            case 0:
                [self launchMailAppOnDevice];
                break;
            default:
                return;
                break;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailText) {
        [pwdText becomeFirstResponder];
    }
    else if (textField == pwdText) {
        [schoolText becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return TRUE;
}

- (IBAction)toggleRemember:(id)sender {

}
@end
