//==============================================================================
//
//  InfColorPickerController.h
//  InfColorPicker
//
//  Created by Troy Gaul on 7 Aug 2010.
//
//  Copyright (c) 2011 InfinitApps LLC - http://infinitapps.com
//	Some rights reserved: http://opensource.org/licenses/MIT
//
//==============================================================================

#import <UIKit/UIKit.h>

@class InfColorBarView;
@class InfColorSquareView;
@class InfColorBarPicker;
@class InfColorSquarePicker;

@protocol ColorPickerControllerDelegate;

//------------------------------------------------------------------------------

@interface ColorPickerController : UIViewController {
	float red;
	float green;
	float blue;
    float alpha;
    IBOutlet UIButton* backBtn;
    UIButton* activedBtn;
}
	// Public API:

+ (ColorPickerController*) colorPickerViewController;
+ (CGSize) idealSizeForViewInPopover;

- (void) presentModallyOverViewController: (UIViewController*) controller;

@property( retain, nonatomic ) UIColor* sourceColor;
@property( retain, nonatomic ) UIColor* resultColor;
@property(nonatomic, assign) BOOL hideBg;

@property( assign, nonatomic ) id<ColorPickerControllerDelegate > delegate;
@property( retain, nonatomic ) IBOutlet InfColorBarPicker* alphaPicker;
@property( retain, nonatomic ) IBOutlet UIView* colorsView;

@property( retain, nonatomic ) IBOutlet UINavigationController* navController;

-(IBAction)back:(id)sender;

@end

//------------------------------------------------------------------------------

@protocol ColorPickerControllerDelegate

@optional

- (void) colorPickerControllerFinished: (ColorPickerController*) controller;
	// This is only called when the color picker is presented modally.

- (void) colorPickerControllerDidChangeColor: (ColorPickerController*) controller;

@end

//------------------------------------------------------------------------------
