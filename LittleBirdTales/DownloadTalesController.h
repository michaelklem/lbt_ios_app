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

@interface DownloadTalesController : UIViewController {
    IBOutlet UIView* taleInfoView;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* authorLabel;
    IBOutlet UILabel* pageLabel;
    IBOutlet UILabel* createdLabel;
    IBOutlet UILabel* modifiedLabel;
    IBOutlet UIImageView* previewImage;
    IBOutlet UIImageView *noTaleBackground;
    IBOutlet UIScrollView *talesScrollView;
    IBOutlet UIView *downloadingView;
    IBOutlet UIView *talesPreviewView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *downloadingLabel;
    NSInteger lastTaleIndex;
    NSInteger currentTaleIndex;
    NSArray* userTales;
}

 - (void)reloadTaleList;
 - (void)selectTale;
 - (void)back;
 - (void)downloadTale:(id)sender;

@end
