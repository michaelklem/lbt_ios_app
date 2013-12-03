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
#import "Flurry.h"
#import "iRate.h"

AppDelegate* _shared;
@implementation AppDelegate

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 0.01;
    [iRate sharedInstance].usesUntilPrompt = 1;
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
        TalesController* controller;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            controller = [[TalesController alloc] initWithNibName:@"TalesController-iPad" bundle:nil];
        } else {
            controller = [[TalesController alloc] initWithNibName:@"TalesController-iPhone" bundle:nil];
        }
        [self.navController pushViewController:controller animated:YES];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    unsigned char a = 100;
//    unsigned char b = 200;
//    
//    NSLog(@"%i",abs(a - b));
//    NSLog(@"%i",abs(b - a));
    
//    fill_left(--x,y);
//    x = x + 1 ;
//    fill_left(x,y-1);
//    fill_left(x,y+1);
    
//    int x = 10;
//    int y = 10;
//    NSLog(@"%i %i",--x,y);
//    x = x + 1;
//    NSLog(@"%i %i",x,y-1);
//    NSLog(@"%i %i",x,y+1);
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"68NHTPWPGX3QNMXSTG9R"];
                           
    
    //As client request to display Splash Screen a little longer
    [NSThread sleepForTimeInterval:1.0];
    
    
    _shared = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController* controller;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        controller = [[TalesController alloc] initWithNibName:@"TalesController-iPad" bundle:nil];
    } else {
        controller = [[TalesController alloc] initWithNibName:@"TalesController-iPhone" bundle:nil];
    }

    self.navController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.navController.navigationBarHidden = YES;
    
//    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
//    } else {
//        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 1024, 748)];
//        imageView.image = [UIImage imageNamed:@"bg-ipad"];
//        [self.navController.view insertSubview:imageView atIndex:0];
//        //TT_RELEASE_SAFELY(imageView);
//    }

    self.window.rootViewController = self.navController;
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
