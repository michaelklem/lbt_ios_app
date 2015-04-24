//
//  PainPath.m
//  Test123
//
//  Created by Mac on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintPath.h"
@implementation PaintPath
@synthesize fillColor, strokerColor, brushWide, shadowWide, points, type, text, image, drawMode, font;
- (id)init {
    self = [super init];
    self.points = [[NSMutableArray alloc] init];
    return self;
}
- (void)paintClearAll:(CGContextRef)context inRect:(CGRect)rect{
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
}

- (void)paintText:(CGContextRef)context inRect:(CGRect)rect{
    if ([self.points count] > 0 && self.text && self.text.length > 0) {
        CGContextSetFillColorWithColor(context, self.strokerColor.CGColor);
        CGContextSetStrokeColorWithColor(context, self.strokerColor.CGColor);
        CGPoint point;
        NSDictionary* dic = [self.points objectAtIndex:0];
        point.x = (int)[[dic objectForKey:@"x"] floatValue];
        point.y = (int)[[dic objectForKey:@"y"] floatValue];
        
        CGRect textFrame;
        textFrame.origin.x = point.x;
        textFrame.origin.y = point.y;        
        textFrame.size.width = rect.size.width - textFrame.origin.x - 5;
        textFrame.size.height = rect.size.height - textFrame.origin.y - 5;
        
        if (textFrame.size.width < 0 && textFrame.size.height < 0) {
            return;
        }
        [self.text drawInRect:textFrame 
                     withFont:self.font 
           lineBreakMode:NSLineBreakByWordWrapping
               alignment:NSTextAlignmentLeft];
        
//        CGContextSetTextDrawingMode(context, kCGTextStroke);
//        CGContextSelectFont(context, "Times", 12.0, kCGEncodingMacRoman);
//        CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
//        CGContextSetTextMatrix(context, transform);
//        const char* txt = [text UTF8String];
//        CGContextShowTextAtPoint(context, 100.0, 100.0, txt, 
//                                 strlen(txt));
    }
}

- (void)paintImage:(CGContextRef)context inRect:(CGRect)rect{
    if (!self.image) {
        return;
    }
    
    if (self.drawMode == kDrawFill) {
        [self.image drawInRect:rect];
    } else if (self.drawMode == kDrawCenter){
        CGSize size = image.size;
        float scaleW = size.width/rect.size.width;
        float scaleH = size.height/rect.size.height;
        
        float scale = MIN(scaleW, scaleH);
        
        if (scale >= 1.0) {
            scale = 1.0/MAX(scaleW, scaleH);
        }
        CGRect _rect = CGRectMake((int)((rect.size.width - size.width*scale)/2), 
                                  (int)((rect.size.height - size.height*scale)/2), 
                                  (int)size.width * scale,
                                  (int)size.height * scale);
        [self.image drawInRect:_rect];
    }
}

- (void)paintLine:(CGContextRef)context {
    if (self.points.count < 2) {
        return;
    }
    CGContextSetLineWidth(context, self.brushWide);
    CGContextSetStrokeColorWithColor(context, self.strokerColor.CGColor);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    
    CGPoint startPoint;
    NSDictionary* dic = [self.points objectAtIndex:0];
    startPoint.x = (int)[[dic objectForKey:@"x"] floatValue];
    startPoint.y = (int)[[dic objectForKey:@"y"] floatValue];
    CGPoint endPoint = CGPointMake(startPoint.x, startPoint.y);
    if (self.points.count > 1) {
        dic = [self.points objectAtIndex:self.points.count-1];
        endPoint.x = (int)[[dic objectForKey:@"x"] floatValue];
        endPoint.y = (int)[[dic objectForKey:@"y"] floatValue];
    }
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);  
}

- (void)paintEclipse:(CGContextRef)context {
    if (self.points.count < 2) {
        return;
    }
    CGContextSetLineWidth(context, self.brushWide);
    CGContextSetStrokeColorWithColor(context, self.strokerColor.CGColor);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    
    CGPoint startPoint;
    NSDictionary* dic = [self.points objectAtIndex:0];
    startPoint.x = (int)[[dic objectForKey:@"x"] floatValue];
    startPoint.y = (int)[[dic objectForKey:@"y"] floatValue];
    CGPoint endPoint = CGPointMake(startPoint.x, startPoint.y);
    if (self.points.count > 1) {
        dic = [self.points objectAtIndex:self.points.count-1];
        endPoint.x = (int)[[dic objectForKey:@"x"] floatValue];
        endPoint.y = (int)[[dic objectForKey:@"y"] floatValue];
    }
    CGRect rectangle = CGRectMake(MIN(startPoint.x, endPoint.x), 
                                  MIN(startPoint.y, endPoint.y),
                                  ABS(endPoint.x - startPoint.x),
                                  ABS(endPoint.y - startPoint.y));
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
    rectangle = CGRectMake(rectangle.origin.x + self.brushWide/2, 
                           rectangle.origin.y + self.brushWide/2, 
                           rectangle.size.width - self.brushWide,
                           rectangle.size.height - self.brushWide);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextFillPath(context);
}

