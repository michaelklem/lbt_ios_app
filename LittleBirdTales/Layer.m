//
//  Layer.m
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Layer.h"
#import <QuartzCore/QuartzCore.h>

@implementation Layer
@synthesize isSelected, scale, delegate;

- (void)setIsSelected:(BOOL)_isSelected {
    isSelected = _isSelected;
    if (!isSelected) {
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        self.layer.borderWidth = 4.0;
        self.layer.borderColor = [UIColor blueColor].CGColor;
    }
}
-(void)onClick:(id)sender {
    if (self.delegate) {
        [self.delegate select:self];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        resizeAction = kMove;
        scale = 1.0;
        self.backgroundColor = [UIColor clearColor];
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [pinchRecognizer setDelegate:self];
        [self addGestureRecognizer:pinchRecognizer];
        size = self.frame.size;
        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
#pragma mark - touches 
-(void)updateResizeAction:(CGPoint)point {
    if (point.y < self.frame.size.height * MOVINGPADDING) {
        if (point.x < self.frame.size.width * MOVINGPADDING) {
            resizeAction = kResizeTopRight;
            return;
        } else if (point.x > self.frame.size.width * (1.0 - MOVINGPADDING)) {
            resizeAction = kResizeTopLeft;
            return;
        } else {
            resizeAction = kResizeTop;
            return;
        }
    } else if (point.y > self.frame.size.height * (1 - MOVINGPADDING)) {
        if (point.x < self.frame.size.width * MOVINGPADDING) {
            resizeAction = kResizeBottomRight;
            return;
        } else if (point.x > self.frame.size.width * (1.0 - MOVINGPADDING)) {
            resizeAction = kResizeBottomLeft;
            return;
        } else {
            resizeAction = kResizeBottom;
            return;
        }
    } else if (point.x < self.frame.size.width * MOVINGPADDING) {
        resizeAction = kResizeLeft;
        return;
    } else if (point.x > self.frame.size.width * (1 -MOVINGPADDING)) {
        resizeAction = kResizeRight;
        return;
    }
    resizeAction = kMove;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([touches count] == 1) {
        UITouch* touch = [touches anyObject];
        oldPoint = [touch locationInView:self];
        prePoint = oldPoint;
        [self updateResizeAction:oldPoint];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if ([touches count] == 1) {
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGRect frame = self.frame;
        switch (resizeAction) {
            case kMove:
                ;
                frame.origin.x += point.x - oldPoint.x;
                frame.origin.y += point.y - oldPoint.y;
                self.frame = frame;
                break;
            case kResizeLeft:
                ;
                frame.origin.x += point.x - oldPoint.x;
                frame.size.width -= point.x - oldPoint.x;
                prePoint = point;
                if (frame.size.width > MINWIDTH && 
                    frame.origin.x > 0) {
                    self.frame = frame;
                }
                break;
            case kResizeRight:
                ;
                frame.size.width += point.x - prePoint.x;
                prePoint = point;
                if (frame.size.width >= MINWIDTH) {
                    self.frame = frame;                    
                }
                break;
            case kResizeTop:
                ;
                frame.size.height -= point.y - oldPoint.y;
                frame.origin.y += point.y - oldPoint.y;
                prePoint = point;
                if (frame.size.height >= MINHEIGHT && frame.origin.y >= 0) {
                    self.frame = frame;                    
                }
                break;
            case kResizeBottom:
                ;
                frame.size.height += point.y - prePoint.y;
                //frame.origin.y -= point.y - prePoint.y;
                prePoint = point;
                if (frame.size.height >= MINHEIGHT && frame.origin.y >= 0) {
                    self.frame = frame;                    
                }
                break;

            default:
                break;
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([touches count] == 1) {
            //TODO: register undo action
    }
}

#pragma mark - Scaling
-(void)setScale:(float)_scale {
    if (![[[self class] description] isEqualToString:@"BottomLayer"]) {
        scale = _scale;
        CGSize newSize = CGSizeMake((int)size.width * _scale, size.height * _scale);
        if (newSize.width > MINWIDTH && newSize.height > MINHEIGHT) {
            CGPoint _center = self.center;
            self.frame = CGRectMake(0, 0, newSize.width
                                    , newSize.height);            
            self.center = _center;
        }
        
    }
}
-(void)scale:(id)sender {
    if (!self.isSelected) {
        return;
    }
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = self.scale;
        return;
    }
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        return;
    }
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateCancelled) {
        
        return;
    }
    
    float _scale = [(UIPinchGestureRecognizer*)sender scale]; 
    self.scale = _lastScale * _scale;    
}
@end
