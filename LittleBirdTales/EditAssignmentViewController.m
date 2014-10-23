//
//  EditTaleViewController.m
//  LittleBirdTales
//
//  Created by Deep Blue on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditAssignmentViewController.h"


@implementation EditAssignmentViewController
@synthesize lesson, taleNumber, popoverController, soundPlayer;


-(void)tapDetected{
    Page *page = [lesson.pages objectAtIndex:currentPage];
    if(!page.image_locked) {
        [self drawPage:(nil)];
    }
}

-(IBAction)drawPage:(id)sender {

    //TODO: Check if there is a page to draw
    DrawController* controller;
    if (IsIdiomPad) {
        controller = [[DrawController alloc] initWithNibName:@"DrawController-iPad" bundle:nil];
    } else {
        controller = [[DrawController alloc] initWithNibName:@"DrawController-iPhone" bundle:nil];
    }
    Page* page = [lesson.pages objectAtIndex:currentPage];
    controller.delegate = self;
    controller.page = page;
    [self.navigationController pushViewController:controller animated:YES];
}
-(IBAction)textPage:(id)sender {
    if (currentPage == 0) {
        InputTaleInfo* tView = [InputTaleInfo viewFromNib:self];
        tView.delegate = self;
        [tView.titleField setText:lesson.title];
        [tView.authorField setText:lesson.author];
        [tView showInView:self.view];
    }
    else {
        InputTextView* tView = [InputTextView viewFromNib:self];
        tView.delegate = self;
        Page *page = [lesson.pages objectAtIndex:currentPage];
        [tView.textView setText:page.text];
        [tView showInView:self.view];
    }
}


-(void)inputedText:(NSString*)text forPage:(NSInteger)pid {
    Page *page = [lesson.pages objectAtIndex:pid];
    
    [page setText:text];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];

}

-(void)inputedText:(NSString*)text {
    Page *page = [lesson.pages objectAtIndex:currentPage];
    NSString *currentText = page.text;
    if (text != currentText) {
        [[undoManager prepareWithInvocationTarget:self] inputedText:currentText forPage:currentPage];
    
        [undoManager setActionName:[NSString stringWithFormat:@"Change Text of Page #%ld",(long)currentPage]];
        
        
        [page setText:text];
        [page setModified:round([[NSDate date] timeIntervalSince1970])];
        [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
        [pagesTableView reloadData];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
        [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)inputedTitle:(NSString*)title author:(NSString*)author {
   
    NSString* currentTitle = lesson.title;
    NSString* currentAuthor = lesson.author;
    
    if (currentAuthor != author || currentTitle != title) {
        [[undoManager prepareWithInvocationTarget:self] inputedTitle:currentTitle author:currentAuthor];
        
        if (![undoManager isUndoing]) {
            [undoManager setActionName:NSLocalizedString(@"Change Tale Info", @"Change Tale Info")];
        }
        [lesson setTitle:title];
        [lesson setAuthor:author];
        [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
        Page *cover = [[lesson pages] objectAtIndex:0];
        cover.text = title;
        titleLabel.text = title;
    }
    
    
    
};

- (void)setVoice:(NSString *)voiceName andDuration:(double)duration forPage:(NSInteger)pid{
    Page *page = [lesson.pages objectAtIndex:pid];
    [page setVoice:voiceName];
    [page setTime:duration + 1];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pid inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:pid];
}

- (void)setVoice:(NSString *)voiceName andDuration:(double)duration{
    Page *page = [lesson.pages objectAtIndex:currentPage];
    NSString *currentVoiceName = page.voice;
    double currentDuration = page.time;
    if (voiceName != currentVoiceName) {
        [[undoManager prepareWithInvocationTarget:self] setVoice:currentVoiceName andDuration:currentDuration forPage:currentPage];
        [undoManager setActionName:[NSString stringWithFormat:@"Change Voice of Page #%ld",(long)currentPage]];

        
        [page setVoice:voiceName];
        [page setTime:duration + 1];
        [page setModified:round([[NSDate date] timeIntervalSince1970])];
        [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
        [pagesTableView reloadData];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
        [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
        [self setActivePage:currentPage];
    }
    
}

-(IBAction)uploadPage:(id)sender {
    UIActionSheet* actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] 
                          initWithTitle:@"Choose image"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:@"From Photo Library"
                          otherButtonTitles:@"From Gallery", @"Take photo", nil];
    }
    else {
        actionSheet = [[UIActionSheet alloc] 
                       initWithTitle:@"Choose image"
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:@"From Photo Library"
                       otherButtonTitles:@"From Gallery", nil];
    }
    [actionSheet showInView:self.view];
}
-(IBAction)soundPage:(id)sender {
    AudioRecord* tView = [AudioRecord viewFromNib:self];
    Page* page = [lesson.pages objectAtIndex:currentPage];
    tView.delegate = self;
    tView.pageFolder = page.pageFolder;
    tView.voiceName = page.voice;
    tView.pageText = page.text;
    tView.playOnly = page.audio_locked;
    [tView showInView:self.view];
}
-(IBAction)deletePage:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Lesson"
                                                        message:@"Delete this page?"
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"OK", nil];
    alertView.tag = 101;
    [alertView show];
}

-(void)addPage:(Page*)page atIndex:(NSInteger)index {
    [lesson.pages insertObject:page atIndex:index];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:index];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            Page* page = [lesson.pages objectAtIndex:currentPage];
            
            //Undo
            [[undoManager prepareWithInvocationTarget:self] addPage:page atIndex:currentPage];
            [undoManager setActionName:[NSString stringWithFormat:@"Delete Page #%ld",(long)currentPage]];
            
            [lesson.pages removeObjectAtIndex:currentPage];
            [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
            [pagesTableView reloadData];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage-1 inSection:0];
            [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
            [self setActivePage:currentPage-1];
            [self reloadLessonList];
        }
    }
    else if (alertView.tag == 102) {
        [undoManager undo];
    }
}

- (void)deleteLastPageFromPage:(NSInteger)pid {
    [lesson.pages removeLastObject];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pid inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:pid];
}

-(IBAction)newPage:(id)sender {
    
    Page *samplePage = [Page newPage];
    samplePage.pageFolder = [NSString stringWithFormat:@"%@/%0.f",[Lib taleFolderPathFromIndex:lesson.index],samplePage.index];
    [lesson.pages addObject:samplePage];
    
    [[undoManager prepareWithInvocationTarget:self] deleteLastPageFromPage:currentPage];
    [undoManager setActionName:[NSString stringWithFormat:@"Add New Page"]];
    
    [pagesTableView reloadData];
    [self reloadLessonList];
    [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[lesson.pages count]-1 inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    
    float w = pagesScrollView.frame.size.width;
    float h = pagesScrollView.frame.size.height;
    float newPosition = pagesScrollView.contentOffset.x+w;
    CGRect toVisible = CGRectMake(newPosition, 0, w, h);
    
    [pagesScrollView scrollRectToVisible:toVisible animated:YES];
    
    [self setActivePage:[lesson.pages count]-1];
}

-(IBAction)undo:(id)sender {
    if ([undoManager canUndo]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Tales"
                                                            message:@"Undo your last action?" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Cancel" 
                                                  otherButtonTitles:@"OK", nil];
        alertView.tag = 102;
        [alertView show];
    }
    else {
        [Lib showAlert:@"Little Bird Tales" withMessage:@"Nothing to Undo"];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)setActivePage:(NSInteger)index {
    
    if (lastPageIndex != index) {
        UIButton *lastButton = (UIButton*)[pagesScrollView viewWithTag:lastPageIndex+1000];
        [lastButton.layer setMasksToBounds:YES];
        [lastButton.layer setCornerRadius:2.0];
        [lastButton.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
        [lastButton.layer setBorderWidth:1.0];
        
        UIButton *button = (UIButton*)[pagesScrollView viewWithTag:index+1000];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:2.0];
        [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
        [button.layer setBorderWidth:2.0];
    }
    
    pageNumberView.text = [NSString stringWithFormat:@"Page %ld of %ld",(long)index+1, (long)lesson.pages.count];
    if (index == 0) {
        [editButton setImage:[UIImage imageNamed:@"btn-edittale-ipad.png"] forState:UIControlStateNormal];
        deleteButton.hidden = YES;
    }
    else {
        [editButton setImage:[UIImage imageNamed:@"btn-edit-ipad.png"] forState:UIControlStateNormal];
        deleteButton.hidden = NO;
    }
    
    currentPage = index;
    lastPageIndex = index;
    Page *page = [lesson.pages objectAtIndex:currentPage];
    
    [teacherTextView setText:page.teacher_text];
    [studentTextView setText:page.text];
    studentTextView.editable = !page.text_locked;
    uploadButton.enabled = !page.image_locked;
    imageButton.enabled = !page.image_locked;
    editButton.enabled = !page.text_locked;

    if(page.teacher_voice != nil && page.teacher_voice.length > 0) {
        stopButton.hidden = YES;
        playButton.hidden = NO;
    }
    else {
        stopButton.hidden = YES;
        playButton.hidden = YES;
    }
    [imageView setImage:[page pageImageWithDefaultBackground]];
}

-(void)setActivePage2:(id)sender {
    if (sender != nil) {
        UIButton *button = (UIButton*) sender;
        currentPage = button.tag - 1000;
        [self setActivePage:currentPage];
    }
}

#pragma mark - View lifecycle

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad {
    [super viewDidLoad];

    //UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    //swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    //[self.view addGestureRecognizer:swipeleft];
    
    //UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    //swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    //[self.view addGestureRecognizer:swiperight];
    
    [studentTextView setDelegate:self];
    
    //To make the border look very close to a UITextField
    [studentTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [studentTextView.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    studentTextView.layer.cornerRadius = 5;
    studentTextView.clipsToBounds = YES;
    
    //To make the border look very close to a UITextField
    [teacherTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [teacherTextView.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    teacherTextView.layer.cornerRadius = 5;
    teacherTextView.clipsToBounds = YES;
    [teacherTextView.layer setBackgroundColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor]];
    
    //Undo Manager
    undoManager = [[NSUndoManager alloc] init];
    [undoManager setLevelsOfUndo:5];
    
    taleHistory = [[NSMutableArray alloc] init];
    activePageHistory = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view from its nib.
    if (lesson == nil) {
        lesson = [[Lesson alloc] init];
        
        NSMutableArray *pageArray = [[NSMutableArray alloc] init];
        
        Page *samplePage = [[Page alloc] init];
        samplePage.image = @"";
        samplePage.voice = @"";
        samplePage.text = @"";
        samplePage.index = 1;
        samplePage.order = 1;
        
        [pageArray addObject:samplePage];
        
        lesson.pages = pageArray;
    }
    
    titleLabel.text = lesson.title;
    
    pagesTableView.editing = YES;
    pagesTableView.allowsSelectionDuringEditing = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:singleTap];
    
    [self setActivePage:0];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    Page *page = [lesson.pages objectAtIndex:currentPage];
    
    [page setText:studentTextView.text];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
}

- (void)viewWillAppear:(BOOL)animated {
    Page *page = [lesson.pages objectAtIndex:currentPage];
    [pagesTableView reloadData];
    [imageView setImage:[page pageImageWithDefaultBackground]];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionTop];
    
    [self reloadLessonList];
    
    [super viewWillAppear:animated];
}

- (void)reloadLessonList {
    NSLog(@"Reload lesson list");
    for (UIButton *view in pagesScrollView.subviews) {
        [view removeFromSuperview];
    }
    if ([[lesson pages] count] > 0) {
        NSLog(@"Has lessons");
        for (NSInteger i = 0; i < [[lesson pages] count]; i++) {
            Page *page = [[lesson pages] objectAtIndex:i];
            UIButton *button;
            
            
            button = [[UIButton alloc] initWithFrame:CGRectMake(65*i, 3, 60, 40)];
            if (i == currentPage) {
                [button.layer setCornerRadius:2.0];
                [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                [button.layer setBorderWidth:2.0];
            } else {
                [button.layer setCornerRadius:2.0];
                [button.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                [button.layer setBorderWidth:1.0];
            }
            
            
            [button setImage:[page pageThumbnail] forState:UIControlStateNormal];
            
            
            [button.layer setMasksToBounds:YES];
            
            
            
            button.tag = 1000 + i;
            [button addTarget:self action:@selector(setActivePage2:) forControlEvents:UIControlEventTouchUpInside];
            
            [pagesScrollView addSubview:button];
        }
        
        [pagesScrollView setContentSize:CGSizeMake(65*[[lesson pages] count] , 40)];

    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [lesson deleteOrphanFiles];
    [Lesson updateLesson:lesson at:taleNumber];
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    
    if([lesson.pages count] > currentPage+1) {
        [self setActivePage:currentPage+1];
    }
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if(currentPage > 0) {
        [self setActivePage:currentPage-1];
    }
}

- (void)showLoadingViewOn{
    [Lib showLoadingViewOn:self.view withAlert:@"Saving image..."];
}

- (void)cropImage:(NSTimer*)theTimer {
    NSDictionary *info = theTimer.userInfo;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {

        UIImage *original = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CropImage* tView = [CropImage viewFromNib:self];
        tView.delegate = self;
        [tView receivingImage:original];
        [tView showInView:self.view];
        
    }
    [Lib removeLoadingViewOn:self.view];
}

- (void)setImageName:(NSString*)imageName forPage:(NSInteger)pid{
    Page *page = [lesson.pages objectAtIndex:pid];
    [page setImage:imageName];
    [imageView setImage:page.pageImageWithDefaultBackground];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pid inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
}

- (void)saveImageAs:(UIImage *)image {
    
    Page *page = [lesson.pages objectAtIndex:currentPage];
    NSString *currentImageName = page.image;
    
    [[undoManager prepareWithInvocationTarget:self] setImageName:currentImageName forPage:currentPage];
    [undoManager setActionName:[NSString stringWithFormat:@"Change Image of Page #%ld",(long)currentPage]];
    
    [page saveImage:image];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [lesson setModified:round([[NSDate date] timeIntervalSince1970])];
    [imageView setImage:page.pageImageWithDefaultBackground];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (IsIdiomPad) {
        if (self.popoverController) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
            
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        [NSTimer scheduledTimerWithTimeInterval: 0
                                         target: self
                                       selector: @selector(showLoadingViewOn)
                                       userInfo: nil
                                        repeats: NO];
        [NSTimer scheduledTimerWithTimeInterval: 0.5f
                                         target: self
                                       selector: @selector(cropImage:)
                                       userInfo: info
                                        repeats: NO];
    } else {
       [picker dismissViewControllerAnimated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval: 0
                                         target: self
                                       selector: @selector(showLoadingViewOn)
                                       userInfo: nil
                                        repeats: NO];
        [NSTimer scheduledTimerWithTimeInterval: 0.5f
                                         target: self
                                       selector: @selector(cropImage:)
                                       userInfo: info
                                        repeats: NO];
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) { // Take Photo

        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
		controller.delegate = self;
		controller.sourceType = UIImagePickerControllerSourceTypeCamera;
		
		// Hide camera controls (iOS 5+) until view is shown to prevent console log
		// "Snapshotting a view that has not been rendered results in an empty snapshot...
		if ( [self respondsToSelector:@selector(presentViewController:animated:completion:)] ) {
			controller.showsCameraControls = NO;
			[self presentViewController:controller animated:YES completion:^{
				controller.showsCameraControls = YES;
			}];
		}
		else { // up to iOS 5
			[self presentModalViewController:controller animated:YES];
		}
    } else if (buttonIndex == 0) { // Library
        
        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (IsIdiomPad) {
            if (self.popoverController && [self.popoverController isPopoverVisible]) {
                [self.popoverController dismissPopoverAnimated:NO];
            }
            
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:controller];                    
            self.popoverController.delegate = self;
            UIView* aView = (UIView*)uploadButton;
            [self.popoverController presentPopoverFromRect:[aView bounds]
                                                    inView:aView
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];            
            
        } else {
            [self presentModalViewController:controller animated:YES];
        }
    } else if (buttonIndex == 1) { // Gallery
        if (IsIdiomPad) {
            if (self.popoverController && [self.popoverController isPopoverVisible]) {
                [self.popoverController dismissPopoverAnimated:NO];
            }
            
            GalleryTableViewController* controller = [[GalleryTableViewController alloc] init];
            controller.delegate = self;
            controller.title = @"Gallery";
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
            UIBarButtonItem *editGalleryButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:controller action:@selector(toggleEditMode:)];
            nav.navigationBar.topItem.rightBarButtonItem = editGalleryButton;
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:nav];                    
            self.popoverController.delegate = self;
            [self.popoverController setPopoverContentSize:CGSizeMake(345, 465)];
            UIView* aView = (UIView*)uploadButton;
            [self.popoverController presentPopoverFromRect:[aView bounds] inView:aView
                                  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];            
            
        } else {

            GalleryViewController *galleryController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:nil];
            galleryController.delegate = self;
            [[self navigationController] pushViewController:galleryController animated:YES];
            
        }

    }

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (lesson)
        return [lesson.pages count];
    return 0;
}



- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setActivePage:indexPath.row];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PageCell"];
    if (!cell) {
        NSArray *bundle;
        if (IsIdiomPad) {
            bundle = [[NSBundle mainBundle] loadNibNamed:@"PageCell-iPad"
                                                            owner:self options:nil];
        } else {
            bundle = [[NSBundle mainBundle] loadNibNamed:@"PageCell-iPhone"
                                                            owner:self options:nil];
        }
        
        for (id object in bundle) {
            if ([object isKindOfClass:[PageCell class]])
                cell = (PageCell *)object;
        }   
    }
    
    Page* page = [lesson.pages objectAtIndex:indexPath.row];
    
    cell.pageNumber.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    if ([page.text isEqualToString:@""] || page.text == NULL) {
        [cell.textIndicator setImage:[UIImage imageNamed:@"ipad_icon_text_false"]];
    }
    else {
        [cell.textIndicator setImage:[UIImage imageNamed:@"ipad_icon_text_true"]];
    }
    if ([page.voice isEqualToString:@""] || page.voice == NULL) {
        [cell.soundIndicator setImage:[UIImage imageNamed:@"ipad_icon_sound_false"]];
    }
    else {
        [cell.soundIndicator setImage:[UIImage imageNamed:@"ipad_icon_sound_true"]];
    }
    
    [cell.thumbnail setImage:[page pageThumbnail]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0)  return NO;
    return YES;
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    if (sourceIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    Page* movePage = [lesson.pages objectAtIndex:sourceIndexPath.row];
    
    if (destinationIndexPath.row > [lesson.pages count]) {
        [lesson.pages addObject:movePage];
        [lesson.pages removeObjectAtIndex:sourceIndexPath.row];
    }
    else {
        [lesson.pages removeObjectAtIndex:sourceIndexPath.row];
        [lesson.pages insertObject:movePage atIndex:destinationIndexPath.row];
    }
    
    if (currentPage == sourceIndexPath.row) {
        currentPage = destinationIndexPath.row;
    }
    
    [pagesTableView reloadData];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
    [self setActivePage:currentPage];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Select the editing style of each cell
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do not allow inserts / deletes
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == 0) {
        return sourceIndexPath;     
    }
    
    return proposedDestinationIndexPath;
}



