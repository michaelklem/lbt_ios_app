//
//  GalleryCell.m
//  LittleBirdTales
//
//  Created by Deep Blue on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryCell.h"
#import "Lib.h"

@implementation GalleryCell
@synthesize index, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setThumbnail:(NSString*)imageName editMode:(BOOL)editMode{
    
    NSString *filePath = [NSString stringWithFormat:@"%@/gallery/%@",[Lib applicationDocumentsDirectory],imageName];
    UIImage *thumbnail = [UIImage imageWithContentsOfFile:filePath];
    
    switch (index) {
        case 1:
            [thumbnail02 setImage:thumbnail forState:UIControlStateNormal];
            [thumbnail02 setTitle:imageName forState:UIControlStateDisabled];
            if (editMode) {
                thumbnail02.alpha = 0.4f;
            }
            break;
        case 2:
            [thumbnail03 setImage:thumbnail forState:UIControlStateNormal];
            [thumbnail03 setTitle:imageName forState:UIControlStateDisabled];
            if (editMode) {
                thumbnail03.alpha = 0.4f;
            }
            break;
        case 3:
            [thumbnail04 setImage:thumbnail forState:UIControlStateNormal];
            [thumbnail04 setTitle:imageName forState:UIControlStateDisabled];
            if (editMode) {
                thumbnail04.alpha = 0.4f;
            }
            break;
            
        default:
            index = 0;
            [thumbnail01 setImage:thumbnail forState:UIControlStateNormal];
            [thumbnail01 setTitle:imageName forState:UIControlStateDisabled];
            if (editMode) {
                thumbnail01.alpha = 0.4f;
            }
            break;
    }
    index++;
}

- (IBAction)selectImage:(id)sender{
    UIButton *button = (UIButton*) sender;
    NSString *imageName = [button titleForState:UIControlStateDisabled];
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@".jpg.jpg" withString:@".jpg"];
    if (delegate && ![imageName isEqualToString:@""] && imageName != NULL) {
        
        [delegate selectImage:imageName];
    }
}

@end
