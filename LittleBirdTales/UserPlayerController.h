//
//  PlayerController.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tale.h"
#import "Page.h"
#import "Lib.h"

@interface UserPlayerController : UIViewController{
    IBOutlet UIImageView *mainScreen;
    IBOutlet UITextView *description;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *pauseButton;
    IBOutlet UIButton *stopButton;
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *volumeButton;
    IBOutlet UISlider *timerSlider;
    IBOutlet UILabel *timerLabel;
    
    IBOutlet UIView *mpVolumeViewParentView;
    
    BOOL isPause;
    BOOL shouldPlayAudio;
    NSInteger currentTime;
    NSInteger currentPageIndex;
    NSMutableArray *timeArray;
    NSTimer *myTicker;
    Tale *tale;
    NSMutableArray *pageList;
    IBOutlet UILabel *titleLabel;
}

@property (nonatomic, retain) Tale *tale;


- (IBAction)playButtonClicked:(id)sender;
- (IBAction)pauseButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)sliderChange:(id)sender;
- (IBAction)back:(id)sender;
- (void) playTalePage:(BOOL)autoStop;

@end