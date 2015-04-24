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
#import "MFSideMenu.h"

@implementation DownloadAssignmentsController

-(void)selectTale:(id)sender {
    pageTitle.text = @"Downloading Lesson";
    UIButton *button;
    int currentTaleIndex;
    
    if (sender != nil) {
        button = (UIButton*) sender;
        currentTaleIndex = button.tag - 1000;
    }
    
    downloadingView.hidden = NO;
    talesPreviewView.hidden = YES;
    [activityIndicator startAnimating];

    NSDictionary *currentTale = [[_dataArray objectAtIndex:0] objectAtIndex:currentTaleIndex];
    
    NSString* url = [NSString stringWithFormat:@"%@/services/lesson/",servicesURLPrefix];
    
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
                         newLesson.taleId = [json valueForKey:@"tale_id"];
                         
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
                                 
                                 if([[json valueForKey:@"has_teacher_audio"] boolValue]) {
                                     NSLog(@"has_teacher_audio");
                                     NSString *imageFilePath = [path stringByAppendingPathComponent:@"teacher_audio.mp3"];
                                     NSData *audioData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                                     NSLog(@"has_teacher_audio:%d", audioData.length);
                                     Page *page = [newLesson.pages objectAtIndex:0];
                                     [page saveTeacherAudio:audioData];
                                 }
                                 
                                 
                                 
                                 Page *page = [newLesson.pages objectAtIndex:0];

                                 [page setTeacher_text:[json valueForKey:@"teacher_text"]];
                                 page.text_locked = [[json valueForKey:@"title_locked"] boolValue];
                                 page.image_locked = [[json valueForKey:@"image_locked"]boolValue];
                                 page.audio_locked = [[json valueForKey:@"audio_locked"] boolValue];

                                 NSArray* pages = [json valueForKey:@"pages"];
                                 if ([pages count] > 0) {
                                     for (NSInteger i = 0; i < [pages count]; i++) {
                                         NSDictionary *item = [pages objectAtIndex:i];
                                         Page *samplePage = [Page newPage];
                                         samplePage.pageId = [item valueForKey:@"page_id"];
                                         samplePage.pageFolder = [NSString stringWithFormat:@"%@/%0.f",[Lib taleFolderPathFromIndex:newLesson.index],samplePage.index];

                                         samplePage.text = [item valueForKey:@"text"];
                                         samplePage.teacher_text = [item valueForKey:@"teacher_text"]==NULL?@"":[item valueForKey:@"teacher_text"] ;
                                         samplePage.text_locked = [[item valueForKey:@"text_locked"] boolValue];
                                         samplePage.image_locked = [[item valueForKey:@"image_locked"]boolValue];
                                         samplePage.audio_locked = [[item valueForKey:@"audio_locked"] boolValue];
                                         NSLog(@"Page image locked: %hhd", page.image_locked);
                                         NSLog(@"Here is the teacher text: %@", samplePage.teacher_text);
                                         NSLog(@"Here is the teacher text: %@", [item valueForKey:@"teacher_text"]);
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
                                         
                                         if([[item valueForKey:@"has_teacher_audio"] boolValue]) {
                                             NSLog(@"has_teacher_audio");
                                             NSString *audioFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d/teacher_page.mp3", i]];
                                             NSData *audioData = [NSData dataWithContentsOfFile:audioFilePath options:0 error:nil];
                                             NSLog(@"has_teacher_audio:%d", audioData.length);
                                             [samplePage saveTeacherAudio:audioData];
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

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad {
    downloadingView.hidden = NO;
    [activityIndicator startAnimating];
    
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:servicesURLPrefix] encoding:NSUTF8StringEncoding error:nil];
    
    if (connect == NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection!"
                                                        message:@"Connect to internet and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"%@/services/lessons/",servicesURLPrefix];
    NSLog(@"%@", [Lib getValueOfKey:@"encrypted_user_id"]);
    [HttpHelper sendAsyncPostRequestToURL:url
                          withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [Lib getValueOfKey:@"encrypted_user_id"],@"user_id",
                                          nil]
                    andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        NSError *e = nil;
                        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];

                        if([jsonArray count] > 0) {
                            pageTitle.text = @"Select a Lesson to Download";
                            downloadingView.hidden = YES;
                            talesPreviewView.hidden = NO;
                            
                            self.dataArray = [[NSArray alloc] initWithObjects:jsonArray, nil];
                            
                            [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
                            /* end of subclass-based cells block */
                            
                            // Configure layout
                            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
                            [flowLayout setItemSize:CGSizeMake(325, 243)];
                            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
                            [flowLayout setMinimumLineSpacing:15];
                            [self.collectionView setCollectionViewLayout:flowLayout];
                            [self.collectionView reloadData];
                        }
                        else {
                            [activityIndicator stopAnimating];
                            talesPreviewView.hidden = NO;
                            [Lib showAlert:@"Warning" withMessage:@"You have no Lessons to download."];
                        }
                    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
}

- (void)alertView:(UIAlertView *)alertV didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UserLessonsController* controller;
    controller = [[UserLessonsController alloc] initWithNibName:@"UserLessonsController-iPad" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataArray count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
    return [sectionArray count];
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell identifier
    static NSString *cellIdentifier = @"cvCell";
    
    /*  Uncomment this block to use nib-based cells */
    // UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    // UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    // [titleLabel setText:cellData];
    /* end of nib-based cell block */
    
    /* Uncomment this block to use subclass-based cells */
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSMutableArray *data = [self.dataArray objectAtIndex:indexPath.section];
    NSDictionary* lesson = [data objectAtIndex:indexPath.row];
    [cell.titleLabel setText:[[lesson valueForKey:@"title"] isEqual:[NSNull null]]? @"My Little Bird Tale" : [lesson valueForKey:@"title"]];
    [cell.authorLabel setText:[[lesson valueForKey:@"author"] isEqual:[NSNull null]]? @"My Little Bird Tale" : [lesson valueForKey:@"author"]];


    NSString *imageData = [lesson valueForKey:@"image"];
    NSLog(@"Image: %@",imageData);
    if([imageData length]== 0) {
        [cell.cover setBackgroundImage:[UIImage imageNamed:@"cover_default.jpg"] forState:UIControlStateNormal];
    }
    else {
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@", servicesURLPrefix,imageData];
        UIImage *pImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        [cell.cover setBackgroundImage:pImage forState:UIControlStateNormal];
    }

    
    
    [cell.cover setTag:indexPath.row+1000];
    
    [cell.cover addTarget:self action:@selector(selectTale:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.menu setHidden:TRUE];
    /* end of subclass-based cells block */
    
    // Return the cell
    return cell;
    
}

@end
