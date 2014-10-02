//
//  UIImage+FillPath.h
//  Test
//
//  Created by Mac on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UIImage (FillPath)
- (UIImage*)floodFill : (CGPoint)point : (Pixel)fillColor;
- (UIImage*)floodFill : (int)x : (int)y : (Pixel)fillColor;
- (void)fill_left : (int)x : (int)y : (Pixel)fromColor : (Pixel)fillColor : (unsigned char*)data : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)toData;
- (void)fill_right: (int)x :(int)y :(Pixel)fromColor :(Pixel)fillColor : (unsigned char*)data : (int)bytesPerRow : (int)bytesPerPixel : (unsigned char*)toData;
@end
