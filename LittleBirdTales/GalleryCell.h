//
//  GalleryCell.h
//  LittleBirdTales
//
//  Created by Deep Blue on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GalleryCellDelegate 
@required 
-(void)selectImage:(NSString*)imageName;
@end

@interface GalleryCell : UITableViewCell {
    IBOutlet UIButton*thumbnail01;
    IBOutlet UIButton *thumbnail02;
    IBOutlet UIButton *thumbnail03;
    IBOutlet UIButton *thumbnail04;
    
}

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, retain) id <GalleryCellDelegate> delegate;

- (void)setThumbnail:(NSString*)imageName editMode:(BOOL)editMode;
- (IBAction)selectImage:(id)sender;
@end
