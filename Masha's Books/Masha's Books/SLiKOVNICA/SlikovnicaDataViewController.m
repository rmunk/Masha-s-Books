//
//  SlikovnicaDataViewController.m
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SlikovnicaDataViewController.h"
#import "SlikovnicaModelController.h"

@interface SlikovnicaDataViewController () <AVAudioPlayerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *dataImage;
@end

@implementation SlikovnicaDataViewController
@synthesize dataImage = _dataImage;
@synthesize dataObject = _dataObject;
@synthesize pageNumber = _pageNumber;

- (SlikovnicaPage *)page
{
    if([self.dataObject isKindOfClass:[SlikovnicaPage class]])
    {
        return self.dataObject;
    }
    else return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Page %d", self.pageNumber];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.description);
}

- (void)viewDidUnload
{
    [self setDataImage:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.page)
    {
        self.dataImage.image = [UIImage imageWithContentsOfFile:self.page.image];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
