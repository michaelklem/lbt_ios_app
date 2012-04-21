//
//  Tale.h
//  LittleBirdTales
//
//  Created by Mac on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tale : NSObject
@property (nonatomic, assign) double index;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* author;
@property (nonatomic, assign) double created; // time interval since 1970
@property (nonatomic, assign) double modified; // time interval since 1970
@property (nonatomic, retain) NSMutableArray* pages;

// list of tales saved
+(NSMutableArray*)tales; 

// Create a new tale, but not add to tales list
+(Tale*)newTale;
+(Tale*)newTaleWithTale:(Tale*)_tale;
+(Tale*)newTalewithTitle: (NSString*)_title author:(NSString*)_author;
//Add a tale to tales list and saved to plist 
+(void)addTale:(Tale*)tale;

//Update tale
+(void)updateTale:(Tale*)tale at:(NSInteger)index;

// Remove a tale from tales list and .plist
+(void)remove:(Tale*)tale;

// Save tales list to .plist
+(void)save;


- (NSString*)uploadWithUserId: (NSString*)userId andBucketPath: (NSString*)bucketPath ;
- (BOOL)deleteOrphanFiles;
@end
