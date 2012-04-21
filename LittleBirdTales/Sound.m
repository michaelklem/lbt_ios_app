//
//  Sound.m
//  SysSound
//
//  Created by Nguyen Hoang Tuan on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sound.h"
#import <AVFoundation/AVFoundation.h>
#import "Lib.h"

@implementation Sound
@synthesize dictPlayer_;

static id instance = nil;

+ (Sound*)sharedInstance 
{
	if (nil == instance) 
		instance = [[Sound alloc] init];
	
	return instance;
}

- (id)init 
{
	if (self = [super init]) 
	{
		dictPlayer_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

// With loop
- (void)playMusic : (NSString*)musicName withExtension : (NSString*)musicExtension fromSecond:(NSInteger)second withLoop:(BOOL)isLoop {
	AVAudioPlayer *oldPlayer_ = [dictPlayer_ objectForKey:musicName];
	if (oldPlayer_) {
		return;
	}
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:musicName  ofType:musicExtension];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
	// play
	newPlayer.numberOfLoops = (isLoop) ? -1 : 0;
    
    newPlayer.currentTime = (NSTimeInterval) second;
    newPlayer.volume = 1.0;
	newPlayer.delegate = self;
    [newPlayer play];
	[dictPlayer_ setObject:newPlayer forKey:musicName];
	
}
- (void)playVoice : (NSString*)voiceName fromSecond:(NSInteger)second{

	NSString *soundFilePath = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:voiceName];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
	// play
	newPlayer.numberOfLoops =  0;
    newPlayer.currentTime = (NSTimeInterval) second;
    newPlayer.volume = 1.0;
	newPlayer.delegate = self;
    [newPlayer play];
	[dictPlayer_ setObject:newPlayer forKey:voiceName];
	
}

- (void)playVoice : (NSString*)voiceName{
	AVAudioPlayer *oldPlayer_ = [dictPlayer_ objectForKey:voiceName];
	if (oldPlayer_) {
		return;
	}
	NSString *soundFilePath = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:voiceName];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
	// play
	newPlayer.numberOfLoops =  0;
    newPlayer.volume = 1.0;
	newPlayer.delegate = self;
    [newPlayer play];
	[dictPlayer_ setObject:newPlayer forKey:voiceName];
	
}

- (void)stopMusic : (NSString*)musicName {
	AVAudioPlayer *oldPlayer_ = [dictPlayer_ objectForKey:musicName];
	if (oldPlayer_) {
		[oldPlayer_ stop];
		[dictPlayer_ removeObjectForKey:musicName];
	}
}

- (void)stopAll {
    for (NSString *key in dictPlayer_) {
        AVAudioPlayer *player = [dictPlayer_ objectForKey:key];
        if (player) {
            [player stop];
        }
    }
    [dictPlayer_ removeAllObjects];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	NSArray *tempKeys = [dictPlayer_ allKeysForObject:player];
	for (NSString *key_ in tempKeys) {
		[dictPlayer_ removeObjectForKey:key_];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishPlaybackVoice" object:nil];
}


@end
