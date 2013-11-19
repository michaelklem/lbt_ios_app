//
//  RecordButton.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordButton : UIButton {
    UIImageView *imageView;
}

- (void)startAnimation;
- (void)stopAnimation;
@end
