//
//  MyBooksViewController.m
//  Masha's Books
//
//  Created by Ranko Munk on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBooksViewController.h"
#import "Book.h"
#import "Image.h"
#import "BookExtractor.h"
#import "SlikovnicaRootViewController.h"
#import <MessageUI/MessageUI.h>

@interface MyBooksViewController ()<UIScrollViewDelegate, SlikovnicaRootViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *leftBookImage;

@property (nonatomic, strong) NSArray *myBooks;
@property (nonatomic, strong) NSMutableArray *coverViews;
@property (nonatomic, strong) UIActivityIndicatorView *bookLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MyBooksViewController
@synthesize library = _library;
@synthesize mashaImage = _mashaImage;
@synthesize backgroundImage = _backgroundImage;

@synthesize scrollView = _scrollView;
@synthesize scrollViewContainer = _scrollViewContainer;
@synthesize leftBookImage = _leftBookImage;

@synthesize myBooks = _myBooks;
@synthesize coverViews = _coverViews;
@synthesize bookLoadingIndicator = _bookLoadingIndicator;
@synthesize loadingIndicator = _loadingIndicator;

@synthesize context = _context;

#pragma mark - Load Pages

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
    for (NSInteger i=lastPage+1; i<[self.myBooks count]; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= [self.myBooks count]) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *coverView = [self.coverViews objectAtIndex:page];
    if ((NSNull*)coverView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        UIImageView *newCoverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_arrow.png"]];
        newCoverView.contentMode = UIViewContentModeTopLeft;
        newCoverView.frame = frame;
        newCoverView.tag = page;
        newCoverView.userInteractionEnabled = YES;
        [newCoverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
 
        Book *book = [self.myBooks objectAtIndex:page];
        UIImage *coverImage = [[UIImage alloc] initWithData:book.coverImage.image];
        UIImageView *bookCover = [[UIImageView alloc] initWithImage:coverImage];
        bookCover.contentMode = UIViewContentModeScaleToFill;
        frame = CGRectMake(newCoverView.bounds.origin.x, newCoverView.bounds.origin.y, newCoverView.image.size.width - 35, newCoverView.bounds.size.height);
        frame = CGRectInset(frame, 50.0f, 32.0f);
        bookCover.frame = frame;
        [newCoverView insertSubview:bookCover atIndex:0];

        [self.scrollView addSubview:newCoverView];
        [self.coverViews replaceObjectAtIndex:page withObject:newCoverView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= [self.myBooks count]) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *coverView = [self.coverViews objectAtIndex:page];
    if ((NSNull*)coverView != [NSNull null]) {
        [coverView removeFromSuperview];
        [self.coverViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}


#pragma mark - Setup Database

- (void)getMyBooks
{
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
//    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    
//    NSError *error;
//    self.myBooks = [self.library.managedObjectContext executeFetchRequest:request error:&error];
    
    self.myBooks = [Book MR_findAllSortedBy:@"downloadDate" ascending:NO withPredicate:predicate];

    // Set up the array to hold the views for each page
    NSInteger pageCount = [self.myBooks count];
    self.coverViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.coverViews addObject:[NSNull null]];
    } 
    // Clear scrollview
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * [self.myBooks count], pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
}

- (void)loadDesignImages
{
    Design *design = [Design MR_findFirst];
    
    if (design)
    {
        self.backgroundImage.image = [[UIImage alloc] initWithData:design.bgImage];
        self.mashaImage.image = [[UIImage alloc] initWithData:design.bgMasha];
    }
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.library.fileURL path]]) {
        // does not exist on disk, so create it
        [self.library saveToURL:self.library.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        // go to shop
            [self useDocument];
            
        }];
    } else if (self.library.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.library openWithCompletionHandler:^(BOOL success) {
            //[self getMyBooks];
            [self useDocument];
        }];
    } else if (self.library.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self loadDesignImages];
        [self getMyBooks];
    }
}

