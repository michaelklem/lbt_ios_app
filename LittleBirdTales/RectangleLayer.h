//
//  RectangleLayer.h
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Layer.h"
@interface RectangleLayer : Layer
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, retain) UIColor* edgeColor;
@property (nonatomic, assign) float lineWidth;
@end
