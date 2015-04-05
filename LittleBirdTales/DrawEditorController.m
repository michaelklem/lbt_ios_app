//
//  DrawController.m
//  LittleBirdTales
//
//  Created by Mac on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "DrawEditorController.h"
#import "BottomLayer.h"
#import "RectangleLayer.h"
#import "CircleLayer.h"
#import "TextLayer.h"
#import "ImageLayer.h"
#import "ColorHelper.h"
#import "PaintPath.h"
#import "Gallery.h"
//#import "UIImage+FillPath.h"
#import "UIFillImage.h"
#import "UAMacros.h"
#define IMAGETAG 101
@interface DrawEditorController ()
-(void)updateColors;
@end

@implementation DrawEditorController
@synthesize page, popoverController, delegate;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.page saveImage:[paintView toImage]];
        [self.page setModified:round([[NSDate date] timeIntervalSince1970])];
        if (self.delegate) {
            [self.delegate drawPageSaved];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (buttonIndex == 2){
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == 3491832) {
        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
        if (canOpenSettings)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

-(IBAction)back:(id)sender {
    if ([paintView isChanged] && changed) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" 
                                                            message:@"Do you want to save your changes?" 
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Yes", @"No", nil];
        [alertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - View lifecycle
- (CGRect)halfOfBounds {
    CGRect rect = layerManger.bounds;
    rect.size.width = (int)rect.size.width/2;
    rect.size.height = (int)rect.size.height/2;
    rect.origin.x = (int)(layerManger.bounds.size.width - rect.size.width)/2;
    rect.origin.y = (int)(layerManger.bounds.size.height - rect.size.height)/2;
    return rect;
}

-(IBAction)alphaChanged:(id)sender {
    [ColorHelper shared].alpha = alphaSlider.value;
    [self updateColors];
}

-(IBAction)brushChanged:(id)sender {
    [ColorHelper shared].lineWide = brushSlider.value;
    touchView.paintPath.brushWide = brushSlider.value;
}
-(IBAction)shadowChanged:(id)sender {
    [ColorHelper shared].shadow = shadownSlider.value;
    touchView.paintPath.shadowWide = shadownSlider.value;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [titleLabel setText:_taleTitle];
    if([[Lib getValueOfKey:@"is_tales_view"] isEqualToString:@"true"] ) {
        self.view.backgroundColor = [UIColor colorWithRed:1 green:0.631 blue:0.31 alpha:1];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithRed:0.094 green:0.58 blue:0.09 alpha:1];
    }
    if (!IsIdiomPad) {
    //ScrollView
        [scrollView setZoomScale:0.5];
        [scrollView setMaximumZoomScale:0.5];
        [scrollView setMinimumZoomScale:0.5];
    }
    
    layerManger = [[LayerManager alloc] initWithFrame:drawingView.bounds];
    [drawingView addSubview:layerManger];
    bottomLayer = [[BottomLayer alloc] initWithFrame:layerManger.bounds];
    bottomLayer.imageView.image = [self.page pageImage];
    [layerManger addSubview:bottomLayer];
    bottomLayer.delegate = layerManger;
    
    paintView = [[PaintView alloc] initWithFrame:layerManger.bounds];
    paintView.backgroundColor = [UIColor whiteColor];
    [layerManger addSubview:paintView];
    NSLog(@"Draw did load.2");
    // insert BG image 
    UIImage* image = [self.page pageImage];
    PaintPath* path = [[PaintPath alloc] init];
    path.type = kFigureImage;
    path.image = image;
    [paintView addPath:path];
    
    
    touchView = [[TouchView alloc] initWithFrame:layerManger.bounds];
    touchView.backgroundColor = [UIColor clearColor];
    [layerManger addSubview:touchView];
    touchView.delegate = self;
    
    edgeColorView.backgroundColor = [ColorHelper colorWithNoAlpha:[ColorHelper shared].edgeColor];
    if ([ColorHelper isBrightnessColor:edgeColorView.backgroundColor]) {
        edgeColorView.textColor = [UIColor blackColor];
    } else {
        edgeColorView.textColor = [UIColor whiteColor];
    }

    fillColorView.backgroundColor = [ColorHelper colorWithNoAlpha:[ColorHelper shared].fillColor];
    if ([ColorHelper isBrightnessColor:fillColorView.backgroundColor]) {
        fillColorView.textColor = [UIColor blackColor];
    } else {
        fillColorView.textColor = [UIColor whiteColor];
    }
    NSLog(@"Draw did load.3");
    touchView.paintPath.brushWide = brushSlider.value = [ColorHelper shared].lineWide;
    touchView.paintPath.shadowWide = shadownSlider.value = [ColorHelper shared].shadow;
    touchView.paintPath.font = fontView.font = [UIFont fontWithName:[ColorHelper shared].fontName
                                                               size:[ColorHelper shared].fontSize]; 
    
    [brushSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateNormal];
    [brushSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateHighlighted];
    [brushSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateSelected];

    [brushSlider setMinimumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateNormal];
    [brushSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateHighlighted];
    [brushSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateSelected];

    
    [brushSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];   
    [brushSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateHighlighted];    
    [brushSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateSelected];    
    
    [shadownSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];
    [shadownSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateHighlighted];    
    [shadownSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateSelected];    

    [shadownSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateNormal];
    [shadownSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateHighlighted];
    [shadownSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateSelected];
    
    [shadownSlider setMinimumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateNormal];
    [shadownSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateHighlighted];
    [shadownSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateSelected];

    
    [alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateNormal];
    [alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateHighlighted];
    [alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateSelected];
    
    [alphaSlider setMinimumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateNormal];
    [alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateHighlighted];
    [alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"tran"] forState:UIControlStateSelected];
    
    
    [alphaSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];   
    [alphaSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateHighlighted];    
    [alphaSlider setThumbImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateSelected];  
    // Do any additional setup after loading the view from its nib.
    UIButton* btn;
    for (UIView* aView in toolView.subviews) {
        if ([aView isKindOfClass:[UIButton class]] && aView.tag == 0) {
            btn = (UIButton*)aView;
            break;
        }
    }
    
    [self paint:btn];
    touchView.paintPath.type = kFigureDot;
    [self updateColors];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)resetAllBtns {
    for (UIButton* btn in toolView.subviews) {
        [btn setBackgroundImage:[UIImage imageNamed:@"icon_bg@2x.png"] forState:UIControlStateNormal];
    }
}

#pragma TouchViewDelegate 
-(void)inputedText:(NSString*)text {
    if(touchView.paintPath.type == kFigureText) {
        PaintPath* path = [touchView.paintPath copy];
        NSLog(@"FONT: %@ %f: %@",[ColorHelper shared].fontName,
              [ColorHelper shared].fontSize,
              [UIFont fontWithName:[ColorHelper shared].fontName  size:[ColorHelper shared].fontSize]);
        path.font = [UIFont fontWithName:[ColorHelper shared].fontName  size:[ColorHelper shared].fontSize];
        path.text = text;
        [touchView.paintPath.points removeAllObjects];
        [paintView addPath:path];
        [paintView setNeedsDisplay];
        [touchView setNeedsDisplay];
        
        undoBtn.enabled = [paintView canUndo];
        redoBtn.enabled = [paintView canRedo];

        changed = TRUE;

    }
}

-(void)textNeedText {
    InputTextView* tView = [InputTextView viewFromNib:self];
    tView.limited = FALSE;
    tView.delegate = self;
    [tView showInView:self.view];
}

-(void)drawNewFigure:(PaintPath*)paintPath {
    changed = TRUE;
    if (paintPath.type == kFigureFill) {
        UIImage* image =[paintView imageByRenderingView];
        NSDictionary* dic = [paintPath.points objectAtIndex:0];
        CGPoint point;
        point.x = (int)[[dic objectForKey:@"x"] floatValue];
        point.y = (int)[[dic objectForKey:@"y"] floatValue];
        
        UIColor* color = [[ColorHelper shared] fillColor];
        const CGFloat *rgb = CGColorGetComponents(color.CGColor);
        
        float red = rgb[0];
        float green = rgb[1];
        float blue = rgb[2];
        float alpha = 1.0;//CGColorGetAlpha(color.CGColor);
        
        Pixel pixel;
        pixel.red = red*255;
        pixel.green = green*255;
        pixel.blue = blue*255;
        pixel.alpha = alpha*255;
        //@autoreleasepool {
            UIFillImage* fillImage = [[UIFillImage alloc] init];
            paintPath.image = [fillImage fillFlood:point.x:point.y:pixel:image];
        //}
        paintPath.type = kFigureImage;
        paintPath.drawMode = kDrawCenter;
    }
    
    [paintView addPath:paintPath];
    [touchView.paintPath.points removeAllObjects];

    [paintView setNeedsDisplay];
    [touchView setNeedsDisplay];
    
    undoBtn.enabled = [paintView canUndo];
    redoBtn.enabled = [paintView canRedo];
}

#pragma mark - Draw actions 
-(IBAction)paint:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:NO];
    touchView.paintPath.type = kFigureDot;
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
}
-(IBAction)clear:(id)sender { 
    [self resetAllBtns];
    [self objectLayersShow:NO];
    touchView.paintPath.type = kFigureClear;
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
}

