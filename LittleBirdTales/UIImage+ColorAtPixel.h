//
//  UIImage+ColorAtPixel.h
//  LittleBirdTales
//
//  Created by Mac on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorAtPixel)

- (UIColor *)colorAtPixel:(CGPoint)point;

@end