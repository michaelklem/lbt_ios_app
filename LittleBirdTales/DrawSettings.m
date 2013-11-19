//
//  DrawSettings.m
//  LittleBirdTales
//
//  Created by Mac on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DrawSettings.h"
DrawSettings* shared;

@implementation DrawSettings
@synthesize fillColor, edgeColor;
+(DrawSettings*)shared {
    if (!shared) {
        shared = [[DrawSettings alloc] init];
        shared.fillColor = [UIColor whiteColor];
        shared.edgeColor = [UIColor blackColor];
    }
    return shared;
}
@end
