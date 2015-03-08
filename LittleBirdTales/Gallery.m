//
//  Gallery.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gallery.h"
#import "UIImage+Resize.h"
#import "Lib.h"

@implementation Gallery

+ (NSString*)dir {
    
    if([Lib getValueOfKey:@"user_id"] && ![[Lib getValueOfKey:@"user_id"]  isEqual: @""]) {
        return [NSString stringWithFormat:@"%@/gallery/%@/",
                [Lib applicationDocumentsDirectory], [Lib getValueOfKey:@"user_id"]];
    }
    else {
        return [NSString stringWithFormat:@"%@/gallery/",
                [Lib applicationDocumentsDirectory]];
    }
}

+ (BOOL)saveImage:(UIImage*)original {
    
    double number = round([[NSDate date] timeIntervalSince1970]);
    
    NSString *folderPath = [self dir];
    NSString *imageName = [NSString stringWithFormat:@"%.0f.jpg",number];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]; 
    }
    
    // Find the path to the documents directory
    
    NSString *fullPathToFile = [folderPath stringByAppendingPathComponent:imageName];
    
    if ((original.size.width > 600) || (original.size.height > 420) ) {
        [original resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(600, 420) interpolationQuality:kCGInterpolationDefault];
    }
    
    [UIImageJPEGRepresentation(original, 0.8) writeToFile:fullPathToFile atomically:YES];
    UIImage *thumbnail = [original thumbnailImage:80 transparentBorder:0 cornerRadius:5 interpolationQuality:kCGInterpolationDefault];
    [UIImageJPEGRepresentation(thumbnail, 0.8) writeToFile:[NSString stringWithFormat:@"%@.jpg",fullPathToFile] atomically:YES];

    thumbnail = [original thumbnailImage:150 transparentBorder:0 cornerRadius:5 interpolationQuality:kCGInterpolationDefault];
    [UIImageJPEGRepresentation(thumbnail, 0.8) writeToFile:[NSString stringWithFormat:@"%@_iphone.jpg",fullPathToFile] atomically:YES];
    
    return TRUE;
}
@end
