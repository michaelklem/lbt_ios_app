//
//  FontController.h
//  LittleBirdTales
//
//  Created by Mac on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FontController;
@protocol FontControllerDelegate 
-(void)fontDidSelected:(FontController*)sender;
@end

@interface FontController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    IBOutlet UIPickerView* fontPicker;
    IBOutlet UISlider* fontSizeSlider;
    IBOutlet UILabel* fontLabel;
    NSMutableArray* fonts;
    IBOutlet UIButton* backBtn;
}
@property (nonatomic, assign) id <FontControllerDelegate> delegate;
@property (nonatomic, retain) NSString* fontName;
@property (nonatomic, assign) float fontSize;
-(IBAction)fontSizeChanged:(id)sender;
-(IBAction)back:(id)sender;
@end
