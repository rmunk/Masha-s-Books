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
@property (weak, nonatomic) IBOutlet UIImageView *pauseImage;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation SlikovnicaNavigationViewController
@synthesize scrollView = _scrollView;
@synthesize pageNumberLabel = _pageNumberLabel;
@synthesize pauseImage = _pauseImage;
@synthesize toolbar = _toolbar;
@synthesize bookNameLabel = _bookNameLabel;
@synthesize pageImages = _pageImages;
@synthesize currentPage = _currentPage;
@synthesize delegate = _delegate;
@synthesize textVisible = _textVisible;
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

#pragma mark - Toolbar buttons

- (IBAction)goBackToLibrary:(UIBarButtonItem *)sender
{
    [self.delegate navigationControllerClosedBook:self];
}

- (IBAction)turnVoiceOnOff:(UIBarButtonItem *)sender
{
    if (self.voiceOverPlay) {
        self.voiceOverPlay = FALSE;
        sender.style = UIBarButtonItemStyleBordered;
        sender.image = [UIImage imageNamed:@"voice-off.png"];
    }
    else {
        self.voiceOverPlay = TRUE;
        sender.style = UIBarButtonItemStyleDone;
        sender.image = [UIImage imageNamed:@"voice-on.png"];
    }
    if ([self.delegate respondsToSelector:@selector(navigationController:setVoiceoverPlay:)])
        [self.delegate navigationController:self setVoiceoverPlay:self.voiceOverPlay];
}

- (IBAction)turnTextOnOff:(UIBarButtonItem *)sender
{
    if (self.textVisible) {
        self.textVisible = NO;
        sender.style = UIBarButtonItemStyleBordered;
        sender.image = [UIImage imageNamed:@"text-off.png"];
    }
    else {
        self.textVisible = YES;
        sender.style = UIBarButtonItemStyleDone;
        sender.image = [UIImage imageNamed:@"text-on.png"];
    }
    if ([self.delegate respondsToSelector:@selector(navigationController:settextVisible:)])
        [self.delegate navigationController:self settextVisible:self.textVisible];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger pageCount = self.pageImages.count;
    const int border = 4;
    
    for (NSInteger i = 0; i < pageCount; ++i) {
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

- (void)viewDidAppear:(BOOL)animated
{
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, 768, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.toolbar.frame = CGRectMake(self.toolbar.frame.origin.x, -self.toolbar.frame.size.height, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
    self.pauseImage.alpha = 0;
    
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, 768 - self.scrollView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                         self.toolbar.frame = CGRectMake(self.toolbar.frame.origin.x, 0, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
                         self.pauseImage.alpha = 1;
                     }];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageNumberLabel:nil];
    [self setBookNameLabel:nil];
    [self setPauseImage:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Navigation controller exits

- (IBAction)tapReturn:(UITapGestureRecognizer *)sender
{
    UIImageView *currentPageView = (UIImageView *)[self.scrollView viewWithTag:self.currentPage];
    if ([currentPageView respondsToSelector:@selector(setHighlighted:)])
        currentPageView.highlighted = FALSE;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, 768, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                         self.toolbar.frame = CGRectMake(self.toolbar.frame.origin.x, -self.toolbar.frame.size.height, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
                         self.pauseImage.alpha = 0;
                     } completion:^(BOOL finished){
                         if (finished) {
                             [self.delegate navigationController:self didChoosePage:-1];
                             [self.view removeFromSuperview];
                         }
                     }];
}

- (void)userTappedImage:(UITapGestureRecognizer *)sender
{
    UIImageView *page = (UIImageView *)sender.view;
    
    UIImageView *currentPageView = (UIImageView *)[self.scrollView viewWithTag:self.currentPage];
    if ([currentPageView respondsToSelector:@selector(setHighlighted:)])
        currentPageView.highlighted = FALSE;

    //    page.highlighted = TRUE;
    
    //    NSLog(@"Skip to Page %d", page.tag);
    [self.delegate navigationController:self didChoosePage:page.tag];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, 768, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                         
                     } completion:^(BOOL finished){
                         if (finished) {
                             [self.view removeFromSuperview];
                         }
                     }];
}

@end
