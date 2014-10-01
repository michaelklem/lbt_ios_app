//
//  Tale.h
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tale.h"

@interface Lesson : Tale
@property (nonatomic, assign) double index;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* author;
@property (nonatomic, assign) double created; // time interval since 1970
@property (nonatomic, assign) double modified; // time interval since 1970
@property (nonatomic, retain) NSMutableArray* pages;

// list of tales saved
+(NSMutableArray*)lessons;

// Create a new lesson, but not add to lessons list
+(Lesson*)newLesson;
+(Lesson*)newLessonWithLesson:(Lesson*)_lesson;
+(Lesson*)newLessonwithTitle: (NSString*)_title author:(NSString*)_author;
//Add a tale to lessons list and saved to plist
+(void)addLesson:(Lesson*)lesson;

//Update tale
+(void)updateLesson:(Lesson*)lesson at:(NSInteger)index;

// Remove a tale from lessons list and .plist
+(void)remove:(Lesson*)lesson;

// Save tales list to .plist
+(void)save;


- (NSString*)uploadWithUserId: (NSString*)userId andBucketPath: (NSString*)bucketPath ;
- (BOOL)deleteOrphanFiles;
@end
