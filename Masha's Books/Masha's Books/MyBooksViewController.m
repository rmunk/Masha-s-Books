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

@interface MyBooksViewController ()<UIScrollViewDelegate, BookExtractorDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *scrollViewContainer;

@property (nonatomic, strong) NSArray *myBooks;
@property (nonatomic, strong) NSMutableArray *coverViews;

@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MyBooksViewController
@synthesize library = _library;

@synthesize scrollView = _scrollView;
@synthesize scrollViewContainer = _scrollViewContainer;

@synthesize myBooks = _myBooks;
@synthesize coverViews = _coverViews;

@synthesize context = _context;

- (IBAction)extractTest:(id)sender 
{
    
    NSString *file = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"izgubljene_papuce.zip"];
//    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/izgubljene_papuce.zip"];
    BookExtractor *bookExtractor = [[BookExtractor alloc] init];
    bookExtractor.delegate = self;
    bookExtractor.book = [self.myBooks objectAtIndex:0];
    [bookExtractor extractBookFromFile:file];
}

- (void)bookExtractor:(BookExtractor *)extractor didFinishExtractinWithgSuccess:(BOOL)success
{
    if (success) {
        [self.library savePresentedItemChangesWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error saving database! (%@)", error.description);
            }
            NSLog(@"Library database saved!");                
        }];
        
    }
}

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
        frame = CGRectInset(frame, 50.0f, 0.0f);
        
        Book *book = [self.myBooks objectAtIndex:page];
        UIImageView *newCoverView = [[UIImageView alloc] initWithImage:book.coverImage.image];
        newCoverView.contentMode = UIViewContentModeScaleAspectFit;
        newCoverView.frame = frame;
        newCoverView.tag = page;
        newCoverView.userInteractionEnabled = YES;
        [newCoverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedImage:)]];
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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error;
    self.myBooks = [self.library.managedObjectContext executeFetchRequest:request error:&error];
    
    // Set up the array to hold the views for each page
    NSInteger pageCount = [self.myBooks count];
    self.coverViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.coverViews addObject:[NSNull null]];
    }    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * [self.myBooks count], pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.library.fileURL path]]) {
        // does not exist on disk, so create it
        [self.library saveToURL:self.library.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        // go to shop
            
        }];
    } else if (self.library.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.library openWithCompletionHandler:^(BOOL success) {
            [self getMyBooks];
        }];
    } else if (self.library.documentState == UIDocumentStateNormal) {
        // already open and ready to use
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

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"My Books";

    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Library"];
    self.library = [[UIManagedDocument alloc] initWithFileURL:url];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setScrollViewContainer:nil];
    [self setMyBooks:nil];
    [self setCoverViews:nil];
    [super viewDidUnload];
}

#pragma mark -
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    [self loadVisiblePages];
}
@end
