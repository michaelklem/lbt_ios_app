//
//  LayerManager.h
//  pickerSample
//
//  Created by Mac on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Layer.h"
#import "TextLayer.h"

@interface LayerManager : UIView <LayerDelegate> {

}
-(void)addTextLayer:(NSString*)text;
-(void)setSelectedLayer:(Layer*)layer;
-(Layer*)selectedLayer;

@end
