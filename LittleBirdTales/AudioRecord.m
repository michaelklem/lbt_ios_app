//
//  AudioRecord.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioRecord.h"
#import <AudioToolbox/AudioServices.h>

@implementation AudioRecord
@synthesize delegate, voiceName, pageFolder, pageText;

+(AudioRecord*)viewFromNib:(id)owner {
    NSString* nibName = @"AudioRecord-iPhone";
    if (IsIdiomPad) {
        nibName = @"AudioRecord-iPad";
    }
    
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:nibName
                                                    owner:owner options:nil];
    for (id object in bundle) {
        if ([object isKindOfClass:[AudioRecord class]]) {
            return object;
        }
    }   
    return nil;
}

-(void)showInView:(UIView*)aView {
    
    
    hasRecorded = NO;

    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];

    // Make the default sound route for the session be to use the speaker.
    // This resolves the issue where the recorded audio is too low.
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);

    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [playButton setEnabled:NO];
    [stopButton setEnabled:NO];
    [saveButton setEnabled:NO];
    
    NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithFloat: 8000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
    NSString *folderPath;
    
    if (![voiceName isEqualToString:@""] && voiceName != NULL) {
        
        
        [playButton setEnabled:YES];
        [stopButton setEnabled:YES];
        [saveButton setEnabled:NO];
        [cancelButton setEnabled:YES];
    }
    
    double number = round([[NSDate date] timeIntervalSince1970]);
    
    folderPath = [NSString stringWithFormat:@"%@/%@/voices/",
                  [Lib applicationDocumentsDirectory],pageFolder];
    recordName = [NSString stringWithFormat:@"/%@/voices/%.0f.caf",
                  pageFolder,number];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]; 
    }
    
    // Find the path to the documents directory
    
    NSString *fullPathToFile = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:recordName];
    
    NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath: fullPathToFile];

    
    soundRecorder =[[AVAudioRecorder alloc] initWithURL: soundFileURL settings: recordSettings error: nil];
    
    
    soundRecorder.meteringEnabled = YES;
    
    
    CGRect frame = self.frame;
    frame.origin.x = frame.origin.y = 0.0;
    self.frame = frame;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop:) name:@"FinishPlaybackVoice" object:nil];
    
    if (IsIdiomPad) {
        progressBar = [[OCProgress alloc] initWithFrame:CGRectMake(330, 208, 364, 30)];
    }
    else {
        progressBar = [[OCProgress alloc] initWithFrame:CGRectMake(150, 150, 180, 20)];
    }
    
    if (IsIdiomPad) {
        UITextView *pageTextLabel = [[UITextView alloc] initWithFrame:CGRectMake(170, 238, 684, 90)];
        [pageTextLabel setTextColor:[UIColor blackColor]];
        [pageTextLabel setBackgroundColor:[UIColor whiteColor]];
        [pageTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 18.0f]];
        [pageTextLabel setText: pageText];
        [[pageTextLabel layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[pageTextLabel layer] setBorderWidth:1];
        [self addSubview:pageTextLabel];
    }
    
    [progressBar setMinValue:0];
    [progressBar setMaxValue:36];
    [progressBar setProgressColor:UIColorFromRGB(0xfb7720)];
    [progressBar setProgressRemainingColor:[UIColor whiteColor]];
    [self addSubview:progressBar];
    
    [aView addSubview:self];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isRecording = NO;
    }
    return self;
}

-(IBAction)save:(id)sender {
    if (![recordName isEqualToString:@""] && recordName != NULL) {
        if (self.delegate) {
            [self.delegate setVoice:recordName andDuration:duration];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishPlaybackVoice" object:nil];
    
    [self removeFromSuperview];
}
-(IBAction)cancel:(id)sender {
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishPlaybackVoice" object:nil];
}
-(IBAction)record:(id)sender {
    hasRecorded = YES;
    if (!isRecording) {
        [soundRecorder prepareToRecord];
        isRecording = YES;
        [recordButton startAnimation];
        [playButton setEnabled:NO];
        [stopButton setEnabled:YES];
        [saveButton setEnabled:NO];
        [cancelButton setEnabled:NO];
        [soundRecorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    else {
        [self stop:NULL];
    }
}
-(IBAction)play:(id)sender {
    isRecording = NO;
    
    [playButton setEnabled:NO];
    [stopButton setEnabled:YES];
    [recordButton setEnabled:NO];
    [saveButton setEnabled:hasRecorded];
    [cancelButton setEnabled:NO];
    NSString *fullPathToFile = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:voiceName];
    
    NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath:fullPathToFile];
    
    soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    soundPlayer.meteringEnabled = YES;
    soundPlayer.numberOfLoops =  0;
    soundPlayer.volume = 1.0;
    soundPlayer.delegate = self;
    
    [soundPlayer play];
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}
-(IBAction)stop:(id)sender {
    [playButton setEnabled:YES];
    [stopButton setEnabled:YES];
    [saveButton setEnabled:hasRecorded];
    [cancelButton setEnabled:YES];
    [recordButton setEnabled:YES];
    
    [progressBar setCurrentValue:0];
    
    if (isRecording) {
        isRecording = NO;
        duration = [soundRecorder currentTime];
        [recordButton stopAnimation];
        [soundRecorder stop];
        
        voiceName = recordName;
        
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
    } else {
        [playButton setEnabled:YES];
        [recordButton setEnabled:YES];
        [soundPlayer stop];
    }
    [levelTimer invalidate];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	float level;
    if (isRecording) {
        [soundRecorder updateMeters];
        level = [soundRecorder averagePowerForChannel:0] + 35;
    } else {
        [soundPlayer updateMeters];
        level = [soundPlayer averagePowerForChannel:0] + 35;
    }
    
    //NSLog(@"%f",level);
    [progressBar setCurrentValue:level];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stop:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
