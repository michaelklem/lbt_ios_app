//
//  RectangleLayer.m
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RectangleLayer.h"

@implementation RectangleLayer
@synthesize edgeColor, fillColor, lineWidth;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.fillColor = [UIColor whiteColor];
        self.edgeColor = [UIColor blackColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, edgeColor.CGColor);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGContextRestoreGState(context);
}
@end
