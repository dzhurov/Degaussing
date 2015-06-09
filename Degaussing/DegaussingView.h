//
//  DegaussingView.h
//  Degaussing
//
//  Created by ZiM on 04.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface DegaussingView : UIView {
    UIImage     *currentImage;
    CALayer     *sceneLayer;
    CALayer     *sceneSublayer;
    CALayer     *imageLayer;
    CALayer     *rippedImageLayer;
    CALayer     *reflectionLayer;
    CALayer     *rainbowMask;
    CALayer     *rainbowSuperlayer; //CНОВА ОПИСАТЬ!
    CAGradientLayer *threeColorRainbow;
    CALayer     *pelinOnOffLayer;

    BOOL        isTurned;
}
@property (nonatomic, retain) CALayer* imageLayer;

- (CGImageRef)scaleImage:(UIImage *)origImage;
- (void)setCurrentImage:(UIImage *)image;
- (CGRect)rectForImage:(CGImageRef) imageRef;
- (void)degaussingAnimation;
- (void)degaussingAnimationFrame: (NSTimer*)theTimer;
- (CALayer*)imageRipLayer: (CGImageRef)imageRef;
- (void)onOffAnimation;
- (void)turnOnAnimationFrame:(NSTimer*)theTimer;
- (void)turnOffAnimationFrame:(NSTimer*)theTimer;


@end
