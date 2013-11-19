//
//  TouchView.h
//  Test123
//
//  Created by Mac on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintPath.h"
@protocol TouchViewDelegate
-(void)drawNewFigure:(PaintPath*)paintPath;
-(void)textNeedText;
@end
@interface TouchView : UIView {
    CGPoint oldPoint;
}
@property (nonatomic, assign) id <TouchViewDelegate> delegate;
@property (nonatomic, retain) PaintPath* paintPath;
@end
