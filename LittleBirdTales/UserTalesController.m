//
//  TalesController.m
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserTalesController.h"
#import "UserLessonsController.h"
#import "PlayerController.h"
#import "EditTaleViewController.h"
#import "DownloadTalesController.h"
#import "LoginViewController.h"
#import "UserLoginViewController.h"
#import "Lib.h"
#import "Lesson.h"

@implementation UserTalesController

-(IBAction)back:(id)sender {
    [Lib setValue:@"" forKey:@"logged_in"];
    [Lib setValue:@"" forKey:@"user_id"];
    [Lib setValue:@"" forKey:@"bucket_path"];
    [Lib setValue:@"" forKey:@"is_teacher"];
    [Lib setValue:@"" forKey:@"is_student"];
    [Lib setValue:@"" forKey:@"encrypted_user_id"];
    [Lesson removeAll];
    UserLoginViewController* controller;
    if (IsIdiomPad) {
        controller = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController-iPad" bundle:nil];
    }
    [self.navigationController pushViewController:controller animated:YES];
}
-(IBAction)editTale:(id)sender {
    if ([[Tale tales] count] > 0) {
        EditTaleViewController* controller;
        if (IsIdiomPad) {
            controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPad" bundle:nil];
        } else {
            controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPhone" bundle:nil];
        }
        controller.tale = currentTale;
        controller.taleNumber = currentTaleIndex;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [Lib showAlert:@"Error" withMessage:@"No Tale to edit"];
    }
}

-(IBAction)tabChange:(id)sender {
    UserLessonsController* controller;
    if (IsIdiomPad) {
        controller = [[UserLessonsController alloc] initWithNibName:@"UserLessonsController-iPad" bundle:nil];
    }
    [self.navigationController pushViewController:controller animated:NO];
}

-(IBAction)uploadTale:(id)sender {
    if ([[currentTale pages] count] == 1) {
        [Lib showAlert:@"Little Bird Tales" withMessage:@"Please add at least 1 page to your story to make it playable"];
        return;
    }
    [activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        NSString* storyId = [currentTale uploadWithUserId:[Lib getValueOfKey:@"user_id"] andBucketPath:[Lib getValueOfKey:@"bucket_path"]];
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            [activityIndicator stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Your story has successfully been uploaded."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        });
    });
    
    }
-(IBAction)deleteTale:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Tales"
                                                        message:@"Delete this tale?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [Tale remove:currentTale];
        
        if ([[Tale tales] count]) {
            currentTaleIndex = 0;
            [self reloadTaleList];
            [self selectTale:nil];
        } else {
            noTaleBackground.hidden = NO;
            for (UIView *view in talesScrollView.subviews) {
                [view removeFromSuperview];
            }
            
            [titleLabel setText:@""];
            [authorLabel setText:@""];
            [pageLabel setText:@""];
            
            [createdLabel setText:@""];
            [modifiedLabel setText:@""];
            
            [previewImage setImage:[UIImage new]];
        }
    }
}

-(IBAction)playTale:(id)sender {
    if ([[Tale tales] count] > 0) {
        PlayerController* controller;
        if (IsIdiomPad) {
            controller = [[PlayerController alloc] initWithNibName:@"PlayerController-iPad" bundle:nil];
        } else {
            controller = [[PlayerController alloc] initWithNibName:@"PlayerController-iPhone" bundle:nil];
        }

        controller.tale = currentTale;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [Lib showAlert:@"Error" withMessage:@"No tale to play"];
    } 
    
}
-(IBAction)newTale:(id)sender {
    InputTaleInfo* tView = [InputTaleInfo viewFromNib:self];
    tView.delegate = self;
    tView.titleField.text = @"My Little Bird Tale";
    tView.authorField.text = @"A Little Bird";
    [tView showInView:self.view];
    
}

-(IBAction)downloadTales:(id)sender {
    DownloadTalesController* controller;
    if (IsIdiomPad) {
        controller = [[DownloadTalesController alloc] initWithNibName:@"DownloadTalesController-iPad" bundle:nil];
    } else {
        controller = [[DownloadTalesController alloc] initWithNibName:@"DownloadTalesController-iPhone" bundle:nil];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)inputedTitle:(NSString*)title author:(NSString*)author {
    
    Tale *newTale = [Tale newTalewithTitle:title author:author];
    [Tale addTale:newTale];
    [Tale save];
    
    currentTaleIndex = [[Tale tales] count] - 1;
    
    EditTaleViewController* controller;
    if (IsIdiomPad) {
        controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPad" bundle:nil];
    } else {
        controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPhone" bundle:nil];
    }
    controller.tale = [[Tale tales] lastObject];
    controller.taleNumber = [[Tale tales] count] - 1;
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[Tale tales] count] > 0) {
        [self selectTale:nil];
    }
    currentTaleIndex = 0;
    
    activityIndicator.hidesWhenStopped=YES;
    
    [newButton.layer setMasksToBounds:YES];
   
    [newButton.layer setBorderColor:[UIColorFromRGB(0x70b7ff) CGColor]];
    if (IsIdiomPad) {
        [newButton.layer setBorderWidth:3.0];
        [newButton.layer setCornerRadius:5.0];
    } else {
        [newButton.layer setBorderWidth:1.0];
        [newButton.layer setCornerRadius:2.0];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[UISegmentedControl appearance] setTintColor:[UIColor whiteColor]];
    if ([[Tale tales] count] > 0) {
        noTaleBackground.hidden = YES;
        [self selectTale:nil];
    } else {
        noTaleBackground.hidden = NO;
    }
    
    if([[Lib getValueOfKey:@"is_student"] boolValue]==false &&
       [[Lib getValueOfKey:@"is_teacher"] boolValue]==false) {
        controlTab.hidden = YES;
    }
    else {
        controlTab.hidden = NO;
    }
    
    [self reloadTaleList];
    
}

