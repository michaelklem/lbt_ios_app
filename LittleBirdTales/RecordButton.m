//
//  RecordButton.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordButton.h"

@implementation RecordButton

- (void)awakeFromNib {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"ipad_btn_record.png"];
    imageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"ipad_btn_record.png"], [UIImage imageNamed:@"ipad_btn_record_active.png"], nil];
    imageView.animationDuration = 0.5;
    imageView.animationRepeatCount = 0;
    imageView.userInteractionEnabled = NO;
    imageView.hidden = YES;
    [self addSubview:imageView];

}

- (void)startAnimation {
    imageView.hidden = NO;
    [imageView startAnimating];
}
- (void)stopAnimation {
    imageView.hidden = YES;
    [imageView stopAnimating];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
