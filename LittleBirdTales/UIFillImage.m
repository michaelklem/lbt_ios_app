//
//  UIFillImage.m
//  LittleBirdTales
//
//  Created by Mac on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIFillImage.h"
#import "FloodFill.h"
@implementation UIFillImage
- (Pixel)pixelAtPoint:(int)x:(int)y:(unsigned char*)data {
    Pixel pixel;
    unsigned byteIndex = bytesPerRow*y + x*bytesPerPixel;
    pixel.red = data[byteIndex];
    pixel.green = data[byteIndex + 1];
    pixel.blue = data[byteIndex + 2];
    pixel.alpha = data[byteIndex + 3];        
    return pixel;
}

- (void)fill_right:(int)x:(int)y { 
    if (x < 0 || y < 0 || x >= width || y >= height)  return;
    unsigned int byteIndex = bytesPerRow*y + x*bytesPerPixel;
    if (abs(rawData[byteIndex] - fromColor.red) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 1] - fromColor.green) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 2] - fromColor.blue) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 3] - fromColor.alpha) > PER_THREADHOLD) {
        return;
    }
    if (abs(rawData[byteIndex] - fillColor.red) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 1] - fillColor.green) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 2] - fillColor.blue) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 3] - fillColor.alpha) < PER_THREADHOLD) {
        return;
    }
    
    rawData[byteIndex]   = fillColor.red; 
    rawData[byteIndex+1] = fillColor.green;
    rawData[byteIndex+2] = fillColor.blue;
    rawData[byteIndex+3] = fillColor.alpha;
    
    
    [self fill_right:x+1:y];
    [self fill_right:x:y+1];
    if (y > 0) {
        [self fill_right:x:y-1];        
    }
    if (x > 0) {
        unsigned int byteIndex = bytesPerRow*y + (x-1)*bytesPerPixel;
        if (abs(rawData[byteIndex] - fromColor.red) > PER_THREADHOLD ||
            abs(rawData[byteIndex + 1] - fromColor.green) > PER_THREADHOLD ||
            abs(rawData[byteIndex + 2] - fromColor.blue) > PER_THREADHOLD ||
            abs(rawData[byteIndex + 3] - fromColor.alpha) > PER_THREADHOLD) {
            return;
        }
        if (abs(rawData[byteIndex] - fillColor.red) < PER_THREADHOLD &&
             abs(rawData[byteIndex + 1] - fillColor.green) < PER_THREADHOLD &&
             abs(rawData[byteIndex + 2] - fillColor.blue) < PER_THREADHOLD &&
             abs(rawData[byteIndex + 3] - fillColor.alpha) < PER_THREADHOLD) {
            return;
        }
        [self fill_left:x-1:y];
    }
}


- (void)fill_left:(int)x:(int)y { 
    if (x < 0 || y < 0 || x >= width || y >= height)  return;
    unsigned int byteIndex = bytesPerRow*y + x*bytesPerPixel;
    if (abs(rawData[byteIndex] - fromColor.red) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 1] - fromColor.green) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 2] - fromColor.blue) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 3] - fromColor.alpha) > PER_THREADHOLD) {
        return;
    }
    if (abs(rawData[byteIndex] - fillColor.red) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 1] - fillColor.green) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 2] - fillColor.blue) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 3] - fillColor.alpha) < PER_THREADHOLD) {
        return;
    }
    rawData[byteIndex]   = fillColor.red; 
    rawData[byteIndex+1] = fillColor.green;
    rawData[byteIndex+2] = fillColor.blue;
    rawData[byteIndex+3] = fillColor.alpha;
    
    if (x > 0) {
        [self fill_left:x-1:y];
    }
    
    [self fill_left:x:y+1];
    
    if (y > 0) {
        [self fill_left:x:y-1];
    }
    if (x < width - 1) {
        unsigned int byteIndex = bytesPerRow*y + (x+1)*bytesPerPixel;
        if (abs(rawData[byteIndex] - fromColor.red) > PER_THREADHOLD ||
            abs(rawData[byteIndex + 1] - fromColor.green) > PER_THREADHOLD ||
            abs(rawData[byteIndex + 2] - fromColor.blue) > PER_THREADHOLD ||
            abs(rawData[byteIndex + 3] - fromColor.alpha) > PER_THREADHOLD) {
            return;
        }
        if (abs(rawData[byteIndex] - fillColor.red) < PER_THREADHOLD &&
            abs(rawData[byteIndex + 1] - fillColor.green) < PER_THREADHOLD &&
            abs(rawData[byteIndex + 2] - fillColor.blue) < PER_THREADHOLD &&
            abs(rawData[byteIndex + 3] - fillColor.alpha) < PER_THREADHOLD) {
            return;
        }
        [self fill_right:x+1:y];        
    }
}

- (void)flood_fill:(int)x:(int)y {
    if (x < 0 || y < 0 || x >= width || y >= height)  return;
    unsigned int byteIndex = bytesPerRow*y + x*bytesPerPixel;
    if (abs(rawData[byteIndex] - fromColor.red) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 1] - fromColor.green) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 2] - fromColor.blue) > PER_THREADHOLD ||
        abs(rawData[byteIndex + 3] - fromColor.alpha) > PER_THREADHOLD) {
        return;
    }
    
    if (abs(rawData[byteIndex] - fillColor.red) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 1] - fillColor.green) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 2] - fillColor.blue) < PER_THREADHOLD &&
        abs(rawData[byteIndex + 3] - fillColor.alpha) < PER_THREADHOLD) {
        return;
    }

    rawData[byteIndex]   = fillColor.red; 
    rawData[byteIndex+1] = fillColor.green;
    rawData[byteIndex+2] = fillColor.blue;
    rawData[byteIndex+3] = fillColor.alpha;

    [self flood_fill:x+1:y];
    [self flood_fill:x-1:y];
    [self flood_fill:x:y+1];
    [self flood_fill:x:y-1];
}

- (UIImage*)fillFlood:(int)x:(int)y:(Pixel)_fillColor:(UIImage*)image { 
    UIImage* retVal = nil;
    CGImageRef imageRef = image.CGImage;
    width = CGImageGetWidth(imageRef);
    height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    rawData = malloc(height * width * 4);
//    toData = malloc(height * width * 4);
//    memset(toData, 0, height * width * 4);
    
//    if ( !rawData || !toData )  {        
//        CGColorSpaceRelease( colorSpace );        
//        return nil;
//    }
    bytesPerPixel = 4;
    bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, 
                                                 width, 
                                                 height,
                                                 bitsPerComponent, 
                                                 bytesPerRow, 
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    fromColor = [self pixelAtPoint:x :y :rawData];  
    fillColor = _fillColor;
    
    color from_color = [FloodFill mkcolorR:fromColor.red G:fromColor.green B:fromColor.blue A:fromColor.alpha];
    color fill_color = [FloodFill mkcolorR:fillColor.red G:fillColor.green B:fillColor.blue A:fillColor.alpha];
    
    [FloodFill floodfillX:x Y:y image:rawData width:width height:height 
             replacement:fill_color target:from_color];
    
//    [self flood_fill:x:y];
//    [self flood_fill:x-1:y];
//    [self flood_fill:x:y+1];
//    [self flood_fill:x:y-1];
    
//    [self fill_right:x:y];
//    [self fill_left:x-1:y];
    
    context = CGBitmapContextCreate(rawData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big); 
    
    imageRef = CGBitmapContextCreateImage (context);
    retVal = [UIImage imageWithCGImage:imageRef];  
    
    CGContextRelease(context);  
    CGColorSpaceRelease(colorSpace);
    
    free(rawData);
    rawData = nil;
    
    return retVal;
}

@end