- (void) selectImage:(NSString *)imageName {
    selectedImageName = imageName;
    if (IsIdiomPad) {
        [self.popoverController dismissPopoverAnimated:YES];
        [self saveImageFromGallery];
    } else {
        [self saveImageFromGallery];
    }
}

-(IBAction)preview:(id)sender {
    PlayerController* controller;
    if (IsIdiomPad) {
        controller = [[PlayerController alloc] initWithNibName:@"PlayerController-iPad" bundle:nil];
    } else {
        controller = [[PlayerController alloc] initWithNibName:@"PlayerController-iPhone" bundle:nil];
    }
    
    controller.tale = lesson;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)saveImageFromGallery {
    
    NSString *filePath = [NSString stringWithFormat:@"%@/gallery/%@",[Lib applicationDocumentsDirectory],selectedImageName];
    UIImage *original = [UIImage imageWithContentsOfFile:filePath];
    
    CropImage* tView = [CropImage viewFromNib:self];
    tView.delegate = self;
    [tView receivingImage:original];
    [tView showInView:self.view];
//    Page *page = [tale.pages objectAtIndex:currentPage];
//    
//    NSString *currentImageName = page.image;
//    
//    [[undoManager prepareWithInvocationTarget:self] setImageName:currentImageName forPage:currentPage];
//    [undoManager setActionName:[NSString stringWithFormat:@"Change Image of Page #%d",currentPage]];
//    
//    [page saveImage:original];
//    
//    [imageView setImage:page.pageImage];
//    [pagesTableView reloadData];
//    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
//    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
//    [Lib removeLoadingViewOn:self.view];
}

