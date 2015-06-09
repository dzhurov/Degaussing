//
//  DegaussingAppDelegate.h
//  Degaussing
//
//  Created by ZiM on 04.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DegaussingViewController;

@interface DegaussingAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet DegaussingViewController *viewController;

@end
