//
//  PainPath.h
//  Test123
//
//  Created by Mac on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kFigureDot,
    kFigureClear,
    kFigureLine,
    kFigureRect,
    kFigureText,
    kFigureEclipse,
    kFigureImage,
    kFigureFill,
    kFigureClearAll
}  FigureType;

typedef enum {
    kDrawFill,
    kDrawCenter
} DrawMode;
@interface PaintPath : NSObject
@property (nonatomic, retain) UIFont* font;
@property (nonatomic, assign) DrawMode drawMode;
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, retain) UIColor* strokerColor;
@property (nonatomic, assign) float brushWide;
@property (nonatomic, assign) float shadowWide;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, assign) FigureType type;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) UIImage* image;
-(void)draw:(CGContextRef)context inRect:(CGRect)rect;
@end
