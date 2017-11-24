//
//  AppDelegate.m
//  LittleBirdTales
//
//  Created by Mac on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TalesController.h"
#import "UserTalesController.h"
#import "UserLoginViewController.h"
#import "Flurry.h"
#import "iRate.h"
#import "Lib.h"
#import "MFSideMenuContainerViewController.h"
#import "SideMenuViewController.h"
#import "HttpHelper.h"
#import "ServiceLib.h"
#import "SBJson.h"

AppDelegate* _shared;
@implementation AppDelegate

/*
void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
    NSLog(@"Stack trace: %@", [exception callStackSymbols]);
}

-(void) applicationDidFinishLaunching:(UIApplication*)application
{
    NSSetUncaughtExceptionHandler(&onUncaughtException);
}
*/

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 5;
}

+(AppDelegate*)shared {
    return _shared;
}

@synthesize window = _window;
@synthesize navController;

//-(void)showLogin {
//    if (self.navController &&
//        self.navController.viewControllers.count > 1) {
//        [self.navController popToRootViewControllerAnimated:YES];
//    }
//}

-(void)showMain {
    if (self.navController &&
        self.navController.viewControllers.count == 1){
        UIViewController* controller;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            controller = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController-iPad" bundle:nil];
        } else {
            controller = [[TalesController alloc] initWithNibName:@"TalesController-iPhone" bundle:nil];
        }
        [self.navController pushViewController:controller animated:YES];
    }
}

// Have to support portrait for UIImagePickerController to be happy when presentModalViewController gets called
// UINavigationController+Landscape category keeps our views from rotating
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
   return UIInterfaceOrientationMaskAll;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"68NHTPWPGX3QNMXSTG9R"];

    
    //As client request to display Splash Screen a little longer
    [NSThread sleepForTimeInterval:1.0];
    
    
    _shared = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController* controller;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        if([[Lib getValueOfKey:@"user_id"]  isEqual: @""]  || ![Lib getValueOfKey:@"user_id"]) {
            controller = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController-iPad" bundle:nil];
        } else {
            // We retrieve the email address if the user logged in, but
            // the email is not set.
            if([[Lib getValueOfKey:@"user_name"]  isEqual: @""]  || ![Lib getValueOfKey:@"user_name"]) {
                // Make request to new service end point that returns the email address/username based on the user id.
                // klem
//                NSString* url = [NSString stringWithFormat:@"%@/services/emailFromUserId",servicesURLPrefix];
//                [HttpHelper sendAsyncGetRequestToURL:url
//                                      withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                      [Lib getValueOfKey:@"user_id"],@"user_id",
//                                                      nil]
//                                andCompletionHandler:^(NSURLResponse *response, NSData *response_data, NSError *error) {
//                                    NSError *e = nil;
//                                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: response_data options: NSJSONReadingMutableContainers error: &e];
//                                    NSLog(@"Email from user id Data: %@",[json valueForKey:@"email"]);
//                                    [Lib setValue:[json valueForKey:@"email"] forKey:@"user_name"];
//                                }];
//
//
                
            NSString* strData = [ServiceLib sendRequest:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [Lib getValueOfKey:@"user_id"],@"user_id",nil]
                        andUrl:[NSString stringWithFormat:@"%@/services/emailFromUserId",servicesURLPrefix]];
            NSLog(@"Email from user id Data: %@",strData);
            if (strData) {
                id obj = [strData JSONValue];
                if ([obj isKindOfClass:[NSDictionary class]] &&
                    [obj objectForKey:@"email"])
                {
                    NSString *email = [obj objectForKey:@"email"];
                    NSLog(@"Email from user id Data22: %@",email);
                    [Lib setValue:email forKey:@"user_name"];
                }
            }
                
            }
            controller = [[UserTalesController alloc] initWithNibName:@"UserTalesController-iPad" bundle:nil];
        }
    } else {
        controller = [[TalesController alloc] initWithNibName:@"TalesController-iPhone" bundle:nil];
    }

    self.navController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.navController.navigationBarHidden = YES;

    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self navController]
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:rightMenuViewController];

    container.panMode = MFSideMenuPanModeNone;
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
