//
//  PlayerController.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerController.h"
#import "Sound.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation PlayerController
@synthesize tale;

-(BOOL)shouldAutorotate
{
    return NO;
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationLandscapeRight;
}


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

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewWillAppear:(BOOL)animated{
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isPause = NO;
    timeArray = [[NSMutableArray alloc] init];
    
    NSInteger totalSecond = 0;
    [timeArray addObject:[NSNumber numberWithInt:(int)totalSecond]];
    
    // Sample Data
//    [timeArray addObject:[NSNumber numberWithInt:5]];
//    [timeArray addObject:[NSNumber numberWithInt:10]];
//    [timeArray addObject:[NSNumber numberWithInt:20]];
    
    //Waiting for Page Data
    for (Page *page in tale.pages) {
        if (page.time == 0) {
            totalSecond = totalSecond + 5;
        }
        else {
            totalSecond = totalSecond + page.time;
        }
        [timeArray addObject:[NSNumber numberWithInt:(int)totalSecond]];
    }
    
    currentTime = 0;
    currentPageIndex = 0;
    
    int seconds = ([[timeArray lastObject] intValue]) % 60;
    int minutes = ( [[timeArray lastObject] intValue] - seconds) / 60;
    
    [timerSlider setValue:0];
    [timerSlider setMaximumValue:[[timeArray lastObject] intValue]];
    [timerLabel setText:[NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds]];
    
    if ([tale.pages count] > 0) {
        Page *page = [tale.pages objectAtIndex:0];
        
        [mainScreen setImage:page.pageImageWithDefaultBackground];
        
        [description setText:page.text];
    }
    // Do any additional setup after loading the view from its nib.
    
    //mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: mpVolumeViewParentView.bounds];
    [mpVolumeViewParentView addSubview: myVolumeView];
    mpVolumeViewParentView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,-M_PI/2);
    mpVolumeViewParentView.hidden = YES;
    
    titleLabel.text = tale.title;
}

- (void)resumeActivity {
    
    if (currentTime <= [[timeArray lastObject] intValue]) {
        int seconds = ([[timeArray lastObject] intValue] - currentTime) % 60;
        int minutes = (int)( [[timeArray lastObject] intValue] - currentTime - seconds) / 60;
        
        [timerLabel setText:[NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds]];
        
        [timerSlider setValue:currentTime animated:YES];
        
        if (currentPageIndex < [timeArray count]-1) {
            if (currentTime == 0) {
                currentPageIndex = 0;
                [self playTalePage:YES];
            }
            if (currentTime < [[timeArray objectAtIndex:currentPageIndex+1] intValue]) {
                [self playTalePage:YES];
                currentTime = currentTime+1;
            }
            else if (currentTime == [[timeArray objectAtIndex:currentPageIndex+1] intValue]) {
                currentPageIndex = currentPageIndex+1;
                [self playTalePage:YES];
                currentTime = currentTime+1;
            }
        }
        else {
            [myTicker invalidate];
        }
    }
    else {
        if (currentTime > [[timeArray lastObject] intValue]+1) {
            [myTicker invalidate];
            [self stopButtonClicked:nil];
        } else {
            currentTime++;
        }
        
    }
}


- (void)showActivity {
    
    if (currentTime <= [[timeArray lastObject] intValue]) {
        int seconds = ([[timeArray lastObject] intValue] - currentTime) % 60;
        int minutes = (int)( [[timeArray lastObject] intValue] - currentTime - seconds) / 60;
        
        [timerLabel setText:[NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds]];
        
        [timerSlider setValue:currentTime animated:YES];
        
        if (currentPageIndex < [timeArray count]-1) {
            if (currentTime == 0) {
                currentPageIndex = 0;
                [self playTalePage:YES];
            }
            if (currentTime < [[timeArray objectAtIndex:currentPageIndex+1] intValue]) {
                currentTime = currentTime+1;
            }
            else if (currentTime == [[timeArray objectAtIndex:currentPageIndex+1] intValue]) {
                currentPageIndex = currentPageIndex+1;
                [self playTalePage:YES];
                currentTime = currentTime+1;
            }
        }
        else {
            [myTicker invalidate];
        }
    }
    else {
        if (currentTime > [[timeArray lastObject] intValue]+1) {
            [myTicker invalidate];
            [self stopButtonClicked:nil];
        } else {
            currentTime++;
        }
        
    }
}

- (void)playTalePage:(BOOL)autoStop {
    NSInteger currentPageTime = 0;
    
    if (currentTime == 0) {
        currentPageIndex = 0;
        currentPageTime = 0;
    }
    else if (currentTime >= [[timeArray lastObject] intValue]) {
        if (currentTime > [[timeArray lastObject] intValue] && autoStop) {
            [self stopButtonClicked:nil];
        }
        
        return;
    }
    else {
        for (NSInteger i = 0; i < [timeArray count]; i++) {
            NSInteger time = [[timeArray objectAtIndex:i] intValue];
            if (time <= currentTime) {
                currentPageIndex = i;
                currentPageTime = currentTime - time;
            }
        }
    }
    
    Page *currentPage = [tale.pages objectAtIndex:currentPageIndex];
    [currentPage playPageAtSecond:currentPageTime inView:mainScreen withTextView:description withAudio:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [myTicker invalidate];
    [[Sound sharedInstance] stopAll];
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

- (IBAction)playButtonClicked:(id)sender{
    startButton.hidden = YES;
    playButton.userInteractionEnabled = NO;
    [pauseButton setImage:[UIImage imageNamed:@"ipad_btn_player_pause.png"] forState:UIControlStateNormal];
    
    //Waiting for Page Data
    [self resumeActivity];
    isPause = NO;
    myTicker = [NSTimer scheduledTimerWithTimeInterval: 1
												target: self
											  selector: @selector(showActivity)
											  userInfo: nil
											   repeats: YES];
}
- (IBAction)pauseButtonClicked:(id)sender{
    
    isPause = !isPause;
    if (isPause) {
        startButton.hidden = NO;
        [[Sound sharedInstance] stopAll];
        playButton.userInteractionEnabled = YES;
        [myTicker invalidate];
        [pauseButton setImage:[UIImage imageNamed:@"ipad_btn_player_pause_pressed.png"] forState:UIControlStateNormal];
    }
    else {
        startButton.hidden = YES;
        [pauseButton setImage:[UIImage imageNamed:@"ipad_btn_player_pause.png"] forState:UIControlStateNormal];
        [self resumeActivity];
        myTicker = [NSTimer scheduledTimerWithTimeInterval: 1
                                                    target: self
                                                  selector: @selector(showActivity)
                                                  userInfo: nil
                                                   repeats: YES];
    }
}
- (IBAction)stopButtonClicked:(id)sender{
    
    startButton.hidden = NO;
    isPause = NO;
    [pauseButton setImage:[UIImage imageNamed:@"ipad_btn_player_pause.png"] forState:UIControlStateNormal];
    playButton.userInteractionEnabled = YES;
    [myTicker invalidate];
    currentTime = 0;
    currentPageIndex = 0;
    
    
    int seconds = ([[timeArray lastObject] intValue]) % 60;
    int minutes = ( [[timeArray lastObject] intValue] - seconds) / 60;

    [timerLabel setText:[NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds]];
    [timerSlider setValue:0 animated:YES];
    
    
    Page *currentPage = [tale.pages objectAtIndex:currentPageIndex];
    [currentPage playPageAtSecond:0 inView:mainScreen withTextView:description withAudio:NO];
    [[Sound sharedInstance] stopAll];
}

- (IBAction)sliderChange:(id)sender {
    isPause = YES;
    playButton.userInteractionEnabled = YES;
    startButton.hidden = NO;
    [myTicker invalidate];
    [pauseButton setImage:[UIImage imageNamed:@"ipad_btn_player_pause_pressed.png"] forState:UIControlStateNormal];
    
    currentTime = [timerSlider value];
    int seconds = ([[timeArray lastObject] intValue] - currentTime) % 60;
    int minutes = (int)( [[timeArray lastObject] intValue] - currentTime - seconds) / 60;
    
    [timerLabel setText:[NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds]];
    currentTime = currentTime+1;
    [self playTalePage:NO];
    [[Sound sharedInstance] stopAll];
}

- (IBAction)volumeButtonClicked:(id)sender{
    mpVolumeViewParentView.hidden = !mpVolumeViewParentView.hidden;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
