//
//  AppDelegate.h
//  LittleBirdTales
//
//  Created by Mac on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) SideMenuViewController *menuController;

//-(void)showLogin;
-(void)showMain;
+(AppDelegate*)shared;
@end
