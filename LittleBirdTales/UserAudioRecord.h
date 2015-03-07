//
//  AudioRecord.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Lib.h"
#import "Sound.h"
#import "Page.h"
#import "OCProgress.h"
#import "RecordButton.h"

@protocol AudioRecordDelegate 
@required 
-(void)setVoice:(NSString*)voiceName andDuration:(double)duration;
@end


@interface UserAudioRecord : UIView <AVAudioPlayerDelegate>{
    BOOL isRecording;
    AVAudioRecorder *soundRecorder;
    AVAudioPlayer *soundPlayer;
    NSString *recordName;
    double duration;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *stopButton;
    IBOutlet RecordButton *recordButton;
    IBOutlet UIButton *cancelButton;
    OCProgress *progressBar;

    NSTimer *levelTimer;
    UISlider *volumeMeter;
    BOOL hasRecorded;
    BOOL playOnly;
}

@property (nonatomic, assign) id <AudioRecordDelegate> delegate;
@property (nonatomic, strong) NSString *voiceName;
@property (nonatomic, strong) NSString *pageFolder;
@property (nonatomic, strong) NSString *pageText;
@property BOOL playOnly;

+(UserAudioRecord*)viewFromNib:(id)owner;
-(void)showInView:(UIView*)aView;
-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)record:(id)sender;
-(IBAction)play:(id)sender;
-(IBAction)stop:(id)sender;
@end
