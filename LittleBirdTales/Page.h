//
//  Page.h
//  LittleBirdTales
//
//  Created by Mac on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lib.h"

@interface Page : NSObject
@property (nonatomic, assign) double index;
@property (nonatomic, retain) NSString* pageId;
@property (nonatomic, retain) NSString* pageFolder;
// http:// with image from server and file:// with image saved in iPad
@property (nonatomic, retain) NSString* image;
@property (nonatomic, retain) NSString* voice;
@property (nonatomic, retain) NSString* teacher_text;
@property (nonatomic, retain) NSString* teacher_voice;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) NSInteger teacher_time;
@property (nonatomic, assign) double created; // time interval since 1970
@property (nonatomic, assign) double modified; // time interval since 1970
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) BOOL isCover;
@property (nonatomic, assign) BOOL image_locked;
@property (nonatomic, assign) BOOL audio_locked;
@property (nonatomic, assign) BOOL text_locked;


+ (Page*)newPage;
+ (Page*)newCover;

- (void) playPageAtSecond: (NSInteger)second inView: (UIImageView*)imageView withTextView: (UITextView*)textView withAudio:(BOOL)isAudio;
- (void)uploadPageWithUser: (NSString*)userid userPath: (NSString*)userPath taleId:(NSString*)taleId storyId:(NSString*)storyId pageNumber:(NSString*)pageNumber uid:(NSString*)uid;
- (void)uploadLessonPageWithUser: (NSString*)userid userPath: (NSString*)userPath taleId:(NSString*)taleId storyId:(NSString*)storyId pageNumber:(NSString*)pageNumber uid:(NSString*)uid;
- (void)deleteImage;
- (void)deleteVoice;

- (BOOL)deletePageOrphanFile;

- (UIImage*)pageImage;
- (UIImage*)pageThumbnail;
- (UIImage*)pageImageWithDefaultBackground;
- (NSString*)pageVoicePath;
- (NSString*)pageImagePath;
- (void)saveImage:(UIImage*)original;
- (void)saveAudio:(NSData*)original;
- (void)saveTeacherAudio:(NSData*)original;

@end