- (void)paintRect:(CGContextRef)context{
    if (self.points.count < 2) {
        return;
    }
    
    CGContextSetLineWidth(context, self.brushWide);
    CGContextSetStrokeColorWithColor(context, self.strokerColor.CGColor);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    
    CGPoint startPoint;
    NSDictionary* dic = [self.points objectAtIndex:0];
    startPoint.x = (int)[[dic objectForKey:@"x"] floatValue];
    startPoint.y = (int)[[dic objectForKey:@"y"] floatValue];
    CGPoint endPoint = CGPointMake(startPoint.x, startPoint.y);
    if (self.points.count > 1) {
        dic = [self.points objectAtIndex:self.points.count-1];
        endPoint.x = (int)[[dic objectForKey:@"x"] floatValue];
        endPoint.y = (int)[[dic objectForKey:@"y"] floatValue];
    }
    CGRect rectangle = CGRectMake(MIN(startPoint.x, endPoint.x), 
                                  MIN(startPoint.y, endPoint.y),
                                  ABS(endPoint.x - startPoint.x),
                                  ABS(endPoint.y - startPoint.y));
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
    rectangle = CGRectMake(rectangle.origin.x + self.brushWide/2, 
                           rectangle.origin.y + self.brushWide/2, 
                           rectangle.size.width - self.brushWide,
                           rectangle.size.height - self.brushWide);
    CGContextAddRect(context, rectangle);
    CGContextFillPath(context);
}

-(void)paintDots:(CGContextRef)context {
    CGContextSetLineWidth(context, self.brushWide);
    CGContextSetLineCap(context, kCGLineCapRound);
    if (self.type == kFigureDot) {
        CGContextSetStrokeColorWithColor(context, self.strokerColor.CGColor);
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    } else if (self.type == kFigureClear) {
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);        
    }
    for (int i = 0; i < self.points.count; i ++) {
        NSDictionary* dic = [self.points objectAtIndex:i];
        CGPoint point = CGPointMake([[dic objectForKey:@"x"] floatValue], 
                                    [[dic objectForKey:@"y"] floatValue]);
        if (i == 0) {
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
            CGContextAddLineToPoint(context, point.x, point.y);   
        }
    }
    if (self.points.count == 1) {
        NSDictionary* dic = [self.points objectAtIndex:0];
        CGPoint point = CGPointMake([[dic objectForKey:@"x"] floatValue], 
                                    [[dic objectForKey:@"y"] floatValue]);
        CGContextAddLineToPoint(context, point.x, point.y);   
    }
    CGContextStrokePath(context);
}

-(void)draw:(CGContextRef)context inRect:(CGRect)rect{
    switch (self.type) {
        case kFigureClear:
        case kFigureDot:
            ;
            [self paintDots:context];
            break;
        case kFigureLine:
            ;
            [self paintLine:context];
            break;
        case kFigureEclipse:
            ;
            [self paintEclipse:context];
            break;
        case kFigureRect:
            ;
            [self paintRect:context];
            break;
        case kFigureImage:
            ;
            [self paintImage:context inRect:rect];
            break;
        case kFigureText:
            ;
            [self paintText:context inRect:rect];
            break;
        case kFigureClearAll:
            ;
            [self paintClearAll:context inRect:rect];
            break;
        default:
            break;
    }
}

- (id)copy {
    PaintPath* obj = [[PaintPath alloc] init];
    obj.type = self.type;
    obj.fillColor = self.fillColor;
    obj.strokerColor = self.strokerColor;
    obj.brushWide = self.brushWide;
    obj.shadowWide = self.shadowWide;
    obj.points = [self.points mutableCopy];
    obj.text = [self.text copy];
    obj.image = [self.image copy];
    obj.font = self.font;
    return obj;
}
@end