- (void)setLibrary:(UIManagedDocument *)library
{
    if (_library != library) {
        _library = library;
        [self useDocument];
    }
}

- (void)newBookReady:(NSNotification *)notification {
    NSLog(@"Calling getMyBooks");
    [self getMyBooks];
}

- (void)bookDeleted:(NSNotification *)notification {
    NSLog(@"Calling getMyBooks");
    [self getMyBooks];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Library"];
    self.library = [[UIManagedDocument alloc] initWithFileURL:url];
    //    [self getMyBooks];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBookReady:) name:@"BookReady" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookDeleted:) name:@"BookDeleted" object:nil ];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.scrollView.contentOffset.x == 0) {
        self.leftBookImage.frame = CGRectMake(-self.leftBookImage.frame.size.width, self.leftBookImage.frame.origin.y, self.leftBookImage.frame.size.width, self.leftBookImage.frame.size.height);
    }
    
    [self loadDesignImages];
    [self getMyBooks];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setScrollView:nil];
    [self setScrollViewContainer:nil];
    [self setMyBooks:nil];
    [self setCoverViews:nil];
    [self setLeftBookImage:nil];
    [self setMashaImage:nil];
    [self setBackgroundImage:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Read Book

- (void)userTappedImage:(UITapGestureRecognizer *)sender 
{
    UIView *page = sender.view;
    
//    self.bookLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    self.bookLoadingIndicator.contentMode = UIViewContentModeCenter;
//    self.bookLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    self.bookLoadingIndicator.frame = ((UIView *)[page.subviews lastObject]).frame;
//    [page addSubview:self.bookLoadingIndicator];
//    [self.bookLoadingIndicator startAnimating];

    [self.loadingIndicator startAnimating];
    
    Book *selectedBook = [self.myBooks objectAtIndex:page.tag];
    NSLog(@"User selected book %@.", selectedBook.title);
    
    if (selectedBook.pages.count <= 0) {
        NSLog(@"No pages in book!");
        return;
    }
    
    UIStoryboard *slikovnicaStoryboard = [UIStoryboard storyboardWithName:@"PicturebookStoryboard" bundle:nil];
    SlikovnicaRootViewController *initialVC = [slikovnicaStoryboard instantiateInitialViewController];
    initialVC.delegate = self;
    initialVC.modelController.book = selectedBook;
    initialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialVC animated:YES];
}

- (void)slikovnicaRootViewController:(SlikovnicaRootViewController *)sender closedPictureBook:(Book *)book
{
    [self.loadingIndicator stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    [self loadVisiblePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             self.leftBookImage.frame = CGRectMake(0, self.leftBookImage.frame.origin.y, self.leftBookImage.frame.size.width, self.leftBookImage.frame.size.height);
                             
                         }
                         completion:nil];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.leftBookImage.frame = CGRectMake(-self.leftBookImage.frame.size.width, self.leftBookImage.frame.origin.y, self.leftBookImage.frame.size.width, self.leftBookImage.frame.size.height);
                             
                         }
                         completion:nil];
    }    
}

#pragma mark - Top Buttons

- (IBAction)topButtonPressed:(UIButton *)sender {
    NSString *url;
    NSString *message;
    Info *info = [Info MR_findFirst];
    switch (sender.tag) {
        case 1:
            url = info.websiteURL;
            message = @"Go and visit Masha's Bookstore website.";
            break;
        case 2:
            url = info.contactURL;
            message = @"Go and contact Masha's Bookstore.";
            break;
        case 3:
            url = info.facebookURL;
            message = @"Go and like Masha's Bookstore on Facebook.";
            break;
        case 4:
            url = info.twitterURL;
            message = @"Go and follow Masha's Bookstore on Tweeter.";
            break;
        default:
            break;
    }
    if (url){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leave Masha's Bookstore?" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.accessibilityHint = url;
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.title == @"Leave Masha's Bookstore?") {
        if (buttonIndex == 1) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.accessibilityHint]];
    }
}

@end
