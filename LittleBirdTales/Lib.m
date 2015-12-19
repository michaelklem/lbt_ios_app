//
//  LittleBirdTales.m
//
//  Created by Deep Blue on 2/9/12.
//  Copyright 2012 nWavez. All rights reserved.
//

#import "Lib.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView(Extended)
- (UIImage *) imageByRenderingView {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
@implementation Lib

+(NSString*)getValueOfKey:(NSString*)key {

    NSString *result = nil;
    NSMutableDictionary* settings =[[NSUserDefaults standardUserDefaults] objectForKey:@"LBTales.settings"];
    result = [settings objectForKey:key];
    return result;
}

+(void)setValue:(NSString*)value forKey:(NSString*)key {

    NSMutableDictionary* settings =[[[NSUserDefaults standardUserDefaults] objectForKey:@"LBTales.settings"] mutableCopy];

    if (settings) {
        @try {
            if (value) {
                [settings setObject:value forKey:key];
            } else {
                [settings removeObjectForKey:key];
            }
            [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"LBTales.settings"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }

    } else if (value) {
        NSMutableDictionary *newSettings = [[NSMutableDictionary alloc] init];
        [newSettings setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:newSettings forKey:@"LBTales.settings"];
    }
}



+ (void)showLoadingViewOn:(UIView *)aView withAlert:(NSString *)text{

    UIView *loadingView = [[UIView alloc] init];
    loadingView.frame = CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height);
    loadingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    loadingView.tag = 1011;
    UILabel *loadingLabel = [[UILabel alloc ] init];

    UIView* roundedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    roundedView.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
    roundedView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    roundedView.layer.borderColor = [UIColor clearColor].CGColor;
    roundedView.layer.borderWidth = 1.0;
    roundedView.layer.cornerRadius = 10.0;
    [loadingView addSubview:roundedView];

    loadingLabel.text = text;
    loadingLabel.frame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y + 50, 200, 30);
    //loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont boldSystemFontOfSize:14];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingView addSubview:loadingLabel];

    UIActivityIndicatorView *activityIndication = [[UIActivityIndicatorView alloc] init];
    activityIndication.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndication.frame = CGRectMake((loadingView.frame.size.width - 30)/2,
                                          roundedView.frame.origin.y + 15,
                                          30,
                                          30);

    //	NSLog(@"%@",activityIndication);
    [activityIndication startAnimating];
    [loadingView addSubview:activityIndication];

    //	[activityIndication release];
    [aView addSubview:loadingView];
}

+ (void)showNotificationOn:(UIView *)aView withText:(NSString *)text{

    UIView *loadingView = [[UIView alloc] init];
    loadingView.frame = CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height);
    loadingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    loadingView.tag = 1011;
    UILabel *loadingLabel = [[UILabel alloc ] init];

    UIView* roundedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    roundedView.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
    roundedView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    roundedView.layer.borderColor = [UIColor clearColor].CGColor;
    roundedView.layer.borderWidth = 1.0;
    roundedView.layer.cornerRadius = 10.0;
    [loadingView addSubview:roundedView];

    loadingLabel.text = text;
    loadingLabel.frame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y + 25, 200, 30);
    //loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont boldSystemFontOfSize:14];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingView addSubview:loadingLabel];

    [aView addSubview:loadingView];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeNotificationView:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:aView, @"view", nil] repeats:NO];

}

+ (void)removeNotificationView:(NSTimer *)theTimer {
    UIView *view = [[theTimer userInfo] objectForKey:@"view"];
    for (UIView *aView in view.subviews) {
        if ((aView.tag == 1011)  && [aView isKindOfClass:[UIView class]]) {
            [aView removeFromSuperview];
        }
    }
}

+ (void)removeLoadingViewOn:(UIView *)superView{
    for (UIView *aView in superView.subviews) {
        if ((aView.tag == 1011)  && [aView isKindOfClass:[UIView class]]) {
            [aView removeFromSuperview];
        }
    }
}

+(void)showAlert:(NSString*)title withMessage:(NSString*)msg {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

// Returns the URL to the application's Documents directory.
// https://developer.apple.com/library/ios/technotes/tn2406/_index.html
+ (NSString *)applicationDocumentsDirectory
{
    NSURL *dir2 = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"Directory path: %@",dir2);
    NSLog(@"Directory path: %@",[dir2 absoluteString]);
    NSLog(@"Directory path: %@",[dir2 path]);
    NSString *path = [dir2 path];
    return path;
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* dir = [paths objectAtIndex:0];
//    return dir;
}

+ (NSString*)taleFolderPathFromIndex:(double)index {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];

    double createdDate = floor(index/100);

    NSString *path = [NSString stringWithFormat:@"%@/%.0f",[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createdDate]],index];

    return path;
}

// Returns the path to the documents directory with the user_id directory appended
// to the end of the path if the user_id exists.
// Usage:
// NSString* dir = [paths objectAtIndex:0];
// dir = [NSString stringWithFormat:@"%@/%@", [Lib dir], [Lib getValueOfKey:@"user_id"]];
+(NSString*)dir {
    NSString* dir = [self applicationDocumentsDirectory];
    NSString* user_id = [Lib getValueOfKey:@"user_id"];
    if(user_id && ![user_id isEqual: @""])
    {
        dir = [NSString stringWithFormat:@"%@/%@", dir, user_id];
        [Lib createDirectory:user_id];
    }
    NSLog(@"Directory path: %@",dir);
    return dir;
}

// Creates a directory if it does not exist in the documents directory.
// Usage:
// [Lib createDirectory:@"MyDirectory"];
+(void) createDirectory : (NSString *) dirName {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* documentsDirectory = [self applicationDocumentsDirectory];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:dirName];
    NSError* error = nil;

    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        if ([[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error])
        {
            NSLog(@"Directory created : %@ ",dataPath); // Path of folder created
        }
        else
        {
            NSLog(@"Couldn't create directory error: %@", error);
        }
    }
    else
    {
        NSLog(@"Directory exists already");
    }
}

@end