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
@property (strong, nonatomic) IBOutlet UIImageView *pageImage;
@property (weak, nonatomic) IBOutlet UIImageView *textImage;
@end

@implementation SlikovnicaDataViewController
@synthesize page = _page;
@synthesize textVisibility = _textVisibility;
@synthesize pageImage = _pageImage;
@synthesize textImage = _textImage;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Page %@", self.page.pageNumber];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.description);
}

- (void)viewDidUnload
{
    [self setPageImage:nil];
    [self setTextImage:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.page)
    {
        self.pageImage.image = self.page.image;
        if (self.textVisibility)
            self.textImage.image = self.page.text;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
