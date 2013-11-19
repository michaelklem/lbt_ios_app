//
//  UIFillImage.h
//  LittleBirdTales
//
//  Created by Mac on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFillImage : NSObject{
    int bytesPerRow;
    int bytesPerPixel;
    int width;
    int height;
    unsigned char *rawData;
    int loopCount;
    Pixel fromColor;
    Pixel fillColor;
}
- (UIImage*)fillFlood:(int)x:(int)y:(Pixel)_fillColor:(UIImage*)image;
- (void)fill_left:(int)x:(int)y;
- (void)fill_right:(int)x:(int)y;
@end
