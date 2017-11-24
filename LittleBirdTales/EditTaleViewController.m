//
//  EditTaleViewController.m
//  LittleBirdTales
//
//  Created by Deep Blue on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "EditTaleViewController.h"
#import "Gallery.h"


@implementation EditTaleViewController
@synthesize tale, taleNumber, popoverController;

-(BOOL)shouldAutorotate
{
    return NO;
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    if (IsIdiomPad) {
        
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{

    return UIInterfaceOrientationLandscapeRight;
}

-(IBAction)drawPage:(id)sender {
    //TODO: Check if there is a page to draw
    DrawController* controller;
    if (IsIdiomPad) {
        controller = [[DrawController alloc] initWithNibName:@"DrawController-iPad" bundle:nil];
    } else {
        controller = [[DrawController alloc] initWithNibName:@"DrawController-iPhone" bundle:nil];
    }
    Page* page = [tale.pages objectAtIndex:currentPage];
    controller.delegate = self;
    controller.page = page;
    [self.navigationController pushViewController:controller animated:YES];
}
-(IBAction)textPage:(id)sender {
    if (currentPage == 0) {
        InputTaleInfo* tView = [InputTaleInfo viewFromNib:self];
        tView.delegate = self;
        [tView.titleField setText:tale.title];
        [tView.authorField setText:tale.author];
        [tView showInView:self.view];
    }
    else {
        InputTextView* tView = [InputTextView viewFromNib:self];
        tView.delegate = self;
        Page *page = [tale.pages objectAtIndex:currentPage];
        [tView.textView setText:page.text];
        [tView showInView:self.view];
    }
}


-(void)inputedText:(NSString*)text forPage:(NSInteger)pid {
    Page *page = [tale.pages objectAtIndex:pid];

    [page setText:text];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [tale setModified:round([[NSDate date] timeIntervalSince1970])];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];

}

-(void)inputedText:(NSString*)text {
    Page *page = [tale.pages objectAtIndex:currentPage];
    NSString *currentText = page.text;
    if (text != currentText) {
        [[undoManager prepareWithInvocationTarget:self] inputedText:currentText forPage:currentPage];

        [undoManager setActionName:[NSString stringWithFormat:@"Change Text of Page #%ld",(long)currentPage]];


        [page setText:text];
        [page setModified:round([[NSDate date] timeIntervalSince1970])];
        [tale setModified:round([[NSDate date] timeIntervalSince1970])];
        [pagesTableView reloadData];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
        [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)inputedTitle:(NSString*)title author:(NSString*)author {

    NSString* currentTitle = tale.title;
    NSString* currentAuthor = tale.author;

    if (currentAuthor != author || currentTitle != title) {
        [[undoManager prepareWithInvocationTarget:self] inputedTitle:currentTitle author:currentAuthor];

        if (![undoManager isUndoing]) {
            [undoManager setActionName:NSLocalizedString(@"Change Tale Info", @"Change Tale Info")];
        }
        [tale setTitle:title];
        [tale setAuthor:author];
        [tale setModified:round([[NSDate date] timeIntervalSince1970])];
        Page *cover = [[tale pages] objectAtIndex:0];
        cover.text = title;
        titleLabel.text = title;
    }



};

- (void)setVoice:(NSString *)voiceName andDuration:(double)duration forPage:(NSInteger)pid{
    Page *page = [tale.pages objectAtIndex:pid];
    [page setVoice:voiceName];
    [page setTime:duration + 1];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [tale setModified:round([[NSDate date] timeIntervalSince1970])];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pid inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:pid];
}

- (void)setVoice:(NSString *)voiceName andDuration:(double)duration{
    Page *page = [tale.pages objectAtIndex:currentPage];
    NSString *currentVoiceName = page.voice;
    double currentDuration = page.time;
    if (voiceName != currentVoiceName) {
        [[undoManager prepareWithInvocationTarget:self] setVoice:currentVoiceName andDuration:currentDuration forPage:currentPage];
        [undoManager setActionName:[NSString stringWithFormat:@"Change Voice of Page #%ld",(long)currentPage]];


        [page setVoice:voiceName];
        [page setTime:duration + 1];
        [page setModified:round([[NSDate date] timeIntervalSince1970])];
        [tale setModified:round([[NSDate date] timeIntervalSince1970])];
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
                          otherButtonTitles:@"From Gallery", @"Take Photo", nil];
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
    Page* page = [tale.pages objectAtIndex:currentPage];
    tView.delegate = self;
    tView.pageFolder = page.pageFolder;
    tView.voiceName = page.voice;
    tView.pageText = page.text;
    [tView showInView:self.view];
}
-(IBAction)deletePage:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Tales"
                                                        message:@"Delete this page?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.tag = 101;
    [alertView show];
}

-(void)addPage:(Page*)page atIndex:(NSInteger)index {
    [tale.pages insertObject:page atIndex:index];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:index];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {

            Page* page = [tale.pages objectAtIndex:currentPage];

            //Undo
            [[undoManager prepareWithInvocationTarget:self] addPage:page atIndex:currentPage];
            [undoManager setActionName:[NSString stringWithFormat:@"Delete Page #%ld",(long)currentPage]];

            [tale.pages removeObjectAtIndex:currentPage];
            [tale setModified:round([[NSDate date] timeIntervalSince1970])];
            [pagesTableView reloadData];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage-1 inSection:0];
            [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
            [self setActivePage:currentPage-1];
        }
    }
    else if (alertView.tag == 102) {
        [undoManager undo];
    } else if (alertView.tag == 3491832) {
        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
        if (canOpenSettings)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)deleteLastPageFromPage:(NSInteger)pid {
    [tale.pages removeLastObject];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pid inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:pid];
}

-(IBAction)newPage:(id)sender {

    Page *samplePage = [Page newPage];
    samplePage.pageFolder = [NSString stringWithFormat:@"%@/%0.f",[Lib taleFolderPathFromIndex:tale.index],samplePage.index];
    [tale.pages addObject:samplePage];

    [[undoManager prepareWithInvocationTarget:self] deleteLastPageFromPage:currentPage];
    [undoManager setActionName:[NSString stringWithFormat:@"Add New Page"]];

    [pagesTableView reloadData];
    [tale setModified:round([[NSDate date] timeIntervalSince1970])];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[tale.pages count]-1 inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self setActivePage:[tale.pages count]-1];
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
    if (index == 0) {
        [editButton setImage:[UIImage imageNamed:@"btn-edittale-ipad.png"] forState:UIControlStateNormal];
        deleteButton.hidden = YES;
    }
    else {
        [editButton setImage:[UIImage imageNamed:@"btn-edit-ipad.png"] forState:UIControlStateNormal];
        deleteButton.hidden = NO;
    }

    currentPage = index;
    Page *page = [tale.pages objectAtIndex:currentPage];
    [imageView setImage:[page pageImageWithDefaultBackground]];
}
#pragma mark - View lifecycle

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad {
    [super viewDidLoad];

    //Undo Manager
    undoManager = [[NSUndoManager alloc] init];
    [undoManager setLevelsOfUndo:5];

    taleHistory = [[NSMutableArray alloc] init];
    activePageHistory = [[NSMutableArray alloc] init];

    // Do any additional setup after loading the view from its nib.
    if (tale == nil) {
        tale = [[Tale alloc] init];

        NSMutableArray *pageArray = [[NSMutableArray alloc] init];

        Page *samplePage = [[Page alloc] init];
        samplePage.image = @"";
        samplePage.voice = @"";
        samplePage.text = @"";
        samplePage.index = 1;
        samplePage.order = 1;

        [pageArray addObject:samplePage];

        tale.pages = pageArray;
    }

    titleLabel.text = tale.title;

    pagesTableView.editing = YES;
    pagesTableView.allowsSelectionDuringEditing = YES;

    [self setActivePage:0];

}

- (void)viewWillAppear:(BOOL)animated {
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    Page *page = [tale.pages objectAtIndex:currentPage];
    [pagesTableView reloadData];
    [imageView setImage:[page pageImageWithDefaultBackground]];

    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionTop];

    // work-around for status bar hiding when using an ImagePicker
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // work-around for status bar hiding when using an ImagePicker
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    [tale deleteOrphanFiles];
    [Tale updateTale:tale at:taleNumber];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)appEnteredBackground:(NSNotification *)appEnteredBackgroundNotification {
    
    //do your thing
    [tale deleteOrphanFiles];
    [Tale updateTale:tale at:taleNumber];
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
    Page *page = [tale.pages objectAtIndex:pid];
    [page setImage:imageName];
    [imageView setImage:page.pageImageWithDefaultBackground];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pid inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
}

