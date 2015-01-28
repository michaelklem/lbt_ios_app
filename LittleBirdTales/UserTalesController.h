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

@interface UserTalesController : UIViewController <InputTaleInfoDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate> {
    Tale *currentTale;
    NSInteger lastTaleIndex;
    NSInteger currentTaleIndex;
    IBOutlet UISegmentedControl *controlTab;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;

- (IBAction)leftSideMenuButtonPressed:(id)sender;
- (void)reloadTaleList;
- (IBAction)newTale:(id)sender;
@end
