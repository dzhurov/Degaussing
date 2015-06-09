//
//  Constants.h
//  Degaussing
//
//  Created by ZiM on 04.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
static const CGFloat kMaxWidth = 320.0f;
static const CGFloat kMaxHeight = 460.0f - 44.0f; //  -UIToolbar.height
static const CGFloat kFPS = 60.0f;   //Frames Per Second
static const CGFloat kDurationDegaussingAnimation = 2.5f; // seconds
static const CGFloat kFramesPerDegaussingAnimation = 2.5 * 30.0; 
static const CGFloat kFramesPerOnOffHorizontalSweep = 0.5 * 30.0;
static const CGFloat kFramesPerOnOffVerticalSweep = 0.3 * 30.0;
static const NSUInteger kHeightOfRippedImageRow = 2; //pixels
static const NSUInteger kHeightOfSwippingOnOffLine = 5; //pixels