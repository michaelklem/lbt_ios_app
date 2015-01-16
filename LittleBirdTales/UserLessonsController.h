//
//  TalesController.h
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Lesson.h"
#import "InputTaleInfo.h"

@interface UserLessonsController : UIViewController <InputTaleInfoDelegate, UIAlertViewDelegate> {
    IBOutlet UIView* taleInfoView;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* authorLabel;
    IBOutlet UILabel* pageLabel;
    IBOutlet UILabel* createdLabel;
    IBOutlet UILabel* modifiedLabel;
    IBOutlet UIButton* newButton;
    IBOutlet UIImageView* previewImage;
    IBOutlet UIScrollView* lessonsScrollView;
    IBOutlet UIImageView *noTaleBackground;
    Lesson *currentLesson;
    NSInteger lastLessonIndex;
    NSInteger currentLessonIndex;
    IBOutlet UISegmentedControl *controlTab;
    IBOutlet UIActivityIndicatorView *activityIndicator;    
}

- (void)reloadLessonList;
- (void)selectTale:(id)sender;
- (IBAction)newTale:(id)sender;
- (IBAction)editTale:(id)sender;
- (IBAction)uploadTale:(id)sender;
- (IBAction)deleteTale:(id)sender;
- (IBAction)playTale:(id)sender;
- (IBAction)downloadTales:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)tabChange:(id)sender;
@end
