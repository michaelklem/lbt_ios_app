//
//  EditTaleViewController.h
//  LittleBirdTales
//
//  Created by Deep Blue on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Lesson.h"
#import "Page.h"
#import "DrawEditorController.h"
#import "PageCell.h"
#import "InputTextView.h"
#import "InputTaleInfo.h"
#import "Lib.h"
#import "UIImage+Resize.h"
#import "UserAudioRecord.h"
#import "GalleryTableViewController.h"
#import "GalleryViewController.h"
#import "CropImage.h"
#import "PlayerController.h"

@interface EditAssignmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InputTextViewDelegate, InputTaleInfoDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, AudioRecordDelegate, GalleryDelegate, CropImageDelegate,DrawControllerDelegate, GalleryViewDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate > {
    
    IBOutlet UITableView* pagesTableView;
    IBOutlet UIImageView* imageView;
    IBOutlet UITextView* teacherTextView;
    IBOutlet UITextView* studentTextView;
    IBOutlet UIButton *uploadButton;
    IBOutlet UIButton *imageButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *undoButton;
    IBOutlet UIButton *editButton;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *stopButton;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *pageNumberView;
    
    IBOutlet UIScrollView *pagesScrollView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    NSUndoManager *undoManager;
    
    NSString *selectedImageName;
    NSInteger currentPage;
    NSInteger lastPageIndex;
    
    NSMutableArray *taleHistory;
    NSMutableArray *activePageHistory;
    
    AVAudioPlayer *soundPlayer;
    
}
@property (nonatomic, retain) Lesson* lesson;
@property (nonatomic, assign) NSInteger taleNumber;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, retain) AVAudioPlayer *soundPlayer;

-(IBAction)drawPage:(id)sender;
-(IBAction)textPage:(id)sender;
-(IBAction)uploadPage:(id)sender;
-(IBAction)soundPage:(id)sender;
-(IBAction)deletePage:(id)sender;
-(IBAction)newPage:(id)sender;
-(IBAction)undo:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)preview:(id)sender;
-(IBAction)playTeacherAudio:(id)sender;
-(IBAction)stopTeacherAudio:(id)sender;
-(IBAction)saveText:(id)sender;
- (void)setActivePage:(NSInteger)index;
- (void)saveImageFromGallery;
//- (void)saveTaleHistory;

@end
