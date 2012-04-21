//
//  ColorHelper.h
//  LittleBirdTales
//
//  Created by Mac on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorHelper : NSObject
@property (nonatomic, retain) UIColor* edgeColor;
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, assign) float lineWide;
@property (nonatomic, assign) float shadow;
@property (nonatomic, retain) NSString* fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) float alpha;

+ (ColorHelper *)shared;
+(UIColor*)colorWithNoAlpha:(UIColor*)color;
+ (NSString *)stringForColor:(UIColor *)color;
+ (UIColor *)colorFromString:(NSString *)colorStr;
+ (BOOL)isBrightnessColor:(UIColor*)color;
@end
