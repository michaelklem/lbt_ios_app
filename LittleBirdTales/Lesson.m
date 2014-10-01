//
//  Tale.m
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Lesson.h"
#import "Page.h"
#import "SBJson.h"
#import "Lib.h"

NSMutableArray* lessons;
@implementation Lesson
@synthesize index, created, title, pages, modified, author;

+(NSString*)path {
    NSString* path = [NSString stringWithFormat:@"%@/%@", [Lesson dir], @"lessons.plist"];
    NSLog(path);
    return path;
}
+(NSString*)dir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [paths objectAtIndex:0];
    dir = [NSString stringWithFormat:@"%@/%@", dir, [Lib getValueOfKey:@"user_id"]];
    NSLog(dir);
    return dir;
}
+(Lesson*)lessonFromDictionary:(NSDictionary*)dic {
    NSLog(@"%@",dic);
    
    Lesson* lesson = [Lesson newLesson];
    lesson.index = [[dic objectForKey:@"index"] doubleValue];
    lesson.created = [[dic objectForKey:@"created"] doubleValue];
    lesson.modified = [[dic objectForKey:@"modified"] doubleValue];
    lesson.title = [dic objectForKey:@"title"];
    lesson.author = [dic objectForKey:@"author"];
    
    for (NSDictionary* _page in [dic objectForKey:@"pages"]) {
        Page* page = [[Page alloc] init];
        page.index = [[_page objectForKey:@"index"] doubleValue];
        page.pageFolder = [_page objectForKey:@"pageFolder"];
        page.text = [_page objectForKey:@"text"];
        page.teacher_text = [_page objectForKey:@"teacher_text"];
        page.image = [_page objectForKey:@"image"];
        page.voice = [_page objectForKey:@"voice"];
        page.teacher_voice = [_page objectForKey:@"teacher_voice"];
        page.time = [[_page objectForKey:@"teacher_time"] intValue];
        page.teacher_time = [[_page objectForKey:@"time"] intValue];
        page.created = [[_page objectForKey:@"created"] doubleValue];
        page.modified = [[_page objectForKey:@"modified"] doubleValue];
        page.order = [[_page objectForKey:@"order"] intValue];
        page.isCover = [[_page objectForKey:@"isCover"] boolValue];
        page.isCover = [[_page objectForKey:@"isCover"] boolValue];
        page.text_locked = [[_page objectForKey:@"text_locked"] boolValue];
        page.image_locked = [[_page objectForKey:@"image_locked"] boolValue];
        page.audio_locked = [[_page objectForKey:@"audio_locked"] boolValue];
        [lesson.pages addObject:page];
    }
    return lesson;
}

// list of tales saved
+(NSMutableArray*)lessons {
    if (!lessons) {
        NSLog(@"Loading Lessons");
        lessons = [[NSMutableArray alloc] init];
        NSArray* tmp = [NSArray arrayWithContentsOfFile:[Lesson path]];
        if (tmp) {
            NSLog(@"Dictionary Loading Lessons");
            for (NSDictionary* dic in tmp) {
                
                [lessons addObject:[Lesson lessonFromDictionary:dic]];
            }
        }
    }
    return lessons;
}

// Create a new tale, but not add to tales list
+(Lesson*)newLessonWithLesson:(Lesson*)_lesson{
    Lesson* lesson = [[Lesson alloc] init];
    lesson.index = _lesson.index;
    lesson.title = _lesson.title;
    lesson.author = _lesson.author;
    lesson.created = _lesson.created;
    lesson.modified = _lesson.modified;
    lesson.pages = [[NSMutableArray alloc] initWithArray:_lesson.pages];
    lesson = _lesson;
    return lesson;
}

+(Lesson*)newLesson {
    Lesson* lesson = [[Lesson alloc] init];
    lesson.index = round([[NSDate date] timeIntervalSince1970]) * 100 + (arc4random() % 90) + 10;
    lesson.title = @"";
    lesson.author=@"";
    lesson.created = round([[NSDate date] timeIntervalSince1970]);
    lesson.modified = lesson.created;
    lesson.pages = [NSMutableArray array];
    return lesson;
}

+(Lesson*)newLessonwithTitle: (NSString*)_title author:(NSString*)_author {
    Lesson* lesson = [[Lesson alloc] init];
    lesson.index = round([[NSDate date] timeIntervalSince1970]) * 100 + (arc4random() % 90) + 10;
    lesson.title = _title;
    lesson.author= _author;
    lesson.created = round([[NSDate date] timeIntervalSince1970]);
    lesson.modified = lesson.created;
    
    Page *cover = [Page newCover];
    cover.text = _title;
    cover.pageFolder = [NSString stringWithFormat:@"%@/%.0f",[Lib taleFolderPathFromIndex:lesson.index],cover.index];
    lesson.pages = [NSMutableArray arrayWithObject:cover];
    
    return lesson;
}


//Add a tale to tales list and saved to plist 
+(void)addLesson:(Lesson*)lesson {
    [Lesson lessons];
    [lessons addObject:lesson];
    [Lesson save];
}

+(void)updateLesson:(Lesson*)lesson at:(NSInteger)index {
    [Lesson lessons];
    [lessons replaceObjectAtIndex:index withObject:lesson];
    [Lesson save];
}

