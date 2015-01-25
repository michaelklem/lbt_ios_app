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
#import "CVCell.h"
#import "MFSideMenu.h"

@implementation UserLessonsController

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
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

-(void)uploadTale {
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

-(void)playTale {
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
    
    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
    
    for (int i=0; i<50; i++) {
        [firstSection addObject:[NSString stringWithFormat:@"Cell %d", i]];
        [secondSection addObject:[NSString stringWithFormat:@"item %d", i]];
    }
    
    
    //self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    self.dataArray = [[NSArray alloc] initWithObjects:[Lesson lessons], nil];
    
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    /* end of subclass-based cells block */
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(325, 243)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:15];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
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

- (IBAction)pushExample:(id)sender
{
    UIViewController *stubController = [[UIViewController alloc] init];
    stubController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:stubController animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataArray count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
    return [sectionArray count];
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell identifier
    static NSString *cellIdentifier = @"cvCell";
    
    /*  Uncomment this block to use nib-based cells */
    // UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    // UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    // [titleLabel setText:cellData];
    /* end of nib-based cell block */
    
    /* Uncomment this block to use subclass-based cells */
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSMutableArray *data = [self.dataArray objectAtIndex:indexPath.section];
    Lesson* lesson = [data objectAtIndex:indexPath.row];
    [cell.titleLabel setText:lesson.title];
    [cell.authorLabel setText:lesson.author];
    Page *coverPage = [[lesson pages] objectAtIndex:0];
    [cell.cover setBackgroundImage:coverPage.pageThumbnail forState:UIControlStateNormal];
    [cell.cover setTag:indexPath.row+1000];

    [cell.cover addTarget:self action:@selector(selectTale:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.menu addTarget:self action:@selector(menuOptions:) forControlEvents:UIControlEventTouchUpInside];
    [cell.menu setTag:indexPath.row+1000];
    /* end of subclass-based cells block */
    
    // Return the cell
    return cell;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[UISegmentedControl appearance] setTintColor:[UIColor whiteColor]];
    if ([[Lesson lessons] count] > 0) {
        noTaleBackground.hidden = YES;
    } else {
        noTaleBackground.hidden = NO;
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
        
        currentLesson = [[Lesson lessons] objectAtIndex:currentLessonIndex];
        
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
}

-(void)menuOptions:(id)sender {
    if (sender != nil) {
        UIButton *button = (UIButton*) sender;
        currentLessonIndex = button.tag - 1000;
        currentLesson = [[Lesson lessons] objectAtIndex:currentLessonIndex];
    }

    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Action"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Play", @"Upload", nil];
    
    // Show the sheet

    self.actionSheet.tag = ((UIButton*)sender).tag;
    [self.actionSheet showFromRect:[(UIButton*)sender frame] inView:[(UIButton*)sender superview] animated:YES];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self playTale];
            break;
        case 1:
            [self uploadTale];
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *_currentView in actionSheet.subviews) {
        if ([_currentView isKindOfClass:[UILabel class]]) {
            UILabel *l = [[UILabel alloc] initWithFrame:_currentView.frame];
            l.text = [(UILabel *)_currentView text];
            [l setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
            l.textColor = [UIColor darkGrayColor];
            l.backgroundColor = [UIColor clearColor];
            [l sizeToFit];
            [l setCenter:CGPointMake(actionSheet.center.x, 25)];
            [l setFrame:CGRectIntegral(l.frame)];
            [actionSheet addSubview:l];
            _currentView.hidden = YES;
            break;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