- (void)reloadTaleList {
    for (UIView *view in talesScrollView.subviews) {
        [view removeFromSuperview];
    }
    if ([[Tale tales] count] > 0) {
        for (NSInteger i = 0; i < [[Tale tales] count]; i++) {
            Tale *tale = [[Tale tales] objectAtIndex:i];
            Page *coverPage = [[tale pages] objectAtIndex:0];
            UIButton *button;
            
            if (IsIdiomPad) {
                button = [[UIButton alloc] initWithFrame:CGRectMake(210*i, 5, 200, 140)];
                if (i == currentTaleIndex) {
                    [button.layer setCornerRadius:5.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                    [button.layer setBorderWidth:6.0];
                } else {
                    [button.layer setCornerRadius:5.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                    [button.layer setBorderWidth:3.0];
                }
            } else {
                button = [[UIButton alloc] initWithFrame:CGRectMake(95*i, 3, 90, 63)];
                if (i == currentTaleIndex) {
                    [button.layer setCornerRadius:2.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                    [button.layer setBorderWidth:2.0];
                } else {
                    [button.layer setCornerRadius:2.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                    [button.layer setBorderWidth:1.0];
                }
            }
            
            [button setImage:[coverPage pageThumbnail] forState:UIControlStateNormal];
          
            
            [button.layer setMasksToBounds:YES];
            
            
            
            button.tag = 1000 + i;
            [button addTarget:self action:@selector(selectTale:) forControlEvents:UIControlEventTouchUpInside];
            
            [talesScrollView addSubview:button];
        }
        if (IsIdiomPad) {
            [talesScrollView setContentSize:CGSizeMake(210*[[Tale tales] count] , 140)];
        }
        else {
            [talesScrollView setContentSize:CGSizeMake(95*[[Tale tales] count] , 63)];
        }
    }
}

-(void)selectTale:(id)sender {
    if ([[Tale tales] count] > 0) {
        lastTaleIndex = currentTaleIndex;
        UIButton *button;
        
        if (sender != nil) {
            
            button = (UIButton*) sender;
            currentTaleIndex = button.tag - 1000;
        }
        
        if (lastTaleIndex != currentTaleIndex && sender!= nil) {
            if (IsIdiomPad) {
                UIButton *lastButton = (UIButton*)[talesScrollView viewWithTag:lastTaleIndex+1000];
                [lastButton.layer setMasksToBounds:YES];
                [lastButton.layer setCornerRadius:5.0];
                [lastButton.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                [lastButton.layer setBorderWidth:3.0];
                
                [button.layer setMasksToBounds:YES];
                [button.layer setCornerRadius:5.0];
                [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                [button.layer setBorderWidth:6.0];
            } else {
                UIButton *lastButton = (UIButton*)[talesScrollView viewWithTag:lastTaleIndex+1000];
                [lastButton.layer setMasksToBounds:YES];
                [lastButton.layer setCornerRadius:2.0];
                [lastButton.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                [lastButton.layer setBorderWidth:1.0];
                
                [button.layer setMasksToBounds:YES];
                [button.layer setCornerRadius:2.0];
                [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                [button.layer setBorderWidth:2.0];
            }
        }
        
        currentTale = [[Tale tales] objectAtIndex:currentTaleIndex];
        
        Page *coverPage = [[currentTale pages] objectAtIndex:0];
        
        [titleLabel setText:currentTale.title];
        [authorLabel setText:currentTale.author];
        [pageLabel setText:[NSString stringWithFormat:@"%d",[[currentTale pages] count] - 1]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:currentTale.created];
        NSString *createdDate = [dateFormatter stringFromDate:date];
        [createdLabel setText:createdDate];
        date = [NSDate dateWithTimeIntervalSince1970:currentTale.modified];
        NSString *modifiedDate = [dateFormatter stringFromDate:date];
        [modifiedLabel setText:modifiedDate];
        
        [previewImage setImage:coverPage.pageImageWithDefaultBackground];    
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
