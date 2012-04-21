//
//  Sound.h
//  SysSound
//
//  Created by Nguyen Hoang Tuan on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Sound : NSObject <AVAudioPlayerDelegate>{
	NSMutableDictionary *dictPlayer_;
}

@property(nonatomic,retain) NSMutableDictionary *dictPlayer_;

+ (Sound*)sharedInstance;
- (void)playMusic : (NSString*)musicName withExtension : (NSString*)musicExtension fromSecond:(NSInteger)second withLoop:(BOOL)isLoop;
- (void)playVoice : (NSString*)voiceName fromSecond:(NSInteger)second;
- (void)playVoice : (NSString*)voiceName;
- (void)stopMusic : (NSString*)musicName;
- (void)stopAll;
@end
