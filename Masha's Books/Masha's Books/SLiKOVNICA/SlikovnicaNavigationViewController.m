//
//  SlikovnicaNavigationViewController.m
//  My Way
//
//  Created by Ranko Munk on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlikovnicaNavigationViewController.h"

@interface SlikovnicaNavigationViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pageNumberLabel;

@end

@implementation SlikovnicaNavigationViewController
@synthesize scrollView = _scrollView;
@synthesize pageNumberLabel = _pageNumberLabel;
@synthesize bookNameLabel = _bookNameLabel;
@synthesize pageImages = _pageImages;
@synthesize currentPage = _currentPage;
@synthesize delegate = _delegate;

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    if (currentPage == 0) self.pageNumberLabel.title = @"";
    else self.pageNumberLabel.title = [NSString stringWithFormat:@"%d/%d", currentPage, self.pageImages.count - 1];    
}

- (IBAction)goBackToLibrary:(UIBarButtonItem *)sender 
{
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *initialSettingsVC = [settingsStoryboard instantiateInitialViewController];
    initialSettingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialSettingsVC animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger pageCount = self.pageImages.count;
    
    for (NSInteger i = 0; i < pageCount; ++i) {
        CGRect frame = CGRectMake(0, 0, self.scrollView.bounds.size.height * 1.33, self.scrollView.bounds.size.height);
        self.scrollView.contentSize = CGSizeMake(frame.size.width * pageCount, frame.size.height);
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, 10.0f, 10.0f);
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:i]];
        newPageView.tag = i;
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        newPageView.userInteractionEnabled = YES;
        newPageView.alpha = 1;
        [newPageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
        
        [self.scrollView addSubview:newPageView];
    }        
}
- (IBAction)tapReturn:(UITapGestureRecognizer *)sender 
{
    [self.delegate NavigationController:self DidChoosePage:-1];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageNumberLabel:nil];
    [self setBookNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)userTappedImage:(UITapGestureRecognizer *)sender 
{
    UIView *page = sender.view;
    NSLog(@"Skip to Page %d", page.tag);
    [self.delegate NavigationController:self DidChoosePage:page.tag];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
