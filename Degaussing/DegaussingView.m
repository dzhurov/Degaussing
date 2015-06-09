//
//  DegaussingView.m
//  Degaussing
//
//  Created by ZiM on 04.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DegaussingView.h"
#import <QuartzCore/QuartzCore.h>


CGFloat movementFunc(CGFloat arg)
{
    const CGFloat domainOfFunc = 4.0f;
    const CGFloat crossPoint = 1.06f;
    arg *= domainOfFunc/kFramesPerDegaussingAnimation;
    if  (arg >= crossPoint)
        return (sin(arg+0.5)+1)/2;
    return (-cos(arg*3)+1)/2;
}

CGFloat swingFunc(CGFloat arg)
{
    const CGFloat domainOfFunc = M_PI;
    arg *= domainOfFunc/kFramesPerDegaussingAnimation;
    return (cos(arg)+1)/2;
}


@implementation DegaussingView

@synthesize imageLayer;

- (void)setCurrentImage:(UIImage *)image
{
    if (image == currentImage) 
        return;
    [currentImage release];
    currentImage = [image retain];
   
    CGImageRef drawnImage = [self scaleImage:currentImage];
    
    if ([sceneSublayer.sublayers count] != 0) {
        // remove all sublayers from imageLayer
        NSArray *sublayers = [NSArray arrayWithArray:[sceneSublayer sublayers]];
        for(CALayer *layer in sublayers) {
            [layer removeFromSuperlayer];
        }
    }
    imageLayer = [CALayer layer];
    imageLayer.frame = [self rectForImage:drawnImage];
    imageLayer.contents = (id)drawnImage;
    
    rippedImageLayer = [self imageRipLayer:drawnImage];
    rippedImageLayer.hidden = NO;
    reflectionLayer = [self imageRipLayer:drawnImage];
    reflectionLayer.hidden = YES;
    reflectionLayer.opacity = 0.5;
    rainbowMask = [self imageRipLayer:drawnImage];
    [rainbowMask retain];
    [sceneSublayer addSublayer: imageLayer];
    [sceneSublayer addSublayer: rippedImageLayer];
    [sceneSublayer addSublayer:reflectionLayer];
    
    rainbowSuperlayer = [CALayer layer];
    rainbowSuperlayer.frame = CGRectMake(0, 0, kMaxWidth, kMaxHeight);
    rainbowSuperlayer.mask = rainbowMask;
    rainbowSuperlayer.hidden = YES;
    rainbowSuperlayer.opacity = 0.5;
    
    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:60];
    for (int i=0; i<10; i++){
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGFloat red[] = {1, 0, 0, 1},
        green[] =       {0, 1, 0, 1},
        blue[] =        {0, 0, 1, 1},
        clear[] =       {0, 0, 0, 1};
        [colors addObject:(id)CGColorCreate(colorspace, red)];
        
        [colors addObject:(id)CGColorCreate(colorspace, green)];
        [colors addObject:(id)CGColorCreate(colorspace, blue)];
        [colors addObject:(id)CGColorCreate(colorspace, clear)];
        [colors addObject:(id)CGColorCreate(colorspace, clear)];
        [colors addObject:(id)CGColorCreate(colorspace, clear)];
        
    }
    threeColorRainbow = [CAGradientLayer layer];
    threeColorRainbow.colors = colors; 
    threeColorRainbow.frame = CGRectMake(0, 0, kMaxWidth, kMaxHeight);
    for (id color in colors){
        CGColorRelease((CGColorRef)color);
    }
    [colors release];
    [rainbowSuperlayer addSublayer:threeColorRainbow];
    [sceneSublayer addSublayer:rainbowSuperlayer];
    
    pelinOnOffLayer = [CALayer layer];
    pelinOnOffLayer.frame = imageLayer.frame;
    pelinOnOffLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    pelinOnOffLayer.hidden = YES;
    [sceneSublayer addSublayer:pelinOnOffLayer];
    
    if (!isTurned)
        [self onOffAnimation];
    
    CGImageRelease(drawnImage);

    //[imageLayer renderInContext: UIGraphicsGetCurrentContext()];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        isTurned = NO;
        sceneLayer = [CALayer layer];
        sceneLayer.frame = CGRectMake(0, 0, kMaxWidth, kMaxHeight);
        sceneLayer.masksToBounds = YES;
        [self.layer addSublayer:sceneLayer];
        sceneSublayer = [CALayer layer];
        [sceneSublayer removeAllAnimations];
        sceneSublayer.frame = CGRectMake(0, 0, kMaxWidth, kMaxHeight);
        [sceneLayer addSublayer:sceneSublayer];
        [self setCurrentImage:[UIImage imageNamed:@"table.png"]];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)rectForImage:(CGImageRef) imageRef
{
    CGFloat width = CGImageGetWidth(imageRef),
            height = CGImageGetHeight(imageRef);
    return CGRectMake((kMaxWidth - width)/2, (kMaxHeight - height)/2,
                      width, height);        
}

