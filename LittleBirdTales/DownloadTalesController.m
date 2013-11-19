//
//  DownloadTalesController.m
//  LittleBirdTales
//
//  Created by Michael Arnold on 10/30/13.
//
//

#import "DownloadTalesController.h"
#import "EditTaleViewController.h"
#import "TalesController.h"
#import "SBJson.h"
#import "ServiceLib.h"
#import "Lib.h"
#import <AudioToolbox/AudioServices.h> 
#import <AVFoundation/AVFoundation.h>
#import "ZipArchive.h"

@implementation DownloadTalesController

@synthesize userId;
static int LoadingItemContext = 1;
- (void)reloadTaleList {
    for (UIView *view in talesScrollView.subviews) {
        [view removeFromSuperview];
    }
    if ([userTales count] > 0) {
        for (NSInteger i = 0; i < [userTales count]; i++) {
            NSDictionary *item = [userTales objectAtIndex:i];
            
            UIButton *button;
            
            if (IsIdiomPad) {
                button = [[UIButton alloc] initWithFrame:CGRectMake(210*i, 5, 200, 140)];
                if (i == currentTaleIndex) {
                    [button.layer setCornerRadius:5.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                    [button.layer setBorderWidth:6.0];
                } else {
                    [button.layer setCornerRadius:5.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                    [button.layer setBorderWidth:3.0];
                }
            } else {
                button = [[UIButton alloc] initWithFrame:CGRectMake(95*i, 3, 90, 63)];
                if (i == currentTaleIndex) {
                    [button.layer setCornerRadius:2.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                    [button.layer setBorderWidth:2.0];
                } else {
                    [button.layer setCornerRadius:2.0];
                    [button.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                    [button.layer setBorderWidth:1.0];
                }
            }
            
            NSString *imageData = [item valueForKey:@"image_small"];
            NSLog(@"Image: %@",imageData);
            if([imageData length]== 0) {
                [button setImage:[UIImage imageNamed:@"cover_default_med.jpg"]  forState:UIControlStateNormal];
            }
            else {
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@", servicesURLPrefix,imageData];
                UIImage *pImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
                [button setImage:pImage forState:UIControlStateNormal];
            }
            
            
            
            [button.layer setMasksToBounds:YES];
            
            
            
            button.tag = 1000 + i;
            [button addTarget:self action:@selector(selectTale:) forControlEvents:UIControlEventTouchUpInside];
            
            [talesScrollView addSubview:button];
            
        }
        if (IsIdiomPad) {
            [talesScrollView setContentSize:CGSizeMake(210*[userTales count] , 140)];
        }
        else {
            [talesScrollView setContentSize:CGSizeMake(90*[userTales count] , 63)];
        }
        
    }
}

-(void)selectTale:(id)sender {
        lastTaleIndex = currentTaleIndex;
        UIButton *button;
        
        if (sender != nil) {
            
            button = (UIButton*) sender;
            currentTaleIndex = button.tag - 1000;
        }
        
        if (lastTaleIndex != currentTaleIndex && sender!= nil) {
            if (IsIdiomPad) {
                UIButton *lastButton = (UIButton*)[talesScrollView viewWithTag:lastTaleIndex+1000];
                [lastButton.layer setMasksToBounds:YES];
                [lastButton.layer setCornerRadius:5.0];
                [lastButton.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                [lastButton.layer setBorderWidth:3.0];
                
                [button.layer setMasksToBounds:YES];
                [button.layer setCornerRadius:5.0];
                [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                [button.layer setBorderWidth:6.0];
            } else {
                UIButton *lastButton = (UIButton*)[talesScrollView viewWithTag:lastTaleIndex+1000];
                [lastButton.layer setMasksToBounds:YES];
                [lastButton.layer setCornerRadius:2.0];
                [lastButton.layer setBorderColor:[UIColorFromRGB(0x8FD866) CGColor]];
                [lastButton.layer setBorderWidth:1.0];
                
                [button.layer setMasksToBounds:YES];
                [button.layer setCornerRadius:2.0];
                [button.layer setBorderColor:[UIColorFromRGB(0xfa3737) CGColor]];
                [button.layer setBorderWidth:2.0];
            }
        }
        
        NSDictionary *currentTale = [userTales objectAtIndex:currentTaleIndex];
        NSLog(@"Title: %@",[currentTale valueForKey:@"title"]);
       
        [titleLabel setText:[currentTale valueForKey:@"title"]];
        [authorLabel setText:[currentTale valueForKey:@"author"]];
        [pageLabel setText:[NSString stringWithFormat:@"%@",[currentTale valueForKey:@"pages"]]];
        [createdLabel setText:[currentTale valueForKey:@"created"]];
        [modifiedLabel setText:[currentTale valueForKey:@"modified"]];
        
        NSString *imageData = [currentTale valueForKey:@"image"];
        NSLog(@"Image: %@",imageData);
        if([imageData length]== 0) {
            [previewImage setImage:[UIImage imageNamed:@"cover_default.jpg"]];
        }
        else {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@", servicesURLPrefix,imageData];
            UIImage *pImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            [previewImage setImage:pImage];
        }
    
}

- (void)downloadTale:(id)sender {
    NSDictionary *currentTale = [userTales objectAtIndex:currentTaleIndex];
    
    NSString* strData;
    NSString* url = [NSString stringWithFormat:@"%@/services/tale/tale_id/%@/",servicesURLPrefix, [currentTale valueForKey:@"tale_id"]];
    strData = [ServiceLib sendGetRequest:url];
    NSData *jsonData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    
    
    NSLog(@"Downloaded Tale.");
    NSLog(@"Title: %@",[json valueForKey:@"title"]);
    
    Tale *newTale = [Tale newTalewithTitle:[json valueForKey:@"title"] author:[json valueForKey:@"author"]];
    
    NSURL *url2 = [NSString stringWithFormat:@"%@/services/taleData/tale_id/%@/",servicesURLPrefix, [currentTale valueForKey:@"tale_id"]];
    NSLog(@"%@", url2);
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url2] options:0 error:&error];
    
    if(!error)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *zipPath = [path stringByAppendingPathComponent:@"tale_data.zip"];
        [data writeToFile:zipPath options:0 error:&error];
        
        if(!error)
        {
            ZipArchive *za = [[ZipArchive alloc] init];
            if ([za UnzipOpenFile: zipPath]) {
                BOOL ret = [za UnzipFileTo: path overWrite: YES];
                if (NO == ret){} [za UnzipCloseFile];
                
                if([[json valueForKey:@"has_image"] boolValue]) {
                    NSString *imageFilePath = [path stringByAppendingPathComponent:@"image.jpg"];
                    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                    UIImage *img = [UIImage imageWithData:imageData];
                
                    Page *page = [newTale.pages objectAtIndex:0];
                
                    [page saveImage:img];
                }
                
                if([[json valueForKey:@"has_audio"] boolValue]) {
                    NSLog(@"has_audio");
                    NSString *imageFilePath = [path stringByAppendingPathComponent:@"audio.mp3"];
                    NSData *audioData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                    NSLog(@"has_audio:%d", audioData.length);
                    Page *page = [newTale.pages objectAtIndex:0];
                    [page saveAudio:audioData];
                }
                
                
                NSArray* pages = [json valueForKey:@"pages"];
                if ([pages count] > 0) {
                    for (NSInteger i = 0; i < [pages count]; i++) {
                        NSDictionary *item = [pages objectAtIndex:i];
                        Page *samplePage = [Page newPage];
                        samplePage.pageFolder = [NSString stringWithFormat:@"%@/%0.f",[Lib taleFolderPathFromIndex:newTale.index],samplePage.index];
                        samplePage.text = [item valueForKey:@"text"];
                        
                        if([[item valueForKey:@"has_image"] boolValue]) {
                            NSString *imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d/page.jpg", i]];
                            NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                            UIImage *img = [UIImage imageWithData:imageData];
                                
                            [samplePage saveImage:img];
                        }
                        
                        if([[item valueForKey:@"has_audio"] boolValue]) {
                            NSLog(@"has_audio");
                            NSString *audioFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d/page.mp3", i]];
                            NSData *audioData = [NSData dataWithContentsOfFile:audioFilePath options:0 error:nil];
                            NSLog(@"has_audio:%d", audioData.length);
                            [samplePage saveAudio:audioData];
                        }
                            
                        [newTale.pages addObject:samplePage];
                        
                    }
                }
                /*
                 Page *samplePage = [Page newPage];
                 samplePage.pageFolder = [NSString stringWithFormat:@"%@/%0.f",[Lib taleFolderPathFromIndex:tale.index],samplePage.index];
                 [tale.pages addObject:samplePage];
                 
                 */
                /*dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = img;
                    self.label.text = textString;
                });*/
            }
        }
        else
        {
            NSLog(@"Error saving file %@",error);
        }
    }
    else
    {
        NSLog(@"Error downloading zip file: %@", error);
    }
    
    
    [Tale addTale:newTale];
    [Tale save];
    
    
    
    currentTaleIndex = [[Tale tales] count] - 1;
    
    EditTaleViewController* controller;
    if (IsIdiomPad) {
        controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPad" bundle:nil];
    } else {
        controller = [[EditTaleViewController alloc] initWithNibName:@"EditTaleViewController-iPhone" bundle:nil];
    }
    controller.tale = [[Tale tales] lastObject];
    controller.taleNumber = [[Tale tales] count] - 1;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)back:(id)sender {
    TalesController* controller;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        controller = [[TalesController alloc] initWithNibName:@"TalesController-iPad" bundle:nil];
    } else {
        controller = [[TalesController alloc] initWithNibName:@"TalesController-iPhone" bundle:nil];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
        noTaleBackground.hidden = YES;
    NSString* strData;
    NSString* url = [NSString stringWithFormat:@"%@/services/tales/user_id/%@/",servicesURLPrefix, userId];
    strData = [ServiceLib sendGetRequest:url];
    NSData *jsonData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    
    userTales = jsonArray;
    [self reloadTaleList];
    if([userTales count] > 0) {
        [self selectTale:nil];
        noTaleBackground.hidden = YES;
    }
    else {
        noTaleBackground.hidden = NO;
        [Lib showAlert:@"Warning" withMessage:@"You have no Tales to Download."];
    }
}

@end
