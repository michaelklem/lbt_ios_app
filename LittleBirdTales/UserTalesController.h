//
//  TalesController.h
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Tale.h"
#import "InputTaleInfo.h"

@interface UserTalesController : UIViewController <InputTaleInfoDelegate, UIAlertViewDelegate> {
    IBOutlet UIView* taleInfoView;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* authorLabel;
    IBOutlet UILabel* pageLabel;
    IBOutlet UILabel* createdLabel;
    IBOutlet UILabel* modifiedLabel;
    IBOutlet UIButton* newButton;
    IBOutlet UIImageView* previewImage;
    IBOutlet UIScrollView* talesScrollView;
    IBOutlet UIImageView *noTaleBackground;
    Tale *currentTale;
    NSInteger lastTaleIndex;
    NSInteger currentTaleIndex;
    IBOutlet UISegmentedControl *controlTab;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction)leftSideMenuButtonPressed:(id)sender;
- (void)reloadTaleList;
- (void)selectTale:(id)sender;
- (IBAction)newTale:(id)sender;
- (IBAction)editTale:(id)sender;
- (IBAction)uploadTale:(id)sender;
- (IBAction)deleteTale:(id)sender;
- (IBAction)playTale:(id)sender;
- (IBAction)downloadTales:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)tabChange:(id)sender;
@end
