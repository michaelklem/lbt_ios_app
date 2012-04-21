//
//  GalleryViewController.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GalleryViewDelegate 
@required 
-(void)selectImage:(NSString*)imageName;
@end

@interface GalleryViewController : UIViewController <UIAlertViewDelegate> {
    NSMutableArray *imageList;
    NSString *galleryPath;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *editButton;
    BOOL editMode;
}

@property (nonatomic, retain) id <GalleryViewDelegate> delegate;

- (void)displayThumbnail;
- (UIImage*) getThumbnailAtIndex:(NSInteger)index;
- (IBAction)back:(id)sender;
- (IBAction)toggleEditMode:(id)sender;
@end