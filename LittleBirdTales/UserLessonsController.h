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

@interface UserLessonsController : UIViewController <InputTaleInfoDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate> {
    Lesson *currentLesson;
    NSInteger lastLessonIndex;
    NSInteger currentLessonIndex;
    IBOutlet UISegmentedControl *controlTab;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;

- (IBAction)leftSideMenuButtonPressed:(id)sender;
- (void)reloadLessonList;
- (void)selectTale:(id)sender;
- (void)menuOptions:(id)sender;
@end
