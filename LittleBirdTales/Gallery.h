//
//  Gallery.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gallery : NSObject

+ (BOOL)saveImage:(UIImage*)original;

+ (NSString *)dir;

@end