- (CGImageRef)scaleImage:(UIImage *)origImage 
{
    CGSize origImageSize = [origImage size];
    CGFloat scale = 1.0f, scaleX, scaleY;
    scaleX = kMaxWidth / origImageSize.width;
    scaleY = kMaxHeight / origImageSize.height;
    CGImageRef subImage = NULL;
    //CGFloat offsetX = 0, offsetY = 0;
    if ((scaleX<1)||(scaleY<1)) 
        scale = (scaleX<scaleY)? scaleX : scaleY;
    CGRect subRect = CGRectMake(0, 0, scale*origImageSize.width, scale*origImageSize.height);
    
    subImage = [origImage CGImage];
    
    
    // scale the image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, scale*origImageSize.width, 
                                                 scale*origImageSize.height, 8, 0, colorSpace, 
                                                 kCGImageAlphaPremultipliedFirst); 
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, subRect, subImage);
    CGContextFlush(context);
    // get the scaled image
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGContextRelease (context);
    //CGImageRelease(subImage);
    subImage = NULL;
    subImage = scaledImage;
    return subImage;
    
}

- (CALayer*)imageRipLayer:(CGImageRef)imageRef
{
    CALayer *ripLayer = [CALayer layer];
    NSUInteger imageWidth = CGImageGetWidth(imageRef),
               imageHeight = CGImageGetHeight(imageRef),
               numOfRows = imageHeight/kHeightOfRippedImageRow;
    for (int i=0; i<numOfRows; i++) {
        CGRect rowRect = CGRectMake(0, i*kHeightOfRippedImageRow, imageWidth, kHeightOfRippedImageRow);
        CGRect rowLayerRect = rowRect;
        rowLayerRect.origin.x+=imageLayer.frame.origin.x;
        rowLayerRect.origin.y+=imageLayer.frame.origin.y;
        CALayer *rowLayer = [CALayer layer];
        rowLayer.frame = rowLayerRect;
        CGImageRef rowImageRef= CGImageCreateWithImageInRect(imageRef, rowRect);
        rowLayer.contents = (id)rowImageRef;
        [ripLayer addSublayer:rowLayer];
    }
    NSUInteger lastRowHeight = imageHeight % kHeightOfRippedImageRow;
    if (lastRowHeight !=0) {
        CGRect rowRect = CGRectMake(0, imageHeight-lastRowHeight, imageWidth, lastRowHeight);
        CGRect rowLayerRect = rowRect;
        rowLayerRect.origin.x+=imageLayer.frame.origin.x;
        rowLayerRect.origin.y+=imageLayer.frame.origin.y;
        CALayer *rowLayer = [CALayer layer];
        rowLayer.frame = rowLayerRect;
        CGImageRef rowImageRef= CGImageCreateWithImageInRect(imageRef, rowRect);
        rowLayer.contents = (id)rowImageRef;
        [ripLayer addSublayer:rowLayer];
    }
    return ripLayer;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Drawing code
}*/



- (void)degaussingAnimation
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/kFPS target:self selector:@selector(degaussingAnimationFrame:) userInfo:nil repeats:YES];
    [timer fire];
}


- (void)transformRayLayersWithFrameNumber: (NSUInteger)frameNum
{
    NSArray *raws = [rippedImageLayer sublayers];
    NSArray *reflectionRaws = [reflectionLayer sublayers];
    NSArray *rainbowRaws = [rainbowMask sublayers];
    for (int i=0; i<[raws count]; i++) {
        CALayer *raw = [raws objectAtIndex:i];
        CALayer *refRaw = [reflectionRaws objectAtIndex:i];
        CALayer *maskRaw = [rainbowRaws objectAtIndex:i];
        
        CGAffineTransform ripAndMaskTransform = CGAffineTransformMake(1, 0, 0, 1, swingFunc(frameNum)*(20+i*0.3)*sin(frameNum+0.1*i), 0);
        CGAffineTransform reflectionTransform = CGAffineTransformMake(1, 0, 0, 1, -swingFunc(frameNum)*(20+i*0.3)*sin(frameNum+0.1*i), 0);
        
        [raw setAffineTransform: ripAndMaskTransform];
        [refRaw setAffineTransform: reflectionTransform];
        [maskRaw setAffineTransform:ripAndMaskTransform];
    }
}

- (void)exfoliationRayLayersWithFrameNumber: (NSUInteger)frameNum
{
    NSInteger maxMovement = 10;
    
    static CGPoint rawsPoint;
    static CGPoint reflectionRawsPoint;
    if (frameNum == 0) {
        rawsPoint.x = -random()%(maxMovement*2);
        rawsPoint.y = random()%(maxMovement/3) - maxMovement/3;
        reflectionRawsPoint.x = -rawsPoint.x;
        reflectionRawsPoint.y = -rawsPoint.y;
    }
    CGFloat arg = movementFunc(frameNum);
    [rippedImageLayer setAffineTransform:CGAffineTransformMake(1, 0, 0, 1, rawsPoint.x*arg, rawsPoint.y*arg)];
    [reflectionLayer setAffineTransform: CGAffineTransformMake(1, 0, 0, 1, reflectionRawsPoint.x*arg, reflectionRawsPoint.y*arg)];
}

