//
//  TalesController.m
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserLessonsController.h"
#import "UserTalesController.h"
#import "PlayerController.h"
#import "EditAssignmentViewController.h"
#import "LoginViewController.h"
#import "UserLoginViewController.h"
#import "DownloadAssignmentsController.h"
#import "Lib.h"

@implementation UserLessonsController

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
    if ([[Lesson lessons] count] > 0) {
        EditAssignmentViewController* controller;
        if (IsIdiomPad) {
            controller = [[EditAssignmentViewController alloc] initWithNibName:@"EditAssignmentViewController-iPad" bundle:nil];
        } else {
            controller = [[EditAssignmentViewController alloc] initWithNibName:@"EditAssignmentViewController-iPhone" bundle:nil];
        }
        controller.lesson = currentLesson;
        controller.taleNumber = currentLessonIndex;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [Lib showAlert:@"Error" withMessage:@"No Tale to edit"];
    }
}

-(IBAction)tabChange:(id)sender {
    UserTalesController* controller;
    if (IsIdiomPad) {
        controller = [[UserTalesController alloc] initWithNibName:@"UserTalesController-iPad" bundle:nil];
    }
    [self.navigationController pushViewController:controller animated:NO];
}
-(IBAction)uploadTale:(id)sender {
    [activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        NSString* storyId = [currentLesson uploadWithUserId:[Lib getValueOfKey:@"user_id"] andBucketPath:[Lib getValueOfKey:@"bucket_path"]];
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            [activityIndicator stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Your lesson has successfully been uploaded."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
    });
}
-(IBAction)deleteTale:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Lessons"
                                                        message:@"Delete this Lesson?"
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [Lesson remove:currentLesson];
        
        if ([[Lesson lessons] count]) {
            currentLessonIndex = 0;
            [self reloadLessonList];
            [self selectTale:nil];
        } else {
            noTaleBackground.hidden = NO;
            for (UIView *view in lessonsScrollView.subviews) {
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
    if ([[Lesson lessons] count] > 0) {
        PlayerController* controller;
        if (IsIdiomPad) {
            controller = [[PlayerController alloc] initWithNibName:@"PlayerController-iPad" bundle:nil];
        } else {
            controller = [[PlayerController alloc] initWithNibName:@"PlayerController-iPhone" bundle:nil];
        }

        controller.tale = currentLesson;
        
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
    DownloadAssignmentsController* controller;
    if (IsIdiomPad) {
        controller = [[DownloadAssignmentsController alloc] initWithNibName:@"DownloadAssignmentsController-iPad" bundle:nil];
    } else {
        controller = [[DownloadAssignmentsController alloc] initWithNibName:@"DownloadAssignmentsController-iPhone" bundle:nil];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)inputedTitle:(NSString*)title author:(NSString*)author {
    
    /*Tale *newTale = [Tale newTalewithTitle:title author:author];
    [Tale addTale:newTale];
    [Tale save];
    
    currentLessonIndex = [[Tale tales] count] - 1;
    
    EditTaleViewController* controller;
    if (IsIdiomPad) {
        controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPad" bundle:nil];
    } else {
        controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPhone" bundle:nil];
    }
    controller.tale = [[Tale tales] lastObject];
    controller.taleNumber = [[Tale tales] count] - 1;
    [self.navigationController pushViewController:controller animated:YES];*/
}
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    if ([[Lesson lessons] count] > 0) {
        [self selectTale:nil];
    }

    currentLessonIndex = 0;
    
    [newButton.layer setMasksToBounds:YES];
   
    [newButton.layer setBorderColor:[UIColorFromRGB(0x70b7ff) CGColor]];
    if (IsIdiomPad) {
        [newButton.layer setBorderWidth:3.0];
        [newButton.layer setCornerRadius:5.0];
    } else {
        [newButton.layer setBorderWidth:1.0];
        [newButton.layer setCornerRadius:2.0];
    }
    activityIndicator.hidesWhenStopped=YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UISegmentedControl appearance] setTintColor:[UIColor whiteColor]];
    if ([[Lesson lessons] count] > 0) {
        noTaleBackground.hidden = YES;
        [self selectTale:nil];
    } else {
        noTaleBackground.hidden = NO;
    }
    
    [self reloadLessonList];
    
}

- (void)reloadLessonList {
    NSLog(@"Reload lesson list");
    for (UIView *view in lessonsScrollView.subviews) {
        [view removeFromSuperview];
    }
    if ([[Lesson lessons] count] > 0) {
        NSLog(@"Has lessons");
        for (NSInteger i = 0; i < [[Lesson lessons] count]; i++) {
            Lesson *lesson = [[Lesson lessons] objectAtIndex:i];
            Page *coverPage = [[lesson pages] objectAtIndex:0];
            UIButton *button;
            
            if (IsIdiomPad) {
                button = [[UIButton alloc] initWithFrame:CGRectMake(210*i, 5, 200, 140)];
                if (i == currentLessonIndex) {
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
                if (i == currentLessonIndex) {
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
            
            [lessonsScrollView addSubview:button];
        }
        if (IsIdiomPad) {
            [lessonsScrollView setContentSize:CGSizeMake(210*[[Tale tales] count] , 140)];
        }
        else {
            [lessonsScrollView setContentSize:CGSizeMake(95*[[Tale tales] count] , 63)];
        }
    }
}

-(void)selectTale:(id)sender {
    NSLog(@"selecting lesson");
    if ([[Lesson lessons] count] > 0) {
        lastLessonIndex = currentLessonIndex;
        UIButton *button;
        
        if (sender != nil) {
            
            button = (UIButton*) sender;
            currentLessonIndex = button.tag - 1000;
        }
        
        if (lastLessonIndex != currentLessonIndex && sender!= nil) {
            UIButton *lastButton = (UIButton*)[lessonsScrollView viewWithTag:lastLessonIndex+1000];
            [lastButton.layer setMasksToBounds:YES];
            [lastButton.layer setCornerRadius:5.0];
            [lastButton.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
            [lastButton.layer setBorderWidth:3.0];
                
            [button.layer setMasksToBounds:YES];
            [button.layer setCornerRadius:5.0];
            [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
            [button.layer setBorderWidth:6.0];
        }
        
        currentLesson = [[Lesson lessons] objectAtIndex:currentLessonIndex];
        
        Page *coverPage = [[currentLesson pages] objectAtIndex:0];
        
        [titleLabel setText:currentLesson.title];
        [authorLabel setText:currentLesson.author];
        [pageLabel setText:[NSString stringWithFormat:@"%d",[[currentLesson pages] count] - 1]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:currentLesson.created];
        NSString *createdDate = [dateFormatter stringFromDate:date];
        [createdLabel setText:createdDate];
        date = [NSDate dateWithTimeIntervalSince1970:currentLesson.modified];
        NSString *modifiedDate = [dateFormatter stringFromDate:date];
        [modifiedLabel setText:modifiedDate];
        
        [previewImage setImage:coverPage.pageImageWithDefaultBackground];    
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
