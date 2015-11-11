//
//  Tale.m
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tale.h"
#import "Page.h"
#import "SBJson.h"
#import "Lib.h"

NSMutableArray* tales;
@implementation Tale
@synthesize index, created, title, pages, modified, author;

// Returns the path to the tales.plist file.
+(NSString*)path {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* dir = [paths objectAtIndex:0];
    NSString* dir = [Lib applicationDocumentsDirectory];
    NSString* path = [NSString stringWithFormat:@"%@/%@", dir, @"tales.plist"];
    
    // If the user_id is present, the plist file will be found in the directory with the
    // name of the user_id. So create the directory if needed and add it to the path.
    if([Lib getValueOfKey:@"user_id"] && ![[Lib getValueOfKey:@"user_id"] isEqual: @""]) {
        path = [NSString stringWithFormat:@"%@/%@", [Lib dir], @"tales.plist"];
    }

    // Create the plist file if it does not exist.
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    Boolean success = [fileManager fileExistsAtPath:path];
//    if (success)
//    {
//        NSLog(@"FILE PATH EXISTS %@",path);
//    }
//    else
//    {
//        NSLog(@"FILE PATH DOES NOT EXIST %@",path);
//        [@{} writeToFile: path atomically: YES];
//        Boolean success2 = [fileManager fileExistsAtPath:path];
//        if (success2)
//        {
//            NSLog(@"FILE PATH EXISTS NOW %@",path);
//        }
//    }
    return path;
}

+(Tale*)taleFromDictionary:(NSDictionary*)dic {
    //NSLog(@"%@",dic);
    
    Tale* tale = [Tale newTale];
    tale.index = [[dic objectForKey:@"index"] doubleValue];
    tale.created = [[dic objectForKey:@"created"] doubleValue];
    tale.modified = [[dic objectForKey:@"modified"] doubleValue];
    tale.title = [dic objectForKey:@"title"];
    tale.author = [dic objectForKey:@"author"];
    
    for (NSDictionary* _page in [dic objectForKey:@"pages"]) {
        Page* page = [[Page alloc] init];
        page.index = [[_page objectForKey:@"index"] doubleValue];
        page.pageFolder = [_page objectForKey:@"pageFolder"];
        page.text = [_page objectForKey:@"text"];
        page.image = [_page objectForKey:@"image"];
        page.voice = [_page objectForKey:@"voice"];
        page.time = [[_page objectForKey:@"time"] intValue];
        page.created = [[_page objectForKey:@"created"] doubleValue];
        page.modified = [[_page objectForKey:@"modified"] doubleValue];
        page.order = [[_page objectForKey:@"order"] intValue];
        page.isCover = [[_page objectForKey:@"isCover"] boolValue];
        [tale.pages addObject:page];
    }
    return tale;
}

// list of tales saved
+(NSMutableArray*)tales {
    if (!tales) {
        tales = [[NSMutableArray alloc] init];
        NSArray* tmp = [NSArray arrayWithContentsOfFile:[Tale path]];
        if (tmp) {
            for (NSDictionary* dic in tmp) {
                [tales addObject:[Tale taleFromDictionary:dic]];
            }
        }
    }
    return tales;
}

+(void)removeAll {
    tales = nil;
}

// Create a new tale, but not add to tales list
+(Tale*)newTaleWithTale:(Tale*)_tale{
    Tale* tale = [[Tale alloc] init];
    tale.index = _tale.index;
    tale.title = _tale.title;
    tale.author = _tale.author;
    tale.created = _tale.created;
    tale.modified = _tale.modified;
    tale.pages = [[NSMutableArray alloc] initWithArray:_tale.pages];
    tale = _tale;
    return tale;
}

+(Tale*)newTale {
    Tale* tale = [[Tale alloc] init];
    tale.index = round([[NSDate date] timeIntervalSince1970]) * 100 + (arc4random() % 90) + 10;
    tale.title = @"";
    tale.author=@"";
    tale.created = round([[NSDate date] timeIntervalSince1970]);
    tale.modified = tale.created;
    tale.pages = [NSMutableArray array];
    return tale;
}

+(Tale*)newTalewithTitle: (NSString*)_title author:(NSString*)_author {
    Tale* tale = [[Tale alloc] init];
    tale.index = round([[NSDate date] timeIntervalSince1970]) * 100 + (arc4random() % 90) + 10;
    tale.title = _title;
    tale.author= _author;
    tale.created = round([[NSDate date] timeIntervalSince1970]);
    tale.modified = tale.created;
    
    Page *cover = [Page newCover];
    cover.text = _title;
    cover.pageFolder = [NSString stringWithFormat:@"%@/%.0f",[Lib taleFolderPathFromIndex:tale.index],cover.index];
    tale.pages = [NSMutableArray arrayWithObject:cover];
    
    return tale;
}


//Add a tale to tales list and saved to plist 
+(void)addTale:(Tale*)tale {
    [Tale tales];
    [tales addObject:tale];
    [Tale save];
}

+(void)updateTale:(Tale*)tale at:(NSInteger)index {
    [Tale tales];
    [tales replaceObjectAtIndex:index withObject:tale];
    [Tale save];
}

// Remove a tale from tales list and .plist
+(void)remove:(Tale*)tale {
    [Tale tales];
    NSString *talePath = [NSString stringWithFormat:@"%@/%@",[Lib applicationDocumentsDirectory],[Lib taleFolderPathFromIndex:tale.index]];
    NSLog(@"%@",talePath);
    
    
    [[NSFileManager defaultManager] removeItemAtPath:talePath error:nil];
    [tales removeObject:tale];
    [Tale save];
}

-(NSMutableDictionary*)taleToDictionay {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithDouble:self.index] forKey:@"index"];
    [dic setObject:[NSNumber numberWithDouble:self.created] forKey:@"created"];
    [dic setObject:[NSNumber numberWithDouble:self.modified] forKey:@"modified"];
    [dic setObject:self.title forKey:@"title"];
    [dic setObject:self.author forKey:@"author"];
    
    NSMutableArray* _pages = [NSMutableArray array];
    [dic setObject:_pages forKey:@"pages"];
    
    for (Page* page in self.pages) {
        [_pages addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithDouble:page.index],@"index",
                           page.image,@"image",
                           page.voice,@"voice",
                           page.text,@"text",
                           page.pageFolder,@"pageFolder",
                           [NSNumber numberWithDouble:page.created],@"created",
                           [NSNumber numberWithDouble:page.modified],@"modified",
                           [NSNumber numberWithInt:page.time],@"time",
                           [NSNumber numberWithInt:page.order],@"order",
                           [NSNumber numberWithBool:page.isCover],@"isCover",
                          nil]];
    }
    return dic;
}   

// Save tales list to .plist
+(void)save {
    [Tale tales];
    NSMutableArray* tmp = [NSMutableArray array];
    for (Tale* tale in tales) {
        [tmp addObject:[tale taleToDictionay]];
    }
    [tmp writeToFile:[Tale path] atomically:YES];
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
    NSLog(@"Upload completed");
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
