//
//  DrawController.h
//  LittleBirdTales
//
//  Created by Mac on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"
#import "InputTextView.h"
#import "LayerManager.h"
#import "BottomLayer.h"
#import "InfColorPickerController.h"
#import "PaintView.h"
#import "TouchView.h"
#import "GalleryTableViewController.h"
#import "GalleryViewController.h"
#import "CropImage.h"
#import "FontController.h"
#import "ColorPickerController.h"
@protocol DrawControllerDelegate 
-(void)drawPageSaved;
@end

@interface DrawController : UIViewController <InputTextViewDelegate, UIAlertViewDelegate,
UIActionSheetDelegate, 
UIImagePickerControllerDelegate,
UINavigationControllerDelegate, 
UIPopoverControllerDelegate, 
InfColorPickerControllerDelegate, TouchViewDelegate, ColorPickerControllerDelegate,
GalleryDelegate, CropImageDelegate, FontControllerDelegate, GalleryViewDelegate, UIScrollViewDelegate>{
    IBOutlet UIView* drawingView;
    IBOutlet UIButton* insertImageBtn;
    IBOutlet UILabel* edgeColorView;
    IBOutlet UILabel* fillColorView;
    IBOutlet UILabel* fontView;

    IBOutlet UISlider* brushSlider;
    IBOutlet UISlider* shadownSlider;

    IBOutlet UISlider* alphaSlider;

    IBOutlet UIButton* undoBtn;
    IBOutlet UIButton* redoBtn;
    
    IBOutlet UIView* toolView;
    
    IBOutlet UIScrollView *scrollView;
    LayerManager* layerManger;
    BottomLayer* bottomLayer;
    BOOL edgeColorChoosing;
    PaintView* paintView;
    TouchView* touchView;
    BOOL changed;
}
@property (nonatomic, assign) id <DrawControllerDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) Page* page;
-(IBAction)back:(id)sender;
-(IBAction)paint:(id)sender;
-(IBAction)clear:(id)sender;
-(IBAction)line:(id)sender;
-(IBAction)fill:(id)sender;
-(IBAction)text:(id)sender;
-(IBAction)circle:(id)sender;
-(IBAction)rectangle:(id)sender;
-(IBAction)undo:(id)sender;
-(IBAction)redo:(id)sender;
-(IBAction)egdeColor:(id)sender;
-(IBAction)fillColor:(id)sender;
-(IBAction)font:(id)sender;
-(IBAction)brushChanged:(id)sender;
-(IBAction)alphaChanged:(id)sender;

-(IBAction)shadowChanged:(id)sender;

-(IBAction)deleteLayer:(id)sender;
-(IBAction)insertImage:(id)sender;
-(IBAction)clearAll:(id)sender;

-(void)objectLayersShow:(BOOL)showed;
-(IBAction)save:(id)sender;
-(IBAction)saveToGallery:(id)sender;

@end