-(IBAction)line:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:NO];
    touchView.paintPath.type = kFigureLine;
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
}
-(IBAction)fill:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:NO];
    touchView.paintPath.type = kFigureFill;
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
}

-(IBAction)text:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:YES];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
    touchView.paintPath.type = kFigureText;
}

-(IBAction)circle:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:YES];
    touchView.paintPath.type = kFigureEclipse;
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
}
-(IBAction)rectangle:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:YES];
    touchView.paintPath.type = kFigureRect;
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:@"icon_bg_actived@2x.png"] forState:UIControlStateNormal];    
}

-(IBAction)insertImage:(id)sender {
    [self resetAllBtns];
    [self objectLayersShow:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:@"Choose image"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"From Photo Library"
                                      otherButtonTitles:@"From Gallery", @"Take photo", nil];
        actionSheet.tag = IMAGETAG;
        [actionSheet showInView:self.view];
    } else {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:@"Choose image"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"From Photo Library"
                                      otherButtonTitles:@"From Gallery", nil];
        actionSheet.tag = IMAGETAG;
        [actionSheet showInView:self.view];
    }
}

-(void)objectLayersShow:(BOOL)showed {
    for (UIView* aView in layerManger.subviews) {
        if ([aView isKindOfClass:[TextLayer class]] || 
            [aView isKindOfClass:[RectangleLayer class]] || 
            [aView isKindOfClass:[CircleLayer class]] || 
            [aView isKindOfClass:[ImageLayer class]] ) {
            aView.hidden = showed;
        }
    }
}
        
