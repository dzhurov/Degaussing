//
//  DegaussingViewController.m
//  Degaussing
//
//  Created by ZiM on 04.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DegaussingViewController.h"

@implementation DegaussingViewController
@synthesize imageView;

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)play:(id)sender {
    [UIView setAnimationsEnabled:NO];
    DegaussingView *degaussingView = (DegaussingView *)self.view;
    [degaussingView degaussingAnimation];
}

- (IBAction)openImage:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker setDelegate: self];
        // Picker is displayed asynchronously.
        [self presentModalViewController:picker animated:YES];
    } else {
        // pop up an alert
    }
}

- (IBAction)onOff:(id)sender {
    DegaussingView *degaussingView = (DegaussingView *)self.view;
    [degaussingView onOffAnimation];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)newImage editingInfo:(NSDictionary *)editingInfo
{
    DegaussingView *degaussianView =  (DegaussingView*)self.view;
    [degaussianView setCurrentImage:newImage]; 
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}
@end
