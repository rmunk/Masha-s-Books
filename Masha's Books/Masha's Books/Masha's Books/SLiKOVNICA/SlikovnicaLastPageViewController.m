//
//  SlikovnicaLastPageViewController.m
//  Masha's Books
//
//  Created by Ranko Munk on 9/15/12.
//
//

#import "SlikovnicaLastPageViewController.h"

@interface SlikovnicaLastPageViewController ()

@end

@implementation SlikovnicaLastPageViewController

- (NSString *)description
{
    return @"Last Page";
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - User actions

- (IBAction)readAgain:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"readAgain" object:self];
}

- (IBAction)goBackToLibrary:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"goBackToLibrary" object:self];
}

@end
