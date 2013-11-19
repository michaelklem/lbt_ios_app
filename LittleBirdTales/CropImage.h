//
//  CropImage.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Lib.h"
@protocol CropImageDelegate 
@required 
-(void)saveImageAs:(UIImage*)image;
@end

@interface CropImage : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
    IBOutlet UIView *placeHolder;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *overlay;
    UIImageView *imageView;
    CGFloat netRotation;
}

@property (nonatomic, assign) id <CropImageDelegate> delegate;

+ (CropImage*)viewFromNib:(id)owner;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (void)showInView:(UIView*)aView;
- (void)receivingImage:(UIImage*)originalImage;
- (IBAction)hideOverlay:(id)sender;
@end
