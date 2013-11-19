#import <Foundation/Foundation.h>
@interface ColorPickerImageView : UIImageView {
    CGContextRef cachedImage;
    unsigned char* cachedImageData;
    size_t cachedImageW;
}


-(UIColor*) getPixelColorAtLocation:(CGPoint)point;
-(CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage;
-(UIColor*) getPixelColorAtLocationCached:(CGPoint)point;
-(void) cacheImage;
-(void) releaseCache;

@end