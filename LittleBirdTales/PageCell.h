//
//  PageCell.h
//  LittleBirdTales
//
//  Created by Mac on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PageCell : UITableViewCell {
    
}
@property (nonatomic, retain) IBOutlet UIImageView* thumbnail;
@property (nonatomic, retain) IBOutlet UIImageView *pageNumberBackground;
@property (nonatomic, retain) IBOutlet UILabel* pageNumber;
@property (nonatomic, retain) IBOutlet UIImageView* textIndicator;
@property (nonatomic, retain) IBOutlet UIImageView* soundIndicator;


@end