- (void)saveImageAs:(UIImage *)image {

    Page *page = [tale.pages objectAtIndex:currentPage];
    NSString *currentImageName = page.image;

    [[undoManager prepareWithInvocationTarget:self] setImageName:currentImageName forPage:currentPage];
    [undoManager setActionName:[NSString stringWithFormat:@"Change Image of Page #%ld",(long)currentPage]];

    [page saveImage:image];
    [page setModified:round([[NSDate date] timeIntervalSince1970])];
    [tale setModified:round([[NSDate date] timeIntervalSince1970])];
    [imageView setImage:page.pageImageWithDefaultBackground];
    [pagesTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentPage inSection:0];
    [pagesTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];

    if (buttonAction == 2) {
        // Save image to camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [picker dismissViewControllerAnimated:true completion:nil];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self:buttonAction = buttonIndex;
    
    if (buttonIndex == 2 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self goToCamera];
    } else if (buttonIndex == 0) { // Library

        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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

//            GalleryViewController *galleryController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:nil];
//            galleryController.delegate = self;
//            [[self navigationController] pushViewController:galleryController animated:YES];

            
            [self presentViewController:controller animated:YES completion:nil];
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
            UIBarButtonItem *editGalleryButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:controller action:@selector(toggleEditMode:)];
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

- (IBAction)goToCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        [self popCamera];
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");

        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 NSLog(@"Granted access to %@", AVMediaTypeVideo);
                 [self popCamera];
             }
             else
             {
                 NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                 [self camDenied];
             }
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        // My own Helper class is used here to pop a dialog in one simple line.
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:nil];
    }
    else
    {
        [self camDenied];
    }
}

-(void)popCamera {
    BOOL hasLoadedCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];

    if (!hasLoadedCamera)
        [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
    else
//        [self showcamera];
        [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];

        }

- (void)showcamera {
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    imagePickerController.delegate = self;
//    imagePickerController.showsCameraControls = YES;
//
//    [self presentViewController:imagePickerController animated:YES completion:nil];

    UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.delegate = self;
    cameraController.sourceType = source;
    cameraController.allowsEditing = YES;
    [self presentViewController:cameraController animated:YES completion:^{
        //iOS 8 bug.  the status bar will sometimes not be hidden after the camera is displayed, which causes the preview after an image is captured to be black
        if (source == UIImagePickerControllerSourceTypeCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
    }];
}

- (void)camDenied
{
    NSLog(@"%@", @"Denied camera access");

    NSString *alertText;
    NSString *alertButton;

    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings)
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to take a picture. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again.";

        alertButton = @"Go";
    }
    else
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to take a picture. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Touch Privacy.\n\n5. Turn the Camera on.\n\n6. Open this app and try again.";

        alertButton = @"OK";
    }

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:alertText
                          delegate:self
                          cancelButtonTitle:alertButton
                          otherButtonTitles:nil];
    alert.tag = 3491832;
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tale)
        return [tale.pages count];
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

    Page* page = [tale.pages objectAtIndex:indexPath.row];

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

    Page* movePage = [tale.pages objectAtIndex:sourceIndexPath.row];

    if (destinationIndexPath.row > [tale.pages count]) {
        [tale.pages addObject:movePage];
        [tale.pages removeObjectAtIndex:sourceIndexPath.row];
    }
    else {
        [tale.pages removeObjectAtIndex:sourceIndexPath.row];
        [tale.pages insertObject:movePage atIndex:destinationIndexPath.row];
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

    controller.tale = tale;

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)saveImageFromGallery {

    NSString *filePath = [NSString stringWithFormat:@"%@%@",[Gallery dir],selectedImageName];

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
    Page *page = [tale.pages objectAtIndex:currentPage];

    NSString *currentImageName = page.image;

    [[undoManager prepareWithInvocationTarget:self] setImageName:currentImageName forPage:currentPage];
    [undoManager setActionName:[NSString stringWithFormat:@"Change Image of Page #%ld",(long)currentPage]];
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
