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
@synthesize page = _page;
@synthesize dataImage = _dataImage;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Page %d", [self.page.pageNumber intValue]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(self.description);
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
        self.dataImage.image = self.page.image;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
