//
//  PaintView.m
//  Test123
//
//  Created by Mac on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
#import <QuartzCore/QuartzCore.h>
#define MAX_UNDO 10

@implementation UIView(Extended)
- (UIImage *) imageByRenderingView {
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resultingImage;
}
@end

@implementation PaintView

-(BOOL)isChanged {
    return [paths count] > 1;
}

-(void)addPath:(PaintPath*)path {
    [paths addObject:path];
    undoCount -= 1;
    if (undoCount < 0) {
        undoCount = 0;
    }
}

-(BOOL)canUndo {
    return ([paths count] > 1 && undoCount < MAX_UNDO);
}
-(BOOL)canRedo {
    return ([undoPaths count] > 0);
}
-(void)undo { 
    if (undoCount >= MAX_UNDO) {
        return;
    }
    undoCount += 1;
    if (paths.count > 1) {
        PaintPath* path = [paths lastObject];
        [paths removeObject:path];
        if (undoPaths.count >= MAX_UNDO) {
            [undoPaths removeObjectAtIndex:0];
        } 
        [undoPaths addObject:path];
        [self setNeedsDisplay];
    }
}    
-(void)redo {
    if (undoPaths.count > 0) {
        PaintPath* path = [undoPaths lastObject];
        [undoPaths removeObject:path];
        [paths addObject:path];
        undoCount -= 1;
        if (undoCount < 0) {
            undoCount = 0;
        }
        [self setNeedsDisplay];
    }
}

-(UIImage*)toImage {
    return [self imageByRenderingView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        paths = [[NSMutableArray alloc] init];
        undoPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();  
    for (PaintPath* path in paths) {
        [path draw:context inRect:rect];
    }
}

@end
