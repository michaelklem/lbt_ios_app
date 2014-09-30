//==============================================================================
//
//  MainViewController.m
//  InfColorPicker
//
//  Created by Troy Gaul on 7 Aug 2010.
//
//  Copyright (c) 2011 InfinitApps LLC - http://infinitapps.com
//	Some rights reserved: http://opensource.org/licenses/MIT
//
//==============================================================================

#import <QuartzCore/QuartzCore.h>
#import "ColorPickerController.h"
#import "ColorPickerImageView.h"
#import "InfColorBarPicker.h"
#import "InfColorSquarePicker.h"
#import "InfHSBSupport.h"
#import "UIImage+ColorAtPixel.h"
//------------------------------------------------------------------------------

static void HSVFromUIColor( UIColor* color, float* h, float* s, float* v )
{
	CGColorRef colorRef = [ color CGColor ];
	
	const CGFloat* components = CGColorGetComponents( colorRef );
	size_t numComponents = CGColorGetNumberOfComponents( colorRef );
	
	CGFloat r, g, b;
	if( numComponents < 3 ) {
		r = g = b = components[ 0 ];
	}
	else {
		r = components[ 0 ];
		g = components[ 1 ];
		b = components[ 2 ];
	}
	
	RGBToHSV( r, g, b, h, s, v, YES );
}

//==============================================================================

@interface ColorPickerController()

- (void) updateResultColor;

// Outlets and actions:

- (IBAction) takeAlphaValue: (id) sender;
- (IBAction) done: (id) sender;

@end

//==============================================================================

@implementation ColorPickerController

//------------------------------------------------------------------------------

@synthesize delegate, resultColor, sourceColor;
@synthesize navController, alphaPicker, colorsView, hideBg;

//------------------------------------------------------------------------------
#pragma mark	Class methods
//------------------------------------------------------------------------------

+ (ColorPickerController*) colorPickerViewController
{
	return [  [ ColorPickerController alloc ] initWithNibName: @"ColorPickerController" bundle: nil  ];
}

//------------------------------------------------------------------------------

+ (CGSize) idealSizeForViewInPopover
{
	return CGSizeMake( 256 + ( 1 + 20 ) * 2, 420 );
}

//------------------------------------------------------------------------------
#pragma mark	Memory management
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark	Creation
//------------------------------------------------------------------------------

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
	self = [ super initWithNibName: nibNameOrNil bundle: nibBundleOrNil ];
	
	if( self ) {
		self.navigationItem.title = NSLocalizedString( @"Set Color", 
									@"ColorPicker default nav item title" );
	}
	
	return self;
}

//------------------------------------------------------------------------------

-(IBAction)back:(id)sender {
    if (!IsIdiomPad && self.delegate) {
        [self.delegate colorPickerControllerFinished:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)colorPicked:(id)sender {
    if (activedBtn) {
        activedBtn.layer.borderColor = [UIColor blackColor].CGColor;
        activedBtn.layer.borderWidth = 1.0f;
    }
    activedBtn = sender;
    activedBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    activedBtn.layer.borderWidth = 3.0f;
    
    
    const CGFloat *rgb = CGColorGetComponents(activedBtn.backgroundColor.CGColor);
    
    red = rgb[0];
    green = rgb[1];
    blue = rgb[2];
    
    [self updateResultColor];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void) viewDidLoad
{
	[ super viewDidLoad ];

	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    alphaPicker.value = alpha;
    if (IsIdiomPad) {
        [backBtn setHidden:YES];
    }
    if (hideBg) {
        for (UIView* aView in self.view.subviews) {
            if ([aView isKindOfClass:[UIImageView class]]) {
                aView.hidden = YES;
            }
        }
    }
    
    int num = 6 * 23;
    UIImage* barImg = [UIImage imageNamed:@"color_bar"];
    
    int width = barImg.size.width;
    int height = barImg.size.height;
    
    for (int i = 0; i < num; i ++) {
        int col = i % 23;
        int row = (int)(i / 23);
        int x = (int)((width/23.0)* col + (width/46.0));
        int y = (int)((height/6.0)* row + (height/12.0));        
        
        UIColor* color = [barImg colorAtPixel:CGPointMake(x, y)];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.layer.borderWidth = 1.0f;
        [btn addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(col * 20, row * 20, 20, 20);
        btn.backgroundColor = color;
        [colorsView addSubview:btn];
        const CGFloat *rgb = CGColorGetComponents(color.CGColor);
        if( (roundf(red * 255)   == roundf(rgb[0] * 255)) && 
            (roundf(green * 255) == roundf(rgb[1] * 255)) && 
            (roundf(blue * 255)  == roundf(rgb[2] * 255)) )  {
                [self colorPicked:btn];                 
        }
    }
}

//------------------------------------------------------------------------------

- (void) viewDidUnload
{
	[ super viewDidUnload ];
	
	// Release any retained subviews of the main view.	
	self.navController = nil;
}

//------------------------------------------------------------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

//------------------------------------------------------------------------------

- (void) presentModallyOverViewController: (UIViewController*) controller
{
	UINavigationController* nav = [ [ UINavigationController alloc ] initWithRootViewController: self ];
	
	nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	self.navigationItem.rightBarButtonItem = [ [ UIBarButtonItem alloc ] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector( done: ) ];
				
    [controller presentViewController:nav animated:YES completion:nil];
}

//------------------------------------------------------------------------------
#pragma mark	IB actions
//------------------------------------------------------------------------------

- (IBAction) takeAlphaValue: (InfColorBarPicker*) sender {
    alpha = sender.value;
    [ self updateResultColor ];
}

//------------------------------------------------------------------------------

- (IBAction) done: (id) sender
{
	[ self.delegate colorPickerControllerFinished: self ];	
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) informDelegateDidChangeColor
{
	if( self.delegate && [ (id) self.delegate respondsToSelector: @selector( colorPickerControllerDidChangeColor: ) ] )
		[ self.delegate colorPickerControllerDidChangeColor: self ];
}

//------------------------------------------------------------------------------

- (void) updateResultColor
{
	// This is used when code internally causes the update.  We do this so that
	// we don't cause push-back on the HSV values in case there are rounding
	// differences or anything.  However, given protections from hue and sat
	// changes when not necessary elsewhere it's probably not actually needed.
	
	[ self willChangeValueForKey: @"resultColor" ];
	
	resultColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha ];
	
	[ self didChangeValueForKey: @"resultColor" ];
		
	[ self informDelegateDidChangeColor ];
}

//------------------------------------------------------------------------------

- (void) setResultColor: (UIColor*) newValue
{
	if( ![resultColor isEqual: newValue ] ) {
		resultColor = newValue;
		
        const CGFloat *rgb = CGColorGetComponents(newValue.CGColor);
        red = rgb[0];
        green = rgb[1];
        blue = rgb[2];
        alpha = rgb[3];
        alphaPicker.value = alpha;
        
		[ self informDelegateDidChangeColor ];
	}
}

//------------------------------------------------------------------------------

- (void) setSourceColor: (UIColor*) newValue
{
	if( ![ sourceColor isEqual: newValue ] ) {
		sourceColor = newValue;
				
        const CGFloat* components = CGColorGetComponents(sourceColor.CGColor);
        alpha = components[3];
		self.resultColor = newValue;
	}
}

//------------------------------------------------------------------------------
#pragma mark	UIViewController( UIPopoverController ) methods
//------------------------------------------------------------------------------

- (CGSize) contentSizeForViewInPopover
{
	return [ [ self class ] idealSizeForViewInPopover ];
}

//------------------------------------------------------------------------------

@end

//==============================================================================
