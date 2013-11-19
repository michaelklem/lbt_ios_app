//
//  OCProgress.h
//  ProgressView
//
//  Created by Brian Harmann on 7/24/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OCProgress : UIView {
	float minValue, maxValue;
	float currentValue;
	UIColor *lineColor, *progressRemainingColor, *progressColor;
}

@property (nonatomic, retain) UIColor *lineColor, *progressRemainingColor, *progressColor;

-(void)setNewRect:(CGRect)newFrame;
-(void)setMinValue:(float)newMin;
-(void)setMaxValue:(float)newMax;
-(void)setCurrentValue:(float)newValue;

@end
