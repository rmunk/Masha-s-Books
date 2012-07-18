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
@synthesize textVisibility = _textVisibility;
@synthesize voiceOverPlay = _voiceOverPlay;

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    if (currentPage == 0) self.pageNumberLabel.title = @"";
    else self.pageNumberLabel.title = [NSString stringWithFormat:@"%d/%d", currentPage, self.pageImages.count - 1];    
}

- (IBAction)goBackToLibrary:(UIBarButtonItem *)sender 
{
//    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    UIViewController *initialSettingsVC = [settingsStoryboard instantiateInitialViewController];
//    initialSettingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentModalViewController:initialSettingsVC animated:YES];
    [self.delegate navigationControllerClosedBook:self];
}

- (IBAction)turnVoiceOnOff:(UIBarButtonItem *)sender 
{
    if (self.voiceOverPlay) {
        self.voiceOverPlay = FALSE;
        sender.style = UIBarButtonItemStyleBordered;
        sender.title = @"Voice OFF";
    }
    else {
        self.voiceOverPlay = TRUE;
        sender.style = UIBarButtonItemStyleDone;
        sender.title = @"Voice ON";
    }
    if ([self.delegate respondsToSelector:@selector(navigationController:SetVoiceoverPlay:)])
        [self.delegate navigationController:self setVoiceoverPlay:self.voiceOverPlay];
}

- (IBAction)turnTextOnOff:(UIBarButtonItem *)sender 
{
    if (self.textVisibility) {
        self.textVisibility = FALSE;
        sender.style = UIBarButtonItemStyleBordered;
        sender.title = @"Text OFF";
    }
    else {
        self.textVisibility = TRUE;
        sender.style = UIBarButtonItemStyleDone;
        sender.title = @"Text ON";
    }
    if ([self.delegate respondsToSelector:@selector(navigationController:SetTextVisibility:)])
        [self.delegate navigationController:self setTextVisibility:self.textVisibility];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger pageCount = self.pageImages.count;
    
    for (NSInteger i = 0; i < pageCount; ++i) {
        CGRect frame = CGRectMake(0, 0, self.scrollView.bounds.size.height * 1.2, self.scrollView.bounds.size.height);
        self.scrollView.contentSize = CGSizeMake(frame.size.width * pageCount, frame.size.height);
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, 0.0f, 10.0f);
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:i]];
        newPageView.tag = i;
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        newPageView.userInteractionEnabled = YES;
        newPageView.alpha = 1;
        newPageView.opaque = TRUE;
        [newPageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
        if (i == self.currentPage)
        {
            // Dodaj okvir oko te slike
        }
        [self.scrollView addSubview:newPageView];
    }        
}

- (IBAction)tapReturn:(UITapGestureRecognizer *)sender 
{
    [self.delegate navigationController:self didChoosePage:-1];
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
    [self.delegate navigationController:self didChoosePage:page.tag];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
