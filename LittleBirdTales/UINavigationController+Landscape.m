//
//  UINavigationController+Landscape.m
//  LittleBirdTales
//
//  Created by Stuart Davison on 4/10/14.
//
//

#import "UINavigationController+Landscape.h"

@implementation UINavigationController (Landscape)

// Have to support portrait mode (in AppDelegate's application:supportedInterfaceOrientationsForWindow:)
// for UIImagePickerController to be happy when presentModalViewController gets called
// UINavigationController+Landscape category keeps our views landscape only
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end