//
//  CircleLayer.m
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleLayer.h"
@implementation CircleLayer
@synthesize fillColor, edgeColor, lineWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        lineWidth = 2.0f;
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
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGRect eRect = rect;
    eRect.origin.x += lineWidth;
    eRect.origin.y += lineWidth;
    eRect.size.width -= 2 * lineWidth;
    eRect.size.height -= 2 * lineWidth;
    CGContextFillEllipseInRect(context, eRect);
    
    
    CGContextRestoreGState(context);
}

@end
