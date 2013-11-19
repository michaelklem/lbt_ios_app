//
//  DrawSettings.h
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawSettings : NSObject
@property (nonatomic, retain) UIColor* edgeColor;
@property (nonatomic, retain) UIColor* fillColor;
+(DrawSettings*)shared;
@end
