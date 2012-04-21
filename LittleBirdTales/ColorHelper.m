//
//  ColorHelper.m
//  LittleBirdTales
//
//  Created by Mac on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorHelper.h"
#import "Lib.h"

static ColorHelper* share;
@implementation ColorHelper
@synthesize edgeColor, fillColor, lineWide, shadow, fontName, fontSize, alpha;

+(BOOL)isBrightnessColor:(UIColor*)color {
    const CGFloat *rgb = CGColorGetComponents(color.CGColor);
    CGFloat red = rgb[0];
    CGFloat green = rgb[1];
    CGFloat blue = rgb[2];

    float num = red;
    float num2 = blue;
    float num3 = green;
    float num4 = num;
    float num5 = num;
    if (num2 > num4)
        num4 = num2;
    if (num3 > num4)
        num4 = num3;
    if (num2 < num5)
        num5 = num2;
    if (num3 < num5)
        num5 = num3;
    if (((num4 + num5) / 2.0f) > 0.5) {
        return YES;
    }
    return FALSE;
}
+(UIColor*)colorWithNoAlpha:(UIColor*)color {
    const CGFloat *rgb = CGColorGetComponents(color.CGColor);
    return [UIColor colorWithRed:rgb[0] green:rgb[1] blue:rgb[2] alpha:1.0];
}

+(ColorHelper*)shared {
    if (!share) {
        share = [[ColorHelper alloc] init];
    }
    return share;
}
+ (NSString *)stringForColor:(UIColor *)color {
//    CIColor* ciColor = [CIColor colorWithCGColor:color.CGColor];
//    NSLog(@"ColorStr: %@",ciColor.stringRepresentation);
//    return ciColor.stringRepresentation;
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"%0.3f %0.3f %0.3f %0.3f",components[0],
            components[1],components[2],components[3]];
}

+ (UIColor *)colorFromString:(NSString *)colorStr {
    NSArray *components = [colorStr componentsSeparatedByString:@" "];
    if (components.count == 4) {
        return [UIColor colorWithRed:[[components objectAtIndex:0] floatValue] 
                               green:[[components objectAtIndex:1] floatValue]  
                                blue:[[components objectAtIndex:2] floatValue]
                               alpha:1.0];
                //[[components objectAtIndex:3] floatValue]]; 
    }
    return nil;
}
-(void)setShadow:(float)_shadow {
    if (shadow > 0 && _shadow > 0) {
        [Lib setValue:[NSString stringWithFormat:@"%0.2f",_shadow] forKey:@"shadow"];    
    }
    shadow = _shadow;
}
-(void)setLineWide:(float)_lineWide {
    if (lineWide > 0 && _lineWide > 0) {
        [Lib setValue:[NSString stringWithFormat:@"%0.2f",_lineWide] forKey:@"line-wide"];    
    }
    lineWide = _lineWide;
}
-(void)setFillColor:(UIColor *)_fillColor {
    if (self.fillColor && _fillColor) {
        [Lib setValue:[ColorHelper stringForColor:_fillColor] forKey:@"fill-color"];  
    }
    fillColor = _fillColor;
}
-(void)setEdgeColor:(UIColor *)_edgeColor {
    if (self.edgeColor && _edgeColor) {
        [Lib setValue:[ColorHelper stringForColor:_edgeColor] forKey:@"edge-color"];  
    }
    edgeColor = _edgeColor;
}

-(void)setFontName:(NSString *)_fontName {    
    if (self.fontName && _fontName) {
        [Lib setValue:_fontName forKey:@"font-name"];  
    }
    fontName = _fontName;
}

-(void)setFontSize:(float)_fontSize {
    if (self.fontSize > 0 && _fontSize > 0) {
        [Lib setValue:[NSString stringWithFormat:@"%0.2f",_fontSize]
               forKey:@"font-size"];  
    }
    fontSize = _fontSize;
}

-(void)setAlpha:(float)_alpha {
    if (_alpha >= 0.0 && _alpha <= 1.0) {
        [Lib setValue:[NSString stringWithFormat:@"%0.2f",_alpha]
               forKey:@"alpha"];  
    }
    alpha = _alpha;
}

-(id)init {
    self = [super init];
    
    if ([Lib getValueOfKey:@"edge-color"]) {
        self.edgeColor = [ColorHelper colorFromString:[Lib getValueOfKey:@"edge-color"]];
    }
    if (!self.edgeColor) {
        self.edgeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
    
    if ([Lib getValueOfKey:@"fill-color"]) {
        self.fillColor = [ColorHelper colorFromString:[Lib getValueOfKey:@"fill-color"]];
    }    
    if (!self.fillColor) {
        self.fillColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }

    if ([Lib getValueOfKey:@"line-wide"]) {
        self.lineWide = [[Lib getValueOfKey:@"line-wide"] floatValue];
    }
    
    if (self.lineWide < 2.0) {
        self.lineWide = 6.0;
    }
    
    if ([Lib getValueOfKey:@"shadow"]) {
        self.shadow = [[Lib getValueOfKey:@"shadow"] floatValue];
    }
    
    if (self.shadow < 2.0) {
        self.shadow = 6.0;
    }

    if ([Lib getValueOfKey:@"font-name"]) {
        self.fontName = [Lib getValueOfKey:@"font-name"];
    }
    if (!self.fontName) {
        self.fontName = @"ArialRoundedMTBold";
    }
    
    if ([Lib getValueOfKey:@"font-size"]) {
        self.fontSize = [[Lib getValueOfKey:@"font-size"] floatValue];
    }
    
    if (self.fontSize < 10.0) {
        self.fontSize = 20.0;
    }
    
    if ([Lib getValueOfKey:@"alpha"]) {
        self.alpha = [[Lib getValueOfKey:@"alpha"] floatValue];
    } else alpha = 1.0;
    if (self.alpha < 0.0 || self.alpha >= 1.0) {
        self.alpha = 1.0;
    }
    return self;
}
@end
