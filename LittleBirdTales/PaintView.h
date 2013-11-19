//
//  PaintView.h
//  Test123
//
//  Created by Mac on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintPath.h"

@interface UIView(Paint)
- (UIImage *) imageByRenderingView;
@end
@interface PaintView : UIView {
    NSMutableArray* paths;
    NSMutableArray* undoPaths;
    int undoCount;
}
-(BOOL)isChanged;
-(void)addPath:(PaintPath*)path;
-(UIImage*)toImage;
-(BOOL)canUndo;
-(BOOL)canRedo;
-(void)undo;
-(void)redo;

@end