-(void)drawPageSaved {
    Page *page = [lesson.pages objectAtIndex:currentPage];
    
    NSString *currentImageName = page.image;
    
    [[undoManager prepareWithInvocationTarget:self] setImageName:currentImageName forPage:currentPage];
    [undoManager setActionName:[NSString stringWithFormat:@"Change Image of Page #%ld",(long)currentPage]];
}

-(IBAction)playTeacherAudio:(id)sender {
    Page *page = [lesson.pages objectAtIndex:currentPage];
    playButton.hidden = YES;
    stopButton.hidden = NO;
    NSString *fullPathToFile = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:page.teacher_voice];
    
    NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath:fullPathToFile];

    NSError *error1;
    NSError *error2;
    NSData *songFile = [[NSData alloc] initWithContentsOfURL:soundFileURL options:NSDataReadingMappedIfSafe error:&error1 ];
    soundPlayer = [[AVAudioPlayer alloc] initWithData:songFile error:&error2];
    soundPlayer.meteringEnabled = YES;
    soundPlayer.numberOfLoops =  0;
    soundPlayer.volume = 1.0;
    soundPlayer.delegate = self;
    
    NSLog(@"%@", error1);
    NSLog(@"%@", error2);
    
    [soundPlayer play];
}

-(IBAction)stopTeacherAudio:(id)sender {
    playButton.hidden = NO;
    stopButton.hidden = YES;
    [soundPlayer stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopTeacherAudio:nil];
}

//- (void)saveTaleHistory {
//    undoButton.enabled = TRUE;
//    
//    if ([taleHistory count] == 10) {
//        [taleHistory removeObjectAtIndex:0];
//    }  
//    if ([activePageHistory count] == 10) {
//        [activePageHistory removeObjectAtIndex:0];
//    }
//    NSArray *pageList = [[NSArray alloc] initWithArray:[tale pages]];
//    [taleHistory addObject:pageList];
//    [activePageHistory addObject:[NSNumber numberWithInt:currentPage]];
//}


@end