- (void)threeColorRainbowAnimationFrame:(NSUInteger)frameNum
{
    
    rainbowSuperlayer.opacity = 0.4*movementFunc( frameNum);
    [threeColorRainbow setAffineTransform:CGAffineTransformMake(1, 0, 0, 1/swingFunc(frameNum), 0, 20*movementFunc(frameNum))];
}

- (void)sceneSublayerTransformAnimation: (NSUInteger)frameNum
{
    
    [sceneSublayer setAffineTransform:CGAffineTransformMake(1, swingFunc(frameNum)*0.05*sin(frameNum*0.4), swingFunc(frameNum)*0.05*sin(frameNum*0.4), 1, 0, 0)];
}

- (void)degaussingAnimationFrame:(NSTimer *)theTimer
{
    static NSUInteger framesCounter = 0;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
    imageLayer.hidden = YES;
    rippedImageLayer.hidden = NO;
    reflectionLayer.hidden = NO;
    rainbowSuperlayer.hidden = NO;
    [self transformRayLayersWithFrameNumber:framesCounter];
    [self exfoliationRayLayersWithFrameNumber:framesCounter];
    [self threeColorRainbowAnimationFrame:framesCounter];
    [self sceneSublayerTransformAnimation:framesCounter];
    
    framesCounter++;
    if (framesCounter >= kFramesPerDegaussingAnimation){
        framesCounter = 0;
        [sceneSublayer setAffineTransform:CGAffineTransformMake(1, 0, 0, 1, 0, 0)];
        imageLayer.hidden = NO;
        rippedImageLayer.hidden = YES;
        reflectionLayer.hidden = YES;
        rainbowSuperlayer.hidden = YES;
        [theTimer invalidate];
    }
    
    [CATransaction commit];

}

- (void)onOffAnimation
{
    SEL animationType;
    if (isTurned == NO) 
        animationType = @selector(turnOnAnimationFrame:);
    else
        animationType = @selector(turnOffAnimationFrame:);
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/kFPS target:self selector:animationType userInfo:nil repeats:YES];
    [timer fire];
    isTurned = !isTurned;
}

- (void)horizontalSweepAnimation:(NSUInteger)frameNum
{
    pelinOnOffLayer.opacity = 1.0;
    CGFloat swippingLineRefers = kHeightOfSwippingOnOffLine/pelinOnOffLayer.frame.size.height;
    
    sceneSublayer.opacity = frameNum*(1/kFramesPerOnOffVerticalSweep);
    CGAffineTransform transformation = [sceneSublayer affineTransform];
    transformation.a = frameNum*(1/kFramesPerOnOffHorizontalSweep);
    transformation.d = swippingLineRefers;
    [sceneSublayer setAffineTransform:transformation];
}

- (void)verticalSweepAnimation:(NSUInteger)frameNum
{
    pelinOnOffLayer.opacity = 1-frameNum*(1/kFramesPerOnOffVerticalSweep);
    CGAffineTransform transformation = [sceneSublayer affineTransform];
    CGFloat swippingLineRefers = kHeightOfSwippingOnOffLine/pelinOnOffLayer.frame.size.height;
    transformation.d = ((1-swippingLineRefers)*frameNum/kFramesPerOnOffVerticalSweep + swippingLineRefers) ;
    [sceneSublayer setAffineTransform:transformation];
}

- (void)turnOnAnimationFrame:(NSTimer *)theTimer
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];

    static NSUInteger framesCounter = 0;
    pelinOnOffLayer.hidden = NO;
    if (framesCounter <= kFramesPerOnOffHorizontalSweep){
        [self horizontalSweepAnimation:framesCounter];
    }
    else if (framesCounter <= kFramesPerOnOffHorizontalSweep + kFramesPerOnOffVerticalSweep){
        [self verticalSweepAnimation:framesCounter - kFramesPerOnOffHorizontalSweep];
    }
    else {
        framesCounter = 0;
        pelinOnOffLayer.hidden = YES;
        [theTimer invalidate];
    }
    framesCounter++;
    
    [CATransaction commit];
}

- (void)turnOffAnimationFrame:(NSTimer *)theTimer
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
    static NSUInteger framesCounter = 0;
    pelinOnOffLayer.hidden = NO;
    if (framesCounter <= kFramesPerOnOffVerticalSweep){
        [self verticalSweepAnimation: kFramesPerOnOffVerticalSweep - framesCounter];
    }
    else if (framesCounter <= kFramesPerOnOffHorizontalSweep + kFramesPerOnOffVerticalSweep){
        [self horizontalSweepAnimation: 
            kFramesPerOnOffHorizontalSweep + kFramesPerOnOffVerticalSweep - framesCounter];
    }
    else {
        framesCounter = 0;
        pelinOnOffLayer.hidden = YES;
        [theTimer invalidate];
    }
    framesCounter++;
    
    [CATransaction commit];
}


- (void)dealloc
{   
    [sceneLayer release];
    [currentImage release];
    [super dealloc];
}

@end