// Remove a tale from tales list and .plist
+(void)remove:(Lesson*)lesson {
    [Lesson lessons];
    NSString *lessonPath = [NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory],[Lib taleFolderPathFromIndex:lesson.index]];
    NSLog(@"%@",lessonPath);
    
    
    [[NSFileManager defaultManager] removeItemAtPath:lessonPath error:nil];
    [lessons removeObject:lesson];
    [Lesson save];
}

-(NSMutableDictionary*)lessonToDictionay {
    NSLog(@"Lesson to Dictionary");
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithDouble:self.index] forKey:@"index"];
    [dic setObject:[NSNumber numberWithDouble:self.created] forKey:@"created"];
    [dic setObject:[NSNumber numberWithDouble:self.modified] forKey:@"modified"];
    [dic setObject:self.title forKey:@"title"];
    [dic setObject:self.author forKey:@"author"];
    
    NSMutableArray* _pages = [NSMutableArray array];
    [dic setObject:_pages forKey:@"pages"];
    
    for (Page* page in self.pages) {
        NSLog(@"Image Locked %hhd", page.image_locked);
        NSLog(@"Text Locked %@", [NSNumber numberWithBool:page.text_locked]);
        NSLog(@"Audio Locked %hhd", page.audio_locked);
        [_pages addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithDouble:page.index],@"index",
                           page.image,@"image",
                           page.voice,@"voice",
                           page.text,@"text",
                           [NSNumber numberWithBool:page.text_locked],@"text_locked",
                           [NSNumber numberWithBool:page.image_locked],@"image_locked",
                           [NSNumber numberWithBool:page.audio_locked],@"audio_locked",
                           page.teacher_voice == nil?@"":page.teacher_voice ,@"teacher_voice",
                           page.teacher_text == nil?@"":page.teacher_text,@"teacher_text",
                           page.pageFolder == nil?@"":page.pageFolder,@"pageFolder",
                           [NSNumber numberWithDouble:page.created],@"created",
                           [NSNumber numberWithDouble:page.modified],@"modified",
                           [NSNumber numberWithInt:page.time],@"time",
                           [NSNumber numberWithInt:page.teacher_time],@"teacher_time",
                           [NSNumber numberWithInt:page.order],@"order",
                           [NSNumber numberWithBool:page.isCover],@"isCover",
                          nil]];
    }
    NSLog(@"Lesson as dictionary: %@",dic);
    return dic;
}   

// Save tales list to .plist
+(void)save {
    [Lesson lessons];
    NSMutableArray* tmp = [NSMutableArray array];
    for (Lesson* lesson in lessons) {
        [tmp addObject:[lesson lessonToDictionay]];
    }
    NSLog(@"Save this value: %lu",(unsigned long)[tmp count]);
    NSLog(@"Save this value: %@",[Lesson path]);
    NSString *dir = [Lesson dir];
    NSString *path = [Lesson path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [tmp writeToFile:[Lesson path] atomically:YES];
}


-(NSString*)uploadWithUserId: (NSString*)userId andBucketPath: (NSString*)bucketPath {
    
    NSString *storyId = @"";
    
    NSString * uid = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    
    BOOL success = NO;
    
    NSMutableURLRequest* theRequest = [[NSMutableURLRequest alloc] initWithURL: 
                                       [NSURL URLWithString:[NSString stringWithFormat: @"%@/services/add_tale_1_3_0.php",servicesURLPrefix]]];
	[theRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = @"0xKhTmLbOuNdArY";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// User ID
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"userid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",userId] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Unique ID
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"uid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",uid] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // User Path
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"taleid"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%0.f",index] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Tale Title
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"title"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",title] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Story Id
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"author"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",author] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
	// Date Created
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"date_created"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%0.f",created] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Date Modified
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"date_modified"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%0.f",modified] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
    // Has Image ?
    Page *cover = [pages objectAtIndex:0];
    if (cover.voice != NULL && ![cover.voice isEqualToString:@""]) {
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"has_audio"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // Has Audio?
    if (cover.image != NULL && ![cover.image isEqualToString:@""]) {
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"has_image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
	[theRequest setHTTPBody:postBody];
    
	NSData* responeData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];	
	
	NSString *strData = [[NSString alloc] initWithData:responeData encoding:NSUTF8StringEncoding];
    
    if (strData) {
        id obj = [strData JSONValue];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            storyId = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"id"] intValue]];
        }
        else if ([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"error"]) {
            NSString *error = [obj objectForKey:@"error"];
            [Lib showAlert:@"Error" withMessage:error];
        }
    }
   
    if (![storyId isEqualToString:@""] && storyId != NULL ) {
        
        success = YES;
        
        NSInteger counter = 0;
        for (Page* page in pages) {
            [page uploadPageWithUser:userId userPath:bucketPath taleId:[NSString stringWithFormat:@"%.0f",index] storyId:storyId pageNumber:[NSString stringWithFormat:@"%d",counter] uid:uid];
            
            counter = counter + 1;
        }
    }
    
    return storyId;
}

- (BOOL)deleteOrphanFiles {
    BOOL success;
    
    for (Page *page in self.pages) {
        [page deletePageOrphanFile];
    }
    
    return success;
}
@end
