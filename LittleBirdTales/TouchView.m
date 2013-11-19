//
//  TouchView.m
//  Test123
//
//  Created by Mac on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView
@synthesize paintPath, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        paintPath = [[PaintPath alloc] init];
    }
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1) {
        [paintPath.points removeAllObjects];
        CGPoint point = [[touches anyObject] locationInView:self];

        switch (paintPath.type) {
            case kFigureLine:
            case kFigureEclipse:
            case kFigureRect:
            case kFigureDot:
            case kFigureClear:
                ;
                [paintPath.points addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:point.x],@"x",
                                             [NSNumber numberWithInt:point.y],@"y",
                                             nil]];
                break;
            case kFigureText:
                [paintPath.points addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:point.x],@"x",
                                             [NSNumber numberWithInt:point.y],@"y",
                                             nil]];
                [self.delegate textNeedText];
                break;
            case kFigureFill:
                [paintPath.points addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:point.x],@"x",
                                             [NSNumber numberWithInt:point.y],@"y",
                                             nil]];
                break;
            default:
                break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1) {
        CGPoint point = [[touches anyObject] locationInView:self];

        switch (paintPath.type) {
            case kFigureDot:
            case kFigureClear:
                ;
                [paintPath.points addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:point.x],@"x",
                                             [NSNumber numberWithFloat:point.y],@"y",
                                             nil]];
                if (paintPath.points.count > 1) {
                    [self setNeedsDisplay];
                }
                break;
            case kFigureLine:
            case kFigureEclipse:
            case kFigureRect:
                ;
                if (paintPath.points.count > 1) {
                    [paintPath.points removeObjectAtIndex:1];                    
                }
                [paintPath.points addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:point.x],@"x",
                                             [NSNumber numberWithFloat:point.y],@"y",
                                             nil]];
                [self setNeedsDisplay];
                break;
                
            case kFigureFill:
                ;
                [paintPath.points removeAllObjects];
                [paintPath.points addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:point.x],@"x",
                                             [NSNumber numberWithFloat:point.y],@"y",
                                             nil]];
                break;
            default:
                break;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1) {
        switch (paintPath.type) {
            case kFigureLine:
            case kFigureEclipse:
            case kFigureRect:
            case kFigureClear:
            case kFigureDot:
            case kFigureFill:
                ;
                if (self.delegate)
                    [self.delegate drawNewFigure:[paintPath copy]];
                break;
            default:
                break;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();  

    switch (paintPath.type) {
        case kFigureDot:
        case kFigureClear:
        case kFigureLine:
        case kFigureEclipse:
        case kFigureRect:
            ;
            [paintPath draw:context inRect:rect];
            break;

        default:
            break;
    }
}

@end
