//
//  DownloadTalesController.m
//  LittleBirdTales
//
//  Created by Michael Arnold on 10/30/13.
//
//

#import "DownloadAssignmentsController.h"
#import "EditTaleViewController.h"
#import "UserLessonsController.h"
#import "TalesController.h"
#import "SBJson.h"
#import "ServiceLib.h"
#import "HttpHelper.h"
#import "Lib.h"
#import "Lesson.h"
#import <AudioToolbox/AudioServices.h> 
#import <AVFoundation/AVFoundation.h>
#import "../ZipArchive/ZipArchive.h"

@implementation DownloadAssignmentsController

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
                [HttpHelper sendAsyncGetRequestToURL:imageUrl
                                      withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      @"1",@"test",
                                                      nil]
                                 andCompletionHandler:^(NSURLResponse *response, NSData *taleContent, NSError *error) {
                                     UIImage *pImage=[UIImage imageWithData:taleContent];
                                     [button setImage:pImage forState:UIControlStateNormal];
                                 }];
                
                
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
            [talesScrollView setContentSize:CGSizeMake(95*[userTales count] , 63)];
        }
        
    }
    [activityIndicator stopAnimating];
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
       
        [titleLabel setText:[[currentTale valueForKey:@"title"] isEqual:[NSNull null]]? @"My Little Bird Tale" : [currentTale valueForKey:@"title"]];
        [authorLabel setText:[[currentTale valueForKey:@"author"] isEqual:[NSNull null]] ? @"A Little Bird" : [currentTale valueForKey:@"author"]];
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

- (IBAction)downloadLesson:(id)sender  {
    downloadingView.hidden = NO;
    downloadingLabel.text = @"Downloading tale...";
    talesPreviewView.hidden = YES;
    [activityIndicator startAnimating];
    
    NSDictionary *currentTale = [userTales objectAtIndex:currentTaleIndex];
    
    NSString* url = [NSString stringWithFormat:@"%@/services/tale/",servicesURLPrefix];
    
    [HttpHelper sendAsyncPostRequestToURL:url
                           withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [currentTale valueForKey:@"tale_id"],@"tale_id",
                                           nil]
                     andCompletionHandler:^(NSURLResponse *response, NSData *taleContent, NSError *error) {
                         NSError *e = nil;
                         NSDictionary *json = [NSJSONSerialization JSONObjectWithData: taleContent options: NSJSONReadingMutableContainers error: &e];
                         NSString *myString = [[NSString alloc] initWithData:taleContent encoding:NSUTF8StringEncoding];
                         NSLog(@"Downloaded Tale.");
                         NSLog(@"Title: %@",[json valueForKey:@"title"]);
                         NSLog(@"content: %@",myString);
                         
                         Lesson *newLesson = [Lesson newLessonwithTitle:[[json valueForKey:@"title"] isEqual:[NSNull null]]?@"My Little Bird Tale":[json valueForKey:@"title"] author:[[json valueForKey:@"author"] isEqual:[NSNull null]]?@"A Little Bird":[json valueForKey:@"author"]];
                         
                         NSString *url2 = [NSString stringWithFormat:@"%@/services/taleData/",servicesURLPrefix];
                         NSLog(@"%@", url2);
                         NSError *error2 = nil;
                         
                         NSData *data = [ServiceLib sendRequestForFile:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                        [currentTale valueForKey:@"tale_id"],@"tale_id",
                                                                        nil]
                                                                andUrl:url2];
                         
                         
                         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                         NSString *path = [paths objectAtIndex:0];
                         NSString *zipPath = [path stringByAppendingPathComponent:@"tale_data.zip"];
                         [data writeToFile:zipPath options:0 error:&error2];
                         
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
                                     
                                     Page *page = [newLesson.pages objectAtIndex:0];
                                     
                                     [page saveImage:img];
                                 }
                                 
                                 if([[json valueForKey:@"has_audio"] boolValue]) {
                                     NSLog(@"has_audio");
                                     NSString *imageFilePath = [path stringByAppendingPathComponent:@"audio.mp3"];
                                     NSData *audioData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                                     NSLog(@"has_audio:%d", audioData.length);
                                     Page *page = [newLesson.pages objectAtIndex:0];
                                     [page saveAudio:audioData];
                                 }
                                 
                                 
                                 NSArray* pages = [json valueForKey:@"pages"];
                                 if ([pages count] > 0) {
                                     for (NSInteger i = 0; i < [pages count]; i++) {
                                         NSDictionary *item = [pages objectAtIndex:i];
                                         Page *samplePage = [Page newPage];
                                         samplePage.pageFolder = [NSString stringWithFormat:@"%@/%0.f",[Lib taleFolderPathFromIndex:newLesson.index],samplePage.index];
                                         samplePage.text = [[item valueForKey:@"text"] isEqual:[NSNull null]]?@"":[item valueForKey:@"text"];
                                         
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
                                         
                                         [newLesson.pages addObject:samplePage];
                                         
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
                         
                         
                         
                         [Lesson addLesson:newLesson];
                         [Lesson save];
                         
                         UserLessonsController* controller;
                         controller = [[UserLessonsController alloc] initWithNibName:@"UserLessonsController-iPad" bundle:nil];
                         
                         [self.navigationController pushViewController:controller animated:YES];
                         downloadingView.hidden = YES;
                         talesPreviewView.hidden = NO;
                         [activityIndicator stopAnimating];
                     }];
}

- (IBAction)back:(id)sender {
    UserLessonsController* controller;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        controller = [[UserLessonsController alloc] initWithNibName:@"UserLessonsController-iPad" bundle:nil];
    } else {
        controller = [[UserLessonsController alloc] initWithNibName:@"UserLessonsController-iPhone" bundle:nil];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad {
    noTaleBackground.hidden = YES;
    downloadingView.hidden = NO;
    downloadingLabel.text = @"Getting tales list...";
    [activityIndicator startAnimating];
    NSString* strData;
    NSString* url = [NSString stringWithFormat:@"%@/services/lessons/",servicesURLPrefix];
    NSLog(@"%@", [Lib getValueOfKey:@"encrypted_user_id"]);
    [HttpHelper sendAsyncPostRequestToURL:url
                          withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [Lib getValueOfKey:@"encrypted_user_id"],@"user_id",
                                          nil]
                    andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        NSError *e = nil;
                        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
                        userTales = jsonArray;
                        [self reloadTaleList];
                        if([userTales count] > 0) {
                            [self selectTale:nil];
                            noTaleBackground.hidden = YES;
                            downloadingView.hidden = YES;
                            talesPreviewView.hidden = NO;
                        }
                        else {
                            [activityIndicator stopAnimating];
                            noTaleBackground.hidden = NO;
                            talesPreviewView.hidden = NO;
                            [Lib showAlert:@"Warning" withMessage:@"You have no Tales to Download."];
                        }
                    }];
}

@end
