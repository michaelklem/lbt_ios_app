//
//  DownloadTalesController.h
//  LittleBirdTales
//
//  Created by Michael Arnold on 10/30/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "InputTaleInfo.h"
#import "CVCell.h"

@interface StudentDownloadTalesController : UIViewController {
    IBOutlet UIView *downloadingView;
    IBOutlet UIView *talesPreviewView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *pageTitle;
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

 - (IBAction)leftSideMenuButtonPressed:(id)sender;

@end