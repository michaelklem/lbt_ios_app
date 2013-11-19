//
//  GalleryTableViewController.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryCell.h"
@protocol GalleryDelegate 
@required 
-(void)selectImage:(NSString*)imageName;
@end

@interface GalleryTableViewController : UITableViewController <GalleryCellDelegate, UIAlertViewDelegate>{
    NSMutableArray *imageList;
    NSString *galleryPath;
    NSString *selectImage;
    BOOL editMode;
}

@property (nonatomic, retain) id <GalleryDelegate> delegate;
- (IBAction)toggleEditMode:(id)sender;
@end