-(IBAction)clearAll:(id)sender {
    PaintPath* path = [[PaintPath alloc] init];
    path.type = kFigureClearAll;
    [paintView addPath:path];
    [paintView setNeedsDisplay];
    changed = TRUE;
}


-(IBAction)deleteLayer:(id)sender {
    Layer* layer = [layerManger selectedLayer];
    if (layer) {
        [layer removeFromSuperview];
        // TODO: Undo, redo
    }
}

- (void)showLoadingViewOn{
    [Lib showLoadingViewOn:self.view withAlert:@"Saving image..."];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (IsIdiomPad) {
        if (self.popoverController) {
            [self.popoverController dismissPopoverAnimated:YES];
        } else {
            [picker dismissModalViewControllerAnimated:YES];
        }
        [NSTimer scheduledTimerWithTimeInterval: 0
                                         target: self
                                       selector: @selector(showLoadingViewOn)
                                       userInfo: nil
                                        repeats: NO];
        [NSTimer scheduledTimerWithTimeInterval: 0.5f
                                         target: self
                                       selector: @selector(cropImage:)
                                       userInfo: info
                                        repeats: NO];            
    } else {
        [picker dismissModalViewControllerAnimated:YES];  
        [NSTimer scheduledTimerWithTimeInterval: 0
                                         target: self
                                       selector: @selector(showLoadingViewOn)
                                       userInfo: nil
                                        repeats: NO];
        [NSTimer scheduledTimerWithTimeInterval: 0.5f
                                         target: self
                                       selector: @selector(cropImage:)
                                       userInfo: info
                                        repeats: NO];
    }

}

- (void)cropImage:(NSTimer*)theTimer {
    NSDictionary *info = theTimer.userInfo;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        
        UIImage *original = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CropImage* tView = [CropImage viewFromNib:self];
        tView.delegate = self;
        [tView receivingImage:original];
        [tView showInView:self.view];
        
    }
    [Lib removeLoadingViewOn:self.view];
}

