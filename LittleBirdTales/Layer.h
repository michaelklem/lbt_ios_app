//
//  Layer.h
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PADDING 5
#define MAX_SCALE
#define END_SCALE
#define MOVINGPADDING 0.2
#define MINWIDTH 100
#define MINHEIGHT 100

typedef enum {
    kResizeTop,
    kResizeTopLeft,
    kResizeTopRight,
    kResizeBottom,
    kResizeBottomLeft,
    kResizeBottomRight,
    kResizeLeft, 
    kResizeRight,
    kMove
}kResize;
@protocol LayerDelegate
@required
-(void)select:(id)sender;
@end 
    
@interface Layer : UIControl <UIGestureRecognizerDelegate> {
    float _lastScale;
    CGSize size;
    CGPoint oldPoint;
    CGPoint prePoint;
    kResize resizeAction;
}
@property (nonatomic, assign) id <LayerDelegate> delegate;
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) BOOL isSelected;

@end
