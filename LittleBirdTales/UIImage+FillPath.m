//
//  UIImage+FillPath.m
//  Test
//
//  Created by Toan M. Ha on 2/24/12.
//  Copyright (c) 2012 Kubic Solutions. All rights reserved.
//

#import "UIImage+FillPath.h"

@implementation UIImage (FillPath)
- (Pixel)pixelAtPoint : (int)x : (int)y : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)data {
    Pixel pixel;
    unsigned byteIndex = bytesPerRow*y + x*bytesPerPixel;
    //NSLog(@"%lu",sizeof(data));
    //if (byteIndex < sizeof(data)) {
        pixel.red = data[byteIndex];
        pixel.green = data[byteIndex + 1];
        pixel.blue = data[byteIndex + 2];
        pixel.alpha = data[byteIndex + 3];        
    //}
    return pixel;
}

- (BOOL)isOutOfBounds : (int)x : (int)y {
    BOOL outOfBounds = YES;
    if (x < self.size.width && x >=0 && 
        y < self.size.height && y >=0) {
        outOfBounds = NO;
    }    
    return outOfBounds;
}

- (BOOL)reachedStopColor : (int)x : (int)y : (Pixel)fromColor : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)data {
    Pixel pixel = [self pixelAtPoint:x :y :bytesPerRow :bytesPerPixel :data];
    if (abs(pixel.red - fromColor.red) > PER_THREADHOLD ||
        abs(pixel.green - fromColor.green) > PER_THREADHOLD ||
        abs(pixel.blue - fromColor.blue) > PER_THREADHOLD ||
        abs(pixel.alpha - fromColor.alpha) > PER_THREADHOLD) {
        return YES;
    }
    return NO;
}

- (BOOL)reachedFilledColor : (int)x : (int)y : (Pixel)fillColor : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)toData {
    Pixel pixel = [self pixelAtPoint:x :y :bytesPerRow :bytesPerPixel :toData];
    if (pixel.red > PER_THREADHOLD || 
        pixel.green > PER_THREADHOLD || 
        pixel.blue > PER_THREADHOLD|| 
        pixel.alpha > PER_THREADHOLD) {
        return YES;
    }
    return NO;
}

- (void)fill_right : (int)x : (int)y : (Pixel)fromColor : (Pixel)fillColor : (unsigned char*)data : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)toData {
    if (x < 0 || y < 0) return;
    if([self isOutOfBounds:x:y] || 
       [self reachedStopColor:x:y:fromColor:bytesPerRow:bytesPerPixel:data] ||
       [self reachedFilledColor:x :y :fillColor :bytesPerRow :bytesPerPixel :toData]) {
        return;
    }
    unsigned int byteIndex = bytesPerRow*y + x*bytesPerPixel;
    data[byteIndex]   = fillColor.red; 
    data[byteIndex+1] = fillColor.green;
    data[byteIndex+2] = fillColor.blue;
    data[byteIndex+3] = fillColor.alpha;
    
    toData[byteIndex] = fillColor.red;
    toData[byteIndex+1] = fillColor.green;
    toData[byteIndex+2] = fillColor.blue;
    toData[byteIndex+3] = fillColor.alpha;
    
    [self fill_right:x+1:y:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    [self fill_right:x:y+1:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    if (y > 0) {
        [self fill_right:x:y-1:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];        
    }
}


- (void)fill_left : (int)x : (int)y : (Pixel)fromColor : (Pixel)fillColor : (unsigned char*)data : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)toData {
    if (x < 0 || y < 0) return;
    if([self isOutOfBounds:x:y] || 
       [self reachedStopColor:x:y:fromColor:bytesPerRow:bytesPerPixel:data] ||
       [self reachedFilledColor:x :y :fillColor :bytesPerRow :bytesPerPixel :toData]) {
        return;
    }
    unsigned int byteIndex = bytesPerRow*y + x*bytesPerPixel;
    data[byteIndex]   = fillColor.red; 
    data[byteIndex+1] = fillColor.green;
    data[byteIndex+2] = fillColor.blue;
    data[byteIndex+3] = fillColor.alpha;
    
    toData[byteIndex] = fillColor.red;
    toData[byteIndex+1] = fillColor.green;
    toData[byteIndex+2] = fillColor.blue;
    toData[byteIndex+3] = fillColor.alpha;
    
    if (x > 1) {
        [self fill_left:x-1:y:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    }
    
    [self fill_left:x:y+1:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    
    if (y > 0) {
        [self fill_left:x:y-1:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    }
}

- (void)flood_fill : (int)x : (int)y : (Pixel)fromColor : (Pixel)fillColor : (unsigned char*)data : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)toData {
    if (x < 0 || y < 0) return;
    if([self isOutOfBounds:x:y] || 
       [self reachedStopColor:x:y:fromColor:bytesPerRow:bytesPerPixel:data] ||
       [self reachedFilledColor:x :y :fillColor :bytesPerRow :bytesPerPixel :toData]) {
        return;
    }
    
//    if([self isOutOfBounds:x:y] || [self reachedStopColor:x:y:fromColor:bytesPerRow:bytesPerPixel:data]) {
//        return;
//    } 
    unsigned byteIndex = bytesPerRow*y + x*bytesPerPixel;
    data[byteIndex]   = fillColor.red; 
    data[byteIndex+1] = fillColor.green;
    data[byteIndex+2] = fillColor.blue;
    data[byteIndex+3] = fillColor.alpha;
    
    toData[byteIndex] = fillColor.red;
    toData[byteIndex+1] = fillColor.green;
    toData[byteIndex+2] = fillColor.blue;
    toData[byteIndex+3] = fillColor.alpha;
    
    [self flood_fill:x+1:y:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    [self flood_fill:x-1:y:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    [self flood_fill:x:y+1:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
    [self flood_fill:x:y-1:fromColor:fillColor:data:bytesPerRow:bytesPerPixel:toData];
}

- (UIImage*)floodFill : (int)x : (int)y : (Pixel)fillColor {
    UIImage* retVal = nil;
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    unsigned char *toData = malloc(height * width * 4);
    memset(toData, 0, height * width * 4);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
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
    //NSLog(@"%i %i %i",fillColor.red, fillColor.green, fillColor.blue);
    Pixel fromColor = [self pixelAtPoint:x :y :bytesPerRow :bytesPerPixel :rawData];  
    
    [self flood_fill:x+1:y:fromColor:fillColor:rawData:bytesPerRow:bytesPerPixel:toData];
    [self flood_fill:x-1:y:fromColor:fillColor:rawData:bytesPerRow:bytesPerPixel:toData];
    [self flood_fill:x:y+1:fromColor:fillColor:rawData:bytesPerRow:bytesPerPixel:toData];
    [self flood_fill:x:y-1:fromColor:fillColor:rawData:bytesPerRow:bytesPerPixel:toData];
    
//    [self fill_right:x :y :fromColor :fillColor :rawData :bytesPerRow :bytesPerPixel:toData];
//    [self fill_left:x-1 :y :fromColor :fillColor :rawData :bytesPerRow :bytesPerPixel:toData];
    
    context = CGBitmapContextCreate(toData,
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
    free(toData);
    
    return retVal;
}


- (UIImage*)floodFill:(CGPoint)point :(Pixel)fillColor {
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    unsigned char *toData = malloc(height * width * 4);
    memset(toData, 0, height * width * 4);

    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    Pixel fromColor = [self pixelAtPoint:point.x :point.y :bytesPerRow :bytesPerPixel :rawData];    
    [self fill_right:point.x :point.y :fromColor :fillColor :rawData :bytesPerRow :bytesPerPixel:toData];
    [self fill_left:point.x-1 :point.y :fromColor :fillColor :rawData :bytesPerRow :bytesPerPixel:toData];
    
    context = CGBitmapContextCreate(toData,
                                CGImageGetWidth( imageRef ),
                                CGImageGetHeight( imageRef ),
                                8,
                                CGImageGetBytesPerRow( imageRef ),
                                CGImageGetColorSpace( imageRef ),
                                kCGImageAlphaPremultipliedLast ); 
    
    imageRef = CGBitmapContextCreateImage (context);
    UIImage* retVal = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(context);  
    free(rawData);
    free(toData);
    
    return retVal;
}
@end
