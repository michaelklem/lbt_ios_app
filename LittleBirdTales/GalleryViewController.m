//
//  GalleryViewController.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "Lib.h"

@implementation GalleryViewController
@synthesize delegate;

#define NO_IMAGE_ALERT 99999

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    editMode = false;
    galleryPath = [NSString stringWithFormat:@"%@/gallery",[Lib applicationDocumentsDirectory]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList = [fm contentsOfDirectoryAtPath:galleryPath error:nil];
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg_iphone.jpg'"];
    imageList = [[NSMutableArray alloc] initWithArray:[fileList filteredArrayUsingPredicate:fltr]];
    
    if (imageList.count == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Tale"
                                                            message:@"You currently have no images saved in your gallery. You can save images you create with our art pad in the gallery so they can be used in other stories." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        alertView.tag = NO_IMAGE_ALERT;
        [alertView show];
    } else {
        [self displayThumbnail];
    }
}

- (void)displayThumbnail {
    
    NSInteger  count = (([imageList count] + 5) / 6);
    [scrollView setContentSize:CGSizeMake(480, count*80+5)];
    for(UIView *subview in [scrollView subviews]) {
        [subview removeFromSuperview];
    }
    for (NSInteger row = 0; row< count; row++) {
        for (NSInteger index = row * 6;index < MIN((row +1)*6, [imageList count]); index++) {
            NSInteger column = (index - row*6);
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((column * 80) + 2, (row * 80) + 5, 75, 75)];
            [button setImage:[self getThumbnailAtIndex:index] forState:UIControlStateNormal];
            button.tag = index + 10000;
            [button addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
            if (editMode) {
                button.alpha = 0.4f;
            }
            [scrollView addSubview:button];
        }
    }
}

- (UIImage*) getThumbnailAtIndex:(NSInteger)index{
    NSString *imageName = [imageList objectAtIndex:index];
    NSString *filePath = [NSString stringWithFormat:@"%@/gallery/%@",[Lib applicationDocumentsDirectory],imageName];
    UIImage *thumbnail = [UIImage imageWithContentsOfFile:filePath];
    return thumbnail;
}

- (void)selectImage:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag - 10000;
    
    if (editMode) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Little Bird Tale" message:@"Delete this image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag =  tag;
        [alert show];
    }
    else {
        if (delegate) {
            NSString *imageName = [imageList objectAtIndex:tag];
            imageName = [imageName stringByReplacingOccurrencesOfString:@".jpg_iphone.jpg" withString:@".jpg"];
            [delegate selectImage:imageName];
        }
        [self.navigationController popViewControllerAnimated:YES];

    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == NO_IMAGE_ALERT) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if (buttonIndex == 0) {
            return;
        } else {
            NSInteger tag = alertView.tag;
            NSString *imageName = [imageList objectAtIndex:tag];
            
            NSString *path = [NSString stringWithFormat:@"%@/gallery/%@", [Lib applicationDocumentsDirectory],imageName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
            imageName = [imageName stringByReplacingOccurrencesOfString:@".jpg_iphone.jpg" withString:@".jpg"];
            path = [NSString stringWithFormat:@"%@/gallery/%@", [Lib applicationDocumentsDirectory],imageName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@.jpg",path] error:NULL];
            }
            [imageList removeObjectAtIndex:tag];
            [self displayThumbnail];
        }
    }
}

- (IBAction)toggleEditMode:(id)sender {
    editMode = !editMode;
    if (editMode) {
        [Lib showNotificationOn:self.view withText:@"Click an image to delete it."];
        [editButton setImage:[UIImage imageNamed:@"ipad_btn_done.png"] forState:UIControlStateNormal];
    } else {
        [editButton setImage:[UIImage imageNamed:@"ipad_btn_edit.png"] forState:UIControlStateNormal];
    }
    
    [self displayThumbnail];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
