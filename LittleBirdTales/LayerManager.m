//
//  LayerManager.m
//  pickerSample
//
//  Created by Mac on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LayerManager.h"
#define PADDING 5
@implementation LayerManager

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)select:(id)sender {
    [self setSelectedLayer:sender];
}

-(Layer*)selectedLayer {
    for (UIView* aView in self.subviews) {
        if ([aView isKindOfClass:[Layer class]] && 
            [(Layer*)aView isSelected]) {
            return (Layer*)aView;
        }
    }
    return nil;
}

-(void)addTextLayer:(NSString*)text {
    TextLayer* textLayer = [[TextLayer alloc] initWithFrame:self.bounds];
    [self addSubview:textLayer];
    textLayer.textLabel.text = text;
    textLayer.delegate = self;
    [self setSelectedLayer:textLayer];
}

-(void)setSelectedLayer:(Layer*)layer {
    for (UIView* aView in self.subviews) {
        if (layer != aView && [aView isKindOfClass:[Layer class]]) {
            [(Layer*)aView setIsSelected:NO];
        }
    }
    if (layer) {
        [layer setIsSelected:YES];        
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setSelectedLayer:nil];
}
@end