- (void)saveImageAs:(UIImage *)image {
    PaintPath* path = [[PaintPath alloc] init];
    path.type = kFigureImage;
    path.drawMode = kDrawCenter;
    path.image = image;
    [paintView addPath:path];
    [paintView setNeedsDisplay];
    
    undoBtn.enabled = [paintView canUndo];
    redoBtn.enabled = [paintView canRedo];
    changed = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == IMAGETAG) {
        if (buttonIndex == 0) { // photo album
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.delegate = self;
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (IsIdiomPad) {
                if (self.popoverController && [self.popoverController isPopoverVisible]) {
                    [self.popoverController dismissPopoverAnimated:NO];
                }
                
                self.popoverController = [[UIPopoverController alloc]
                                          initWithContentViewController:controller];                    
                self.popoverController.delegate = self;
                UIView* aView = (UIView*)insertImageBtn;
                [self.popoverController presentPopoverFromRect:[aView bounds]
                                                        inView:aView
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];            
                
            } else {
                [self presentModalViewController:controller animated:YES];
            }
        } else if (buttonIndex == 1) { // libray
                 
            GalleryTableViewController* controller = [[GalleryTableViewController alloc] init];
            controller.delegate = self;
            controller.title = @"Gallery";
            UINavigationController *nav = [[UINavigationController alloc]
                                           initWithRootViewController:controller];
            if (IsIdiomPad) {
                if (self.popoverController && [self.popoverController isPopoverVisible]) {
                    [self.popoverController dismissPopoverAnimated:NO];
                }
                
                self.popoverController = [[UIPopoverController alloc]
                                          initWithContentViewController:nav];                    
                self.popoverController.delegate = self;
                [self.popoverController setPopoverContentSize:CGSizeMake(345, 465)];
                UIView* aView = (UIView*)insertImageBtn;
                [self.popoverController presentPopoverFromRect:[aView bounds]
                                                        inView:aView
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];            
                
            } else {
                GalleryViewController *galleryController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:nil];
                galleryController.delegate = self;
                [[self navigationController] pushViewController:galleryController animated:YES];
//                [self presentModalViewController:controller animated:YES];
            }

        } else if (buttonIndex == 2) { // take photo
            [self goToCamera];
        }
    }
}

- (IBAction)goToCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        [self popCamera];
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 NSLog(@"Granted access to %@", AVMediaTypeVideo);
                 [self popCamera];
             }
             else
             {
                 NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                 [self camDenied];
             }
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        // My own Helper class is used here to pop a dialog in one simple line.
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:nil];
    }
    else
    {
        [self camDenied];
    }
}

-(void)popCamera {
    BOOL hasLoadedCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (!hasLoadedCamera)
        [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
    else
        [self showcamera];
}

- (void)showcamera {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.showsCameraControls = YES;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)camDenied
{
    NSLog(@"%@", @"Denied camera access");
    
    NSString *alertText;
    NSString *alertButton;
    
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings)
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to take a picture. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Touch Privacy.\n\n3. Turn the Camera on.\n\n4. Open this app and try again.";
        
        alertButton = @"Go";
    }
    else
    {
        alertText = @"It looks like your privacy settings are preventing us from accessing your camera to take a picture. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Touch Privacy.\n\n5. Turn the Camera on.\n\n6. Open this app and try again.";
        
        alertButton = @"OK";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:alertText
                          delegate:self
                          cancelButtonTitle:alertButton
                          otherButtonTitles:nil];
    alert.tag = 3491832;
    [alert show];
}

-(IBAction)undo:(id)sender {
    [paintView undo];
    undoBtn.enabled = [paintView canUndo];
    redoBtn.enabled = [paintView canRedo];
    changed = YES;
    
}
-(IBAction)redo:(id)sender {
    [paintView redo];    
    undoBtn.enabled = [paintView canUndo];
    redoBtn.enabled = [paintView canRedo];
    changed = YES;
}

- (void) colorPickerControllerDidFinish: (InfColorPickerController*) picker {
    if (!IsIdiomPad) {
        if (edgeColorChoosing) {
            edgeColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:edgeColorView.backgroundColor]) {
                edgeColorView.textColor = [UIColor blackColor];
            } else {
                edgeColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].edgeColor = picker.resultColor;
            [self updateColors];
        } else {
            fillColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:fillColorView.backgroundColor]) {
                fillColorView.textColor = [UIColor blackColor];
            } else {
                fillColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].fillColor = picker.resultColor;
            [self updateColors];
        }
    }
}
//
//- (void) colorPickerControllerDidChangeColor: (InfColorPickerController*) controller {
//    if (edgeColorChoosing) {
//        edgeColorView.backgroundColor = controller.resultColor;
//    } else {
//        fillColorView.backgroundColor = controller.resultColor;
//    }    
//}

- (void) popoverControllerDidDismissPopover: (UIPopoverController*) popoverController {
	if( [ self.popoverController.contentViewController isKindOfClass: [ InfColorPickerController class ] ] ) {
		InfColorPickerController* picker = (InfColorPickerController*) self.popoverController.contentViewController;
        if (edgeColorChoosing) {
            edgeColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:edgeColorView.backgroundColor]) {
                edgeColorView.textColor = [UIColor blackColor];
            } else {
                edgeColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].edgeColor = picker.resultColor;
            [self updateColors];
        } else {
            fillColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:fillColorView.backgroundColor]) {
                fillColorView.textColor = [UIColor blackColor];
            } else {
                fillColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].fillColor = picker.resultColor;
            [self updateColors];
        }    

	} else if( [ self.popoverController.contentViewController isKindOfClass: [ ColorPickerController class ] ] ) {
		ColorPickerController* picker = (ColorPickerController*) self.popoverController.contentViewController;
        if (edgeColorChoosing) {
            edgeColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:edgeColorView.backgroundColor]) {
                edgeColorView.textColor = [UIColor blackColor];
            } else {
                edgeColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].edgeColor = picker.resultColor;
            [self updateColors];
        } else {
            fillColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:fillColorView.backgroundColor]) {
                fillColorView.textColor = [UIColor blackColor];
            } else {
                fillColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].fillColor = picker.resultColor;
            [self updateColors];
        }    
        
	} else if( [ self.popoverController.contentViewController isKindOfClass: [ FontController class ] ] ) {
		FontController* picker = (FontController*) self.popoverController.contentViewController;
        [ColorHelper shared].fontName = picker.fontName;
        [ColorHelper shared].fontSize = picker.fontSize;
        fontView.font = [UIFont fontWithName:picker.fontName size:picker.fontSize];
    }
}

-(IBAction)egdeColor:(id)sender {
    if (IsIdiomPad) {
        if (self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:NO];
        }
//        InfColorPickerController* picker = [ InfColorPickerController colorPickerViewController ];
        ColorPickerController* picker = [ColorPickerController colorPickerViewController ];
        picker.hideBg = YES;

        picker.sourceColor = [ColorHelper shared].edgeColor;
        
        self.popoverController = [ [ UIPopoverController alloc ] initWithContentViewController: picker];
        self.popoverController.delegate = self;
        [self.popoverController setPopoverContentSize:CGSizeMake(480, 320)];

        UIView* aView = (UIView*)sender;
        edgeColorChoosing = TRUE;
        [self.popoverController presentPopoverFromRect: [ aView bounds ] 
										inView: aView 
					  permittedArrowDirections: UIPopoverArrowDirectionAny 
									  animated: YES ];
        picker.delegate = self;

    } else {
//        InfColorPickerController* picker = [ InfColorPickerController colorPickerViewController ];
//        picker.sourceColor = [ColorHelper shared].edgeColor;
//        edgeColorChoosing = TRUE;
//        picker.delegate = self;
//        [self.navigationController pushViewController:picker animated:YES];
        
        ColorPickerController* picker = [ColorPickerController colorPickerViewController ];
        picker.sourceColor = [ColorHelper shared].edgeColor;
        picker.delegate = self;
        edgeColorChoosing = TRUE;
        [self.navigationController pushViewController:picker animated:YES];

    }
}
-(IBAction)fillColor:(id)sender {
    if (IsIdiomPad) {
        if (self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:NO];
        }
        ColorPickerController* picker = [ColorPickerController colorPickerViewController ];
        picker.hideBg = YES;
        picker.sourceColor = [ColorHelper shared].fillColor;

//        InfColorPickerController* picker = [ InfColorPickerController colorPickerViewController ];
//        picker.sourceColor = [ColorHelper shared].fillColor;
        self.popoverController = [ [ UIPopoverController alloc ] initWithContentViewController: picker];
        self.popoverController.delegate = self;
        [self.popoverController setPopoverContentSize:CGSizeMake(480, 320)];

        UIView* aView = (UIView*)sender;
        edgeColorChoosing = FALSE;
        [self.popoverController presentPopoverFromRect: [ aView bounds ] 
                                                inView: aView 
                              permittedArrowDirections: UIPopoverArrowDirectionAny 
                                              animated: YES ];
        picker.delegate = self;
    } else {
//        InfColorPickerController* picker = [ InfColorPickerController colorPickerViewController ];
//        picker.sourceColor = [ColorHelper shared].fillColor;
//        picker.delegate = self;
//        edgeColorChoosing = FALSE;
//        [self.navigationController pushViewController:picker animated:YES];
        ColorPickerController* picker = [ColorPickerController colorPickerViewController ];
        picker.sourceColor = [ColorHelper shared].fillColor;
        picker.delegate = self;
        edgeColorChoosing = FALSE;
        [self.navigationController pushViewController:picker animated:YES];

    }
}
-(void)updateColors {
    UIColor* color = [ColorHelper shared].edgeColor; 
    
    const CGFloat *rgb = CGColorGetComponents(color.CGColor);
    float red = rgb[0];
    float green = rgb[1];
    float blue = rgb[2];
    float alpha = rgb[3];
    //[ColorHelper shared].alpha;
    
    touchView.paintPath.fillColor = [ColorHelper shared].fillColor; 
    //[UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    touchView.paintPath.strokerColor =  [UIColor colorWithRed:red green:green blue:blue alpha:alpha]; 
}

- (void) colorPickerControllerFinished: (ColorPickerController*) picker {
    if (!IsIdiomPad) {
        if (edgeColorChoosing) {
            edgeColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            if ([ColorHelper isBrightnessColor:edgeColorView.backgroundColor]) {
                edgeColorView.textColor = [UIColor blackColor];
            } else {
                edgeColorView.textColor = [UIColor whiteColor];
            }
            [ColorHelper shared].edgeColor = picker.resultColor;
            [self updateColors];
        } else {
            fillColorView.backgroundColor = [ColorHelper colorWithNoAlpha:picker.resultColor];
            [ColorHelper shared].fillColor = picker.resultColor;
            [self updateColors];
            if ([ColorHelper isBrightnessColor:fillColorView.backgroundColor]) {
                fillColorView.textColor = [UIColor blackColor];
            } else {
                fillColorView.textColor = [UIColor whiteColor];
            }
        }
    }
}

-(void)fontDidSelected:(FontController*)picker {
    [ColorHelper shared].fontName = picker.fontName;
    [ColorHelper shared].fontSize = picker.fontSize;
    fontView.font = [UIFont fontWithName:picker.fontName size:picker.fontSize];    
}

-(IBAction)font:(id)sender {
    if (IsIdiomPad) {
        if (self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:NO];
        }
        FontController * picker = [[FontController alloc] initWithNibName:@"FontController" bundle:nil];
        picker.fontName = [ColorHelper shared].fontName;
        picker.fontSize = [ColorHelper shared].fontSize;
        
        self.popoverController = [ [ UIPopoverController alloc ] initWithContentViewController: picker];
        [self setContentSizeForViewInPopover:CGSizeMake(320, 416)];
        self.popoverController.delegate = self;
        
        UIView* aView = (UIView*)sender;
        [self.popoverController presentPopoverFromRect: [ aView bounds ] 
                                                inView: aView 
                              permittedArrowDirections: UIPopoverArrowDirectionAny 
                                              animated: YES ];
    } else {
        FontController * picker = [[FontController alloc] initWithNibName:@"FontController" bundle:nil];
        picker.fontName = [ColorHelper shared].fontName;
        picker.fontSize = [ColorHelper shared].fontSize;
        picker.delegate = self;
        [self.navigationController pushViewController:picker animated:YES];
    }
}

-(IBAction)save:(id)sender {
    changed = FALSE;
    if (self.delegate) {
        [self.delegate drawPageSaved];
    }
    [self.page saveImage:[paintView toImage]];
    [Gallery saveImage:[paintView toImage]];
    [self.page setModified:round([[NSDate date] timeIntervalSince1970])];
    [Lib showAlert:@"A Little Bird Tale" withMessage:@"Image has been saved"];
}

- (void) selectImage:(NSString *)imageName {
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@",[Gallery dir],imageName];
    UIImage *original = [UIImage imageWithContentsOfFile:filePath];
    
    CropImage* tView = [CropImage viewFromNib:self];
    tView.delegate = self;
    [tView receivingImage:original];
    [tView showInView:self.view];
    
    if (IsIdiomPad) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return drawingView;
}

@end
