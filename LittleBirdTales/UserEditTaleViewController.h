//
//  EditTaleViewController.h
//  LittleBirdTales
//
//  Created by Deep Blue on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tale.h"
#import "Page.h"
#import "DrawEditorController.h"
#import "PageCell.h"
#import "UserInputTextView.h"
#import "UserInputTaleInfo.h"
#import "Lib.h"
#import "UIImage+Resize.h"
#import "AudioRecord.h"
#import "GalleryTableViewController.h"
#import "GalleryViewController.h"
#import "CropImage.h"
#import "PlayerController.h"

@interface UserEditTaleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InputTextViewDelegate, InputTaleInfoDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, AudioRecordDelegate, GalleryDelegate, CropImageDelegate,DrawControllerDelegate, GalleryViewDelegate > {
    IBOutlet UITableView* pagesTableView;
    IBOutlet UIImageView* imageView;
    IBOutlet UIButton *uploadButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *undoButton;
    IBOutlet UIButton *editButton;
    IBOutlet UILabel *titleLabel;
    
    NSUndoManager *undoManager;
    
    NSString *selectedImageName;
    NSInteger currentPage;
    
    NSMutableArray *taleHistory;
    NSMutableArray *activePageHistory;
}
@property (nonatomic, retain) Tale* tale;
@property (nonatomic, assign) NSInteger taleNumber;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) UIImagePickerController *imagePickerController;

-(IBAction)drawPage:(id)sender;
-(IBAction)textPage:(id)sender;
-(IBAction)uploadPage:(id)sender;
-(IBAction)soundPage:(id)sender;
-(IBAction)deletePage:(id)sender;
-(IBAction)newPage:(id)sender;
-(IBAction)undo:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)preview:(id)sender;
- (void)setActivePage:(NSInteger)index;
- (void)saveImageFromGallery;
//- (void)saveTaleHistory;

@end
