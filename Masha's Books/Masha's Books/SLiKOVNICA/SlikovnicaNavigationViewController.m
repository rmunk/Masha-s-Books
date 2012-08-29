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
    else{
        self.pageNumberLabel.title = [NSString stringWithFormat:@"%d/%d", currentPage, self.pageImages.count - 1];
        UIImageView *currentPageView = (UIImageView *)[self.scrollView viewWithTag:currentPage];
        if ([currentPageView respondsToSelector:@selector(setHighlighted:)])
            currentPageView.highlighted = TRUE;
        [self.scrollView scrollRectToVisible:currentPageView.frame animated:YES];
    }
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
    const int border = 4;
    
    for (NSInteger i = 1; i < pageCount; ++i) {
        CGRect frame = CGRectMake(0, 0, 159, 128);
        self.scrollView.contentSize = CGSizeMake(border + (frame.size.width + border / 2) * (pageCount - 1), frame.size.height + border * 2);
        frame.origin.x = border + (frame.size.width + border / 2) * (i - 1);
        frame.origin.y = border;
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filmstrip-norm.png"] highlightedImage:[UIImage imageNamed:@"filmstrip-selected.png"]];
        newPageView.tag = i;
        newPageView.contentMode = UIViewContentModeBottom;
        newPageView.frame = frame;
        newPageView.userInteractionEnabled = YES;
        [newPageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
        
        UIImageView *pageThumbnail = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:i]];
        pageThumbnail.contentMode = UIViewContentModeBottomLeft;
        pageThumbnail.frame = CGRectInset(newPageView.bounds, 8, 12);
        
        [newPageView addSubview:pageThumbnail];
        
        [self.scrollView addSubview:newPageView];
    }
}

- (IBAction)tapReturn:(UITapGestureRecognizer *)sender
{
    UIImageView *currentPageView = (UIImageView *)[self.scrollView viewWithTag:self.currentPage];
    if ([currentPageView respondsToSelector:@selector(setHighlighted:)])
        currentPageView.highlighted = FALSE;
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
    UIImageView *currentPageView = (UIImageView *)[self.scrollView viewWithTag:self.currentPage];
    if ([currentPageView respondsToSelector:@selector(setHighlighted:)])
        currentPageView.highlighted = FALSE;
    NSLog(@"Skip to Page %d", page.tag);
    [self.delegate navigationController:self didChoosePage:page.tag];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
