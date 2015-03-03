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
#import "UserEditTaleViewController.h"
#import "DownloadTalesController.h"
#import "LoginViewController.h"
#import "UserLoginViewController.h"
#import "Lib.h"
#import "Lesson.h"
#import "MFSideMenu.h"
#import "CVCell.h"

@implementation UserTalesController

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}
-(IBAction)editTale:(id)sender {
    if ([[Tale tales] count] > 0) {
        UserEditTaleViewController* controller;
        if (IsIdiomPad) {
            controller = [[UserEditTaleViewController alloc] initWithNibName:@"UserEditTaleViewController-iPad" bundle:nil];
        } else {
            controller = [[UserEditTaleViewController alloc] initWithNibName:@"UserEditTaleViewController-iPhone" bundle:nil];
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

-(void)uploadTale {
    if ([[currentTale pages] count] == 1) {
        [Lib showAlert:@"Little Bird Tales" withMessage:@"Please add at least 1 page to your story to make it playable"];
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

-(void)deleteTale {
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
        [noTalesMessage setHidden:!([Tale tales].count == 0)];
        [self.collectionView reloadData];
    }
}

-(void)playTale {
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
    UserInputTaleInfo* tView = [UserInputTaleInfo viewFromNib:self];
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
    
    UserEditTaleViewController* controller;
    if (IsIdiomPad) {
        controller = [[UserEditTaleViewController alloc] initWithNibName:@"UserEditTaleViewController-iPad" bundle:nil];
    } else {
        controller = [[UserEditTaleViewController alloc] initWithNibName:@"UserEditTaleViewController-iPhone" bundle:nil];
    }
    controller.tale = [[Tale tales] lastObject];
    controller.taleNumber = [[Tale tales] count] - 1;
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - View lifecycle

-(void)selectTale:(id)sender {
    NSLog(@"selecting tale");
    if ([[Tale tales] count] > 0) {
        lastTaleIndex = currentTaleIndex;
        UIButton *button;
        
        if (sender != nil) {
            
            button = (UIButton*) sender;
            currentTaleIndex = button.tag - 1000;
        }
        
        currentTale = [[Tale tales] objectAtIndex:currentTaleIndex];
        
        UserEditTaleViewController* controller;
        controller = [[UserEditTaleViewController alloc] initWithNibName:@"UserEditTaleViewController-iPad" bundle:nil];
        
        controller.tale = currentTale;
        controller.taleNumber = currentTaleIndex;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}

-(void)menuOptions:(id)sender {
    if (sender != nil) {
        UIButton *button = (UIButton*) sender;
        currentTaleIndex = button.tag - 1000;
        currentTale = [[Tale tales] objectAtIndex:currentTaleIndex];
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
    Tale* lesson = [data objectAtIndex:indexPath.row];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [Lib setValue:@"true" forKey:@"is_tales_view"];
    self.dataArray = [[NSArray alloc] initWithObjects:[Tale tales], nil];
    
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    /* end of subclass-based cells block */
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(325, 243)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:15];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    currentTaleIndex = 0;
    
    activityIndicator.hidesWhenStopped=YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UISegmentedControl appearance] setTintColor:[UIColor whiteColor]];
    
    [noTalesMessage setHidden:!([Tale tales].count == 0)];
    [self.collectionView reloadData];
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
