//
//  UIImage+Thumbnail.m
//  DateDump
//
//  Created by Mac on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Thumbnail.h"
#import "UIImage+Resize.h"

@implementation UIImage (Thumbnail)
-(UIImage*)squreThumbnailWithWidth:(float)width {
    UIImage* retImage = nil;
    float fullWidth = self.size.width;
    if (fullWidth > self.size.height) {
        fullWidth = self.size.height;
    }
    fullWidth = floorf(fullWidth);
    
    CGRect rect = CGRectMake(floorf((self.size.width - fullWidth)/2), 
                             floorf((self.size.height - fullWidth)/2),
                             fullWidth, fullWidth);
    retImage = [[self croppedImage:rect] resizedImage:CGSizeMake(width, width) interpolationQuality:kCGInterpolationHigh];
    return retImage;
}

@end
