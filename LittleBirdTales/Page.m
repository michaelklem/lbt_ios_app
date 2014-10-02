//
//  Page.m
//  LittleBirdTales
//
//  Created by Mac on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Page.h"
#import "Sound.h"
#import "Lib.h"
#import "UIImage+Resize.h"

@implementation Page
@synthesize index, image, voice, text, order, time, created, modified, isCover, pageFolder;

+ (Page*)newPage {
    Page *page = [[Page alloc] init];
    page.image = @"";
    page.voice = @"";
    page.text = @"";
    page.created = round([[NSDate date] timeIntervalSince1970]);
    page.modified = page.created;
    page.index = page.created * 100 + (arc4random() % 90) + 10;
    page.order = 1;
    page.isCover = NO;
    return page;
}

+ (Page*)newCover {
    Page *page = [[Page alloc] init];
    page.image = @"";
    page.voice = @"";
    page.text = @"";
    page.created = round([[NSDate date] timeIntervalSince1970]);
    page.modified = page.created;
    page.index = page.created * 100 + (arc4random() % 90) + 10;
    page.order = 0;
    page.isCover = YES;
    return page;
}

- (void)deleteImage {
    if (![image isEqualToString:@""] && image != NULL) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", [Lib applicationDocumentsDirectory],image];
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@.jpg",path] error:NULL];

    }
   }
- (void)deleteVoice {
    if (![voice isEqualToString:@""] && voice != NULL) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", [Lib applicationDocumentsDirectory],voice];
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

- (void) playPageAtSecond: (NSInteger)second inView: (UIImageView*)imageView withTextView: (UITextView*)textView withAudio:(BOOL)isAudio {
    
    [imageView setImage:[self pageImageWithDefaultBackground]];

    [textView setText:text];
    if (isAudio) {
        if (second < time) {
            [[Sound sharedInstance] playVoice:voice fromSecond:second];
        }
    }
    
}
- (UIImage*)pageImage {
    if (![self.image isEqualToString:@""] && self.image != NULL) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory],self.image];
        return [UIImage imageWithContentsOfFile:path];
    }
    else {
        return [UIImage new];
    }
}

- (UIImage*)pageImageWithDefaultBackground {
    if (![self.image isEqualToString:@""] && self.image != NULL) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory],self.image];
        return [UIImage imageWithContentsOfFile:path];
    }
    else {
        if (isCover) {
            return [UIImage imageNamed:@"cover_default.jpg"];
        }
        else {
            return [UIImage imageNamed:@"page_default.jpg"];
        }
    }
}

- (NSString*)pageImagePath {
    return [NSString stringWithFormat:@"%@/%@.jpg",[Lib applicationDocumentsDirectory],self.image];
}

- (UIImage*)pageThumbnail {
    if (![self.image isEqualToString:@""] && self.image != NULL) {
        NSString *path = [NSString stringWithFormat:@"%@/%@.jpg",[Lib applicationDocumentsDirectory],self.image];
        return [UIImage imageWithContentsOfFile:path];
    }
    else {
        if (isCover) {
            return [UIImage imageNamed:@"cover_default_med.jpg"];
        }
        else {
            return [UIImage imageNamed:@"page_default_med.jpg"];
        }
    }
}
- (NSString*)pageVoicePath {
    NSString *path = [NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory],self.voice];
    return path;
}

- (void)saveImage:(UIImage*)original {
        
    double number = round([[NSDate date] timeIntervalSince1970]);
        
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@/images",
                                [Lib applicationDocumentsDirectory],pageFolder];
    NSString *imageName = [NSString stringWithFormat:@"/%@/images/%.0f.jpg",
                               pageFolder,number];
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]; 
    }
        
        // Find the path to the documents directory
        
    NSString *fullPathToFile = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:imageName];

    if ((original.size.width > 600) || (original.size.height > 420) ) {
        [original resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(600, 420) interpolationQuality:kCGInterpolationDefault];
    }
    
    [UIImageJPEGRepresentation(original, 0.8) writeToFile:fullPathToFile atomically:YES];
    UIImage *thumbnail = [original resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(200, 140) interpolationQuality:kCGInterpolationDefault];
    [UIImageJPEGRepresentation(thumbnail, 0.8) writeToFile:[NSString stringWithFormat:@"%@.jpg",fullPathToFile] atomically:YES];
    
    self.image = imageName;
    self.modified = round([[NSDate date] timeIntervalSince1970]);
}

