//
//  CropImage.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CropImage.h"

@implementation CropImage
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(CropImage*)viewFromNib:(id)owner {
    NSString* nibName = @"CropImage";
    if (IsIdiomPad) {
        nibName = @"CropImage-iPad";
    } else {
        nibName = @"CropImage-iPhone";
    }
    
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:nibName
                                                    owner:owner options:nil];
    for (id object in bundle) {
        if ([object isKindOfClass:[CropImage class]]) {
            return object;
        }
    }   
    return nil;
}

- (void)receivingImage:(UIImage*)originalImage {
    if (IsIdiomPad) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 420)];
    } else {
        placeHolder.frame = CGRectMake(0, 0, 600, 420);
        imageView = [[UIImageView alloc] initWithFrame:placeHolder.frame];
        [scrollView setZoomScale:0.5];
        [scrollView setMaximumZoomScale:0.5];
        [scrollView setMinimumZoomScale:0.5];
    }
    
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:originalImage];
    //imageView.frame = CGRectMake(0, 0, 600, image.size.height*600/image.size.width);
    //imageView.center = CGPointMake(300, 210);
    
    imageView.userInteractionEnabled = YES;
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [imageView addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [imageView addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [imageView addGestureRecognizer:panGesture];
    
    [placeHolder addSubview:imageView];
    
    
}

-(void)showInView:(UIView*)aView {
    CGRect frame = self.frame;
    frame.origin.x = frame.origin.y = 0.0;
    self.frame = frame;
    
    NSString *hideOverlay = [Lib getValueOfKey:@"hideOverlay"];
    if ([hideOverlay isEqualToString:@"true"]) {
        overlay.hidden = YES;
    } else {
        overlay.hidden = NO;
        [Lib setValue:@"true" forKey:@"hideOverlay"];
    }
    
    [aView addSubview:self];
}

- (IBAction)hideOverlay:(id)sender{
    overlay.hidden = YES;
}

 

- (IBAction)saveButtonClicked:(id)sender{
    if (!IsIdiomPad) {
        [scrollView setMaximumZoomScale:1];
        [scrollView setMinimumZoomScale:1];
        [scrollView setZoomScale:1];
    }
    UIGraphicsBeginImageContext(placeHolder.frame.size);
	[placeHolder.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    
    if (delegate) {
        [delegate saveImageAs:resultingImage];
    }
    [self cancelButtonClicked:nil];
}
- (IBAction)cancelButtonClicked:(id)sender{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark === Utility methods  ===
#pragma mark

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return placeHolder;
}

// ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously
// prevent other gesture recognizers from recognizing simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}


@end
