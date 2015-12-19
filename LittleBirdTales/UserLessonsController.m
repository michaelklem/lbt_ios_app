//
//  TalesController.m
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserLessonsController.h"
#import "UserTalesController.h"
#import "UserPlayerController.h"
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
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:servicesURLPrefix] encoding:NSUTF8StringEncoding error:nil];
    
    if (connect == NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection!"
                                                        message:@"Connect to internet and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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
-(void)deleteTale {
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
        [noLessonsMessage setHidden:!([Lesson lessons].count == 0)];
        
        [self.collectionView reloadData];
    }
}

-(void)playTale {
    if ([[Lesson lessons] count] > 0) {
        UserPlayerController* controller;
        if (IsIdiomPad) {
            controller = [[UserPlayerController alloc] initWithNibName:@"UserPlayerController-iPad" bundle:nil];
        } else {
            controller = [[UserPlayerController alloc] initWithNibName:@"UserPlayerController-iPhone" bundle:nil];
        }

        controller.tale = currentLesson;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [Lib showAlert:@"Error" withMessage:@"No tale to play"];
    }
    
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

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [Lib setValue:@"false" forKey:@"is_tales_view"];
    
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
    
    activityIndicator.hidesWhenStopped=YES;
}

- (IBAction)pushExample:(id)sender
{
    UIViewController *stubController = [[UIViewController alloc] init];
    stubController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:stubController animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger x = 1;
    if (self.dataArray == nil)
    {
        x = 1;
    }
    else
    {
        x = [self.dataArray count];
    }
    return x;
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
    [noLessonsMessage setHidden:!([Lesson lessons].count == 0)];
    [self.collectionView reloadData];
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
                                              otherButtonTitles:@"Play", @"Upload", @"Edit", @"Delete", nil];
    
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
        case 2:
            [self editTale:nil];
            break;
        case 3:
            [self deleteTale];
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
