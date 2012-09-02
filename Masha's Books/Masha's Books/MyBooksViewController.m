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

@interface MyBooksViewController ()<UIScrollViewDelegate, SlikovnicaRootViewControllerDelegate, MFMailComposeViewControllerDelegate>
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
        UIImageView *bookCover = [[UIImageView alloc] initWithImage:book.coverImage.image];
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
    // Clear scrollview
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
    [self getMyBooks];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setScrollViewContainer:nil];
    [self setMyBooks:nil];
    [self setCoverViews:nil];
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
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    [self loadVisiblePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark - Top Buttons
- (IBAction)goToWebSite:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.mashasbookstore.com"]];
}

- (IBAction)sendMail:(UIButton *)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;

        NSArray *toRecipients = [NSArray arrayWithObjects:@"masha@mashasbookstore.com", @"ranko.munk@gmail.com", nil];
        [mailer setToRecipients:toRecipients];
        
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot send eMail!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)goToFacebook:(UIButton *)sender {
}

- (IBAction)tweet:(UIButton *)sender {
}

@end