- (void)saveAudio:(NSData *)audioData {
    
    double number = round([[NSDate date] timeIntervalSince1970]);
    
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@/voices",
                            [Lib applicationDocumentsDirectory],pageFolder];
    NSString *voiceName = [NSString stringWithFormat:@"/%@/voices/%.0f.caf",
                           pageFolder,number];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Find the path to the documents directory
    
    NSString *fullPathToFile = [[Lib applicationDocumentsDirectory] stringByAppendingPathComponent:voiceName];
    NSURL *file = [NSURL fileURLWithPath:fullPathToFile];
     
    [audioData writeToURL:file atomically:YES];
    
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    
    self.time = player.duration;
    self.voice = voiceName;
    self.modified = round([[NSDate date] timeIntervalSince1970]);
}

- (void)uploadPageWithUser: (NSString*)userid userPath: (NSString*)userPath taleId:(NSString*)taleId storyId:(NSString*)storyId pageNumber:(NSString*)pageNumber uid:(NSString*)uid{
    
    
    NSMutableURLRequest* theRequest = [[NSMutableURLRequest alloc] initWithURL: 
                                        [NSURL URLWithString:[NSString stringWithFormat: @"%@/services/upload_page_1_3_0.php",servicesURLPrefix]]];
	[theRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = @"0xKhTmLbOuNdArY";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// User ID
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"userid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",userid] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // User Path
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"userpath"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",userPath] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Unique ID
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"uid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",uid] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Tale ID
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"taleid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",taleId] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Story Id
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"storyid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",storyId] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
	// Page Number
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"pageid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",pageNumber] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Text
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"text"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",self.text] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
    // Date Created
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"date_created"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%0.f",self.created] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Date Modified
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"date_modified"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%0.f",self.modified] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // Image
    
    if (![image isEqualToString:@""] && image != NULL) {
        NSData* imgData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory], image]];
        
        if (imgData != nil) {
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@.jpg\"\r\n", uid] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[NSData dataWithData:imgData]];
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }    
    }
    //Sound
    if (![voice isEqualToString:@""] && voice != NULL) {
        NSData* audioData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory], voice]];
        
        if (audioData != nil) {
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"audio\"; filename=\"%@.caf\"\r\n",uid] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Type: audio/x-caf\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[NSData dataWithData:audioData]];
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
	[theRequest setHTTPBody:postBody];

	NSData* responeData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
	NSString *a = [[NSString alloc] initWithData:responeData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",a);
}

- (void)deletePageOrphanFile {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@/images",
                           [Lib applicationDocumentsDirectory],pageFolder];

    if ([fm fileExistsAtPath:imagePath]) {
        NSArray *imageList = [fm contentsOfDirectoryAtPath:imagePath error:nil];
        for (NSString *fileName in imageList) {
            NSString *imageName = [NSString stringWithFormat:@"/%@/images/%@",pageFolder,fileName];
            if (![imageName isEqualToString:self.image] && ![imageName isEqualToString:[NSString stringWithFormat:@"%@.jpg",self.image]]) {
                [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", imagePath,fileName] error:nil];
            }
        }
    }
    
    NSString* voicePath = [NSString stringWithFormat:@"%@/%@/voices",
                 [Lib applicationDocumentsDirectory],pageFolder];
    
    if ([fm fileExistsAtPath:voicePath]) {
        NSArray *voiceList = [fm contentsOfDirectoryAtPath:voicePath error:nil];
        for (NSString *fileName in voiceList) {
            NSString *voiceName = [NSString stringWithFormat:@"/%@/voices/%@",pageFolder,fileName];
            if (![voiceName isEqualToString:self.voice]) {
                [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", voicePath,fileName] error:nil];
            }
        }
    }

}
@end
