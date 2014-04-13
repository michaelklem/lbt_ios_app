//
//  GalleryTableViewController.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryTableViewController.h"
#import "Lib.h"

@implementation GalleryTableViewController
@synthesize delegate;

#define NO_IMAGE_ALERT 99999

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad
{
    [super viewDidLoad];

    galleryPath = [NSString stringWithFormat:@"%@/gallery",[Lib applicationDocumentsDirectory]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList = [fm contentsOfDirectoryAtPath:galleryPath error:nil];
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg.jpg'"];
    imageList = [[NSMutableArray alloc] initWithArray:[fileList filteredArrayUsingPredicate:fltr]];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if (imageList.count == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Little Bird Tale"
                                                            message:@"You currently have no images saved in your gallery. You can save images you create with our art pad in the gallery so they can be used in other stories." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        alertView.tag = NO_IMAGE_ALERT;
        [alertView show];
    }

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([imageList count]) {
        int count = (([imageList count]+3) / 4);
        return count;
    }
    
    else {
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GalleryCell"];
    if (!cell) {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"GalleryCell"
                                                        owner:self options:nil];
        for (id object in bundle) {
            if ([object isKindOfClass:[GalleryCell class]])
                cell = (GalleryCell *)object;
        }   
    }
    
    for (int i = indexPath.row * 4;i < MIN((indexPath.row +1)*4, [imageList count]); i++) {
        [cell setThumbnail:[imageList objectAtIndex:i] editMode:editMode];
    }
    cell.delegate = self;
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    } else {
       
        NSString *path = [NSString stringWithFormat:@"%@/gallery/%@", [Lib applicationDocumentsDirectory],selectImage];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@.jpg",path] error:NULL];
        }
        NSString* imageName = [selectImage stringByReplacingOccurrencesOfString:@".jpg" withString:@".jpg_iphone.jpg"];
        path = [NSString stringWithFormat:@"%@/gallery/%@", [Lib applicationDocumentsDirectory],imageName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@.jpg",path] error:NULL];
        }
        [imageList removeObject:[NSString stringWithFormat:@"%@.jpg",selectImage]];
        [self.tableView reloadData];
    }
}

- (IBAction)toggleEditMode:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    editMode = !editMode;
    if (editMode) {
        [Lib showNotificationOn:self.view withText:@"Click an image to delete it."];
        [button setStyle:UIBarButtonItemStyleDone];
        [button setTitle:@"Done"];
    } else {
        [button setStyle:UIBarButtonItemStyleBordered];
        [button setTitle:@"Edit"];
    }
    
    [self.tableView reloadData];
}

- (void)selectImage:(NSString *)imageName {
    selectImage = imageName;
    if (editMode) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Little Bird Tale" message:@"Delete this image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else {
        if (delegate) {
            [delegate selectImage:imageName];
        }
    }
    
}
@end
