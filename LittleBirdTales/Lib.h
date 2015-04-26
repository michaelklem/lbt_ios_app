//
//  LittleBirdTales.h
//
//  Created by Deep Blue on 2/9/12.
//  Copyright 2012 nWavez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView(Extended)
- (UIImage *) imageByRenderingView;
@end

@interface Lib : NSObject {

}

+(void)setValue:(NSString*)val forKey:(NSString*)key;
+(NSString*)getValueOfKey:(NSString*)key;

+(void)showLoadingViewOn:(UIView *)aView withAlert:(NSString *)text;
+(void)showNotificationOn:(UIView *)aView withText:(NSString *)text;
+(void)removeLoadingViewOn:(UIView *)superView;

+(void)showAlert:(NSString*)title withMessage:(NSString*)msg;

+ (NSString *)applicationDocumentsDirectory;
+ (NSString*)taleFolderPathFromIndex:(double)index;
+(void) createDirectory:(NSString *)dirName;
+(NSString*)dir;

@end
