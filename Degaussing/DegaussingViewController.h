//
//  DegaussingViewController.h
//  Degaussing
//
//  Created by ZiM on 04.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DegaussingView.h"

@interface DegaussingViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    UIImageView *imageView;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
- (IBAction)play:(id)sender;
- (IBAction)openImage:(id)sender;
- (IBAction)onOff:(id)sender;


@end
