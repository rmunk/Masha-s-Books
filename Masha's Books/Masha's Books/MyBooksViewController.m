//
//  MyBooksViewController.m
//  Masha's Books
//
//  Created by Ranko Munk on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBooksViewController.h"
#import "MyLibrary.h"

@interface MyBooksViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) MyLibrary *modelController;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *scrollViewContainer;
@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;
@end

@implementation MyBooksViewController
@synthesize modelController = _modelController;
@synthesize dataSource = _dataSource;
@synthesize scrollView = _scrollView;
@synthesize scrollViewContainer = _scrollViewContainer;
@synthesize pageImages = _pageImages;
@synthesize pageViews = _pageViews;

- (MyLibrary *)modelController
{
    if (!_modelController) {
        _modelController = [[MyLibrary alloc] init];
    }
    return _modelController;
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger numbrOfPagesOnScreen = self.scrollViewContainer.frame.size.width / self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    
    // Work out which pages we want to load
    NSInteger firstPage = page - numbrOfPagesOnScreen / 2 - 1;
    NSInteger lastPage = page + numbrOfPagesOnScreen / 2 + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<[self.dataSource numberOfBooksInMyLibrary]; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= [self.dataSource numberOfBooksInMyLibrary]) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, 50.0f, 0.0f);
        
//        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.dataSource BookCoverImageAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        newPageView.tag = page;
        newPageView.userInteractionEnabled = YES;
        [newPageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= [self.dataSource numberOfBooksInMyLibrary]) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Books";
    self.dataSource = self.modelController;

    // Set up the array to hold the views for each page
    NSInteger pageCount = [self.dataSource numberOfBooksInMyLibrary];
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * [self.dataSource numberOfBooksInMyLibrary], pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
    
    
    
//    NSInteger pageCount = [self.dataSource numberOfBooks];
//    
//    for (NSInteger i = 0; i < pageCount; ++i) {
//        CGRect frame = CGRectMake(0, 0, self.scrollView2.bounds.size.height * 1.33, self.scrollView2.bounds.size.height);
//        self.scrollView2.contentSize = CGSizeMake(frame.size.width * pageCount, frame.size.height);
//        frame.origin.x = frame.size.width * i;
//        frame.origin.y = 0.0f;
//        frame = CGRectInset(frame, 10.0f, 0.0f);
//        
//        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:i]];
//        //        UIView *newPageView = [[UIView alloc] initWithFrame:frame];
//        //        [newPageView addSubview:[[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:i]]];
//        newPageView.tag = i;
//        newPageView.contentMode = UIViewContentModeScaleAspectFit;
//        newPageView.frame = frame;
//        newPageView.userInteractionEnabled = YES;
//        [newPageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
//        
//        [self.scrollView2 addSubview:newPageView];
//    }    
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setScrollViewContainer:nil];
    [self setPageImages:nil];
    [self setPageViews:nil];
    [super viewDidUnload];
}

- (void)userTappedImage:(UITapGestureRecognizer *)sender 
{
    UIView *page = sender.view;
    NSLog(@"Page: %d", page.tag);
    
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"SlikovnicaStoryboard" bundle:nil];
    UIViewController *initialSettingsVC = [settingsStoryboard instantiateInitialViewController];
    initialSettingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialSettingsVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    [self loadVisiblePages];
}
@end
