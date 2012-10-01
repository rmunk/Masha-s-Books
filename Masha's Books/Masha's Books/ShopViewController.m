//
//  ShopViewController.m
//  Masha's Books
//
//  Created by Luka Miljak on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSOrderedSet *booksInSelectedCategory;
@property (nonatomic, strong) UIView *youTubeTransparentView;
@property (nonatomic, strong) UIWebView *youTubeVideoView;
@property (nonatomic, strong) UIButton *youTubeCloseButton;
@property (nonatomic, strong) MBDatabase *database;
@property (nonatomic, strong) Category *selectedCategory;
@property (nonatomic, strong) NSOrderedSet *categoriesInDatabase;
@property (nonatomic, strong) Book *selectedBook;
@end

@implementation ShopViewController
@synthesize categoryButton = _categoryButton ;
@synthesize booksTableView = _booksTableView;
@synthesize thumbImageView = _thumbImageView;
@synthesize bookWebView = _bookWebView;
@synthesize backgroundView = _backgroundView;
@synthesize priceLabel = _priceLabel;
@synthesize buyButton = _buyButton;
@synthesize facebookButton = _facebookButton;
@synthesize twitterButton = _twitterButton;
@synthesize youtubeButton = _youtubeButton;
@synthesize downloadProgressView = _downloadProgressView;
@synthesize bookTitleLabel = _bookTitleLabel;
@synthesize tagViewLarge = _tagViewLarge;
@synthesize rateImage = _rateImage;
@synthesize activityLabel = _activityLabel;
@synthesize activityView = _activityView;
@synthesize booksInSelectedCategory = _booksInSelectedCategory;
@synthesize youTubeTransparentView = _youTubeTransparentView;
@synthesize youTubeVideoView = _youTubeVideoView;
@synthesize youTubeCloseButton = _youTubeCloseButton;

@synthesize database = _database;
@synthesize selectedCategory = _selectedCategory;
@synthesize categoriesInDatabase = _categoriesInDatabase;
@synthesize selectedBook = _selectedBook;


#pragma mark - Initialization methods

- (void)categoryPicked:(Category *)category inController:(CategoryTableViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self categoryPicked:category];
}

- (void)categoryPicked:(Category *)category {
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.selectedCategory = category;
    
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.image = [[UIImage alloc] initWithData:category.bgImage];
                    } completion:NULL];
    
    [self.categoryButton setTitle:category.name forState:UIControlStateNormal];
    self.booksInSelectedCategory = [self.database getBooksForCategory:category];
    [self.booksTableView reloadData];
    [self bookSelectedAtIndexPath:indexPath];
    [self.view setNeedsDisplay];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setMBD:(MBDatabase *)database {
    self.database = database;
}

#pragma mark - View events responders

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.downloadProgressView.hidden = YES;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    self.downloadProgressView.transform = transform;
    self.categoryButton.titleLabel.hidden = NO;

    self.categoriesInDatabase = [self.database getCategoriesInDatabase];

    if (self.categoriesInDatabase.count) {
        [self categoryPicked:[self.categoriesInDatabase objectAtIndex:0]];
        self.booksInSelectedCategory = [self.database getBooksForCategory:self.selectedCategory];
        for (Book *book in self.booksInSelectedCategory) {
            NSLog(@"Book in category %@", book.title);
    }
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.categoryButton.titleLabel.text = [NSString stringWithString:self.selectedCategory.name];
    
    [self.booksTableView reloadData];
    [self bookSelectedAtIndexPath:indexPath];
    
    [self.view setNeedsDisplay];
}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookExtractingError:) name:@"BookExtractingError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookExtracted:) name:@"BookExtracted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookDownloaded:) name:@"BookDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookReady:) name:@"BookReady" object:self.database];
}

- (void)viewWillAppear:(BOOL)animated {
    // progress bar update notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDownloadStatus:) name:@"BookDataReceived" object:nil];
    NSIndexPath *selectedBookIndexPath = self.booksTableView.indexPathForSelectedRow;
    Book *book = ((Book *)[self.booksInSelectedCategory objectAtIndex:selectedBookIndexPath.row]);
    [self refreshBuyButtonWithBookState:book];
    [self.booksTableView reloadData];
    [self.booksTableView selectRowAtIndexPath:selectedBookIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if ([self.selectedBook.status isEqualToString:@"downloading"] && [self.downloadProgressView isHidden]) {
        [self.downloadProgressView setHidden:NO];
    }
    
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookDataReceived" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setCategoryButton:nil];
    [self setThumbImageView:nil];
    [self setBookWebView:nil];
    [self setPriceLabel:nil];
    [self setBuyButton:nil];
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
    [self setYoutubeButton:nil];
    [self setDownloadProgressView:nil];
    [self setBooksTableView:nil];
    [self setBookTitleLabel:nil];
    [self setBackgroundView:nil];
    [self setTagViewLarge:nil];
    [self setRateImage:nil];
    [self setActivityView:nil];
    [self setActivityLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PicturebookShopFinishedLoading" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PicturebookShopLoadingError" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookExtracted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookExtractingError" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookReady" object:nil];
}

#pragma mark - Button action

- (IBAction)bookBought:(UIButton *)sender {

    Book *bookJustBought = self.selectedBook;
    NSIndexPath *selectedBookIndexPath = self.booksTableView.indexPathForSelectedRow;
 
    [self.database userBuysBook:bookJustBought];
    self.booksInSelectedCategory = [self.database getBooksForCategory:self.selectedCategory];
    
    [self refreshBuyButtonWithBookState:bookJustBought];
    
    [self.booksTableView reloadData];
    [self.booksTableView selectRowAtIndexPath:selectedBookIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
  //  NSIndexPath *indexPath = [[NSIndexPath alloc] init];
  //  int i = 0;
   // for (i = 0; i < self.booksInSelectedCategory.count; i++) {
   //     if (bookJustBought.bookID == ((Book *)[self.booksInSelectedCategory objectAtIndex:i]).bookID) {
   //         break;
   //     }
   // }
    
   // indexPath = [NSIndexPath indexPathForRow:i inSection:0];
   // [self bookSelectedAtIndexPath:indexPath];
}

- (IBAction)goToFacebookPage:(UIButton *)sender {
}

- (IBAction)goToTwitterPage:(UIButton *)sender {
}

- (IBAction)goToYoutubePage:(UIButton *)sender {
    NSString *youTubeURL = [NSString stringWithFormat:@"%@%@", @"http://www.youtube.com/watch?feature=player_embedded&v=", sender.titleLabel.text];
    NSLog(@"Youtube url: %@", youTubeURL);
    [self embedYouTube:youTubeURL frame:CGRectMake(40, 40, 200, 150)];
}

- (IBAction)shopRefresh:(UIBarButtonItem *)sender {
    PBDLOG(@"PicturebookShopViewController: Calling refreshShop."); 
    
    [self.view setNeedsDisplay];
}

#pragma mark - Database events responders

- (void)picturebookShopLoadingError:(NSNotification *) notification {
    PBDLOG(@"ERROR: Picture book shop reports loading error!");
}

- (void)bookExtracted:(NSNotification *) notification {
    NSLog(@"ShopViewController: Received BookExtracted notification");
    NSLog(@"Selected book status: %@", self.selectedBook.status);
    NSIndexPath *selectedBookIndexPath = self.booksTableView.indexPathForSelectedRow;
    
    
    Book *book = ((Book *)[self.booksInSelectedCategory objectAtIndex:selectedBookIndexPath.row]);
    [self refreshBuyButtonWithBookState:book];
    [self.booksTableView reloadData];
    [self.booksTableView selectRowAtIndexPath:selectedBookIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)bookExtractingError:(NSNotification *) notification {
    NSLog(@"ShopViewController: Received BookExtracting error notification");
    NSIndexPath *selectedBookIndexPath = self.booksTableView.indexPathForSelectedRow;
    Book *book = ((Book *)[self.booksInSelectedCategory objectAtIndex:selectedBookIndexPath.row]);
    [self refreshBuyButtonWithBookState:book];
    [self.booksTableView reloadData];
    [self.booksTableView selectRowAtIndexPath:selectedBookIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)bookDownloaded:(NSNotification *) notification {
    NSLog(@"ShopViewController: Received BookDownloaded notification");
    NSLog(@"Selected book status: %@", self.selectedBook.status);
    NSIndexPath *selectedBookIndexPath = self.booksTableView.indexPathForSelectedRow;
    
    
    Book *book = ((Book *)[self.booksInSelectedCategory objectAtIndex:selectedBookIndexPath.row]);
    [self refreshBuyButtonWithBookState:book];
    [self.booksTableView reloadData];
    [self.booksTableView selectRowAtIndexPath:selectedBookIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)bookReady:(NSNotification *)notification {
    NSLog(@"ShopViewController: Received BookReady notification");
    NSLog(@"Selected book status: %@", self.selectedBook.status);

    self.downloadProgressView.hidden = YES;
    self.activityLabel.hidden = YES;
    [self.downloadProgressView setNeedsDisplay];
    
    NSIndexPath *selectedBookIndexPath = self.booksTableView.indexPathForSelectedRow;
    
    
    Book *book = ((Book *)[self.booksInSelectedCategory objectAtIndex:selectedBookIndexPath.row]);
    [self refreshBuyButtonWithBookState:book];
    
    [self.booksTableView reloadData];
    [self.booksTableView selectRowAtIndexPath:selectedBookIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    NSLog(@"ShopViewController: Posting PagesAdded notification");
}

- (void)setDownloadStatus:(NSNotification *)notification {
    if ([self.selectedBook.status isEqualToString:@"downloading"]) {
        if(self.downloadProgressView.hidden == YES)
            self.downloadProgressView.hidden = NO;

        self.downloadProgressView.progress = [notification.object floatValue];

    }
    else {
        if(self.downloadProgressView.hidden == NO)
            self.downloadProgressView.hidden = YES;
    }
}

#pragma mark - Database modifiers

- (void)bookSelectedAtIndexPath:(NSIndexPath *)indexPath {
    Book *book = ((Book *)[self.booksInSelectedCategory objectAtIndex:indexPath.row]);

    if (book) {
        
        self.selectedBook = book;
        
        if (![self.downloadProgressView isHidden]) {
            self.downloadProgressView.hidden = YES;
        }
        
        NSLog(@"User selects book %@. Book status: %@", book.title, book.status);
    
        self.thumbImageView.image = [[UIImage alloc] initWithData:book.coverThumbnailImageMedium];
        self.tagViewLarge.image = [[UIImage alloc] initWithData:book.tagImageLarge];
        self.rateImage.image = [[UIImage alloc] initWithData:book.rateImageUp];
        self.bookTitleLabel.text = book.title;
        self.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [book.price floatValue]];
        [self.priceLabel setHidden:YES];
        
        [self refreshBuyButtonWithBookState:book];
        
        [self.booksTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        self.youtubeButton.titleLabel.text = book.youTubeVideoURL;
    
        NSString *siteURL = @"http://www.mashasbookstore.com/storeops/story-long-description.aspx?id=";
        NSString *urlAddress = [siteURL stringByAppendingString:[NSString stringWithFormat:@"%d", [book.bookID intValue]]];
    
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
    
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
        //Load the request in the UIWebView.
        [self.bookWebView loadRequest:requestObj];

    }
    else {
        NSLog(@"No books in category");
    }
}

- (void)refreshBuyButtonWithBookState:(Book *)book {
    if ([book.status isEqualToString:@"ready"]) {
        [self.buyButton setTitle:@"Installed" forState:UIControlStateNormal];
        [self.buyButton setEnabled:NO];
    }
    else if ([book.status isEqualToString:@"bought"]) {
        [self.buyButton setEnabled:YES];
        [self.buyButton setTitle:@"Download" forState:UIControlStateNormal];
    }
    else if ([book.status isEqualToString:@"downloading"]) {
        [self.buyButton setTitle:@"Downloading" forState:UIControlStateNormal];
        [self.buyButton setEnabled:NO];
    }
    else if ([book.status isEqualToString:@"qued"]) {
        [self.buyButton setTitle:@"Waiting" forState:UIControlStateNormal];
        [self.buyButton setEnabled:NO];
    }
    else if ([book.status isEqualToString:@"extracting"]) {
        [self.buyButton setTitle:@"Extracting" forState:UIControlStateNormal];
        [self.buyButton setEnabled:NO];
    }
    else if ([book.status isEqualToString:@"saving"]) {
        [self.buyButton setTitle:@"Saving" forState:UIControlStateNormal];
        [self.buyButton setEnabled:NO];
    }
    else {
        [self.buyButton setEnabled:YES];
        if ([book.price floatValue] == 0.0f) 
            [self.buyButton setTitle:@"Free" forState:UIControlStateNormal];
        else
            [self.buyButton setTitle:[NSString stringWithFormat:@"$ %.2f", [book.price floatValue]] forState:UIControlStateNormal];
    }
}

- (IBAction)categorySelection:(UIButton *)sender {
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    //PBDLOG_ARG(@"Category table number of rows: %i", self.categoriesInDatabase.count);
    return self.booksInSelectedCategory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    static NSString *CellIdentifier = @"BooksTableCell";        
    BooksTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BooksTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    Book *book = [self.booksInSelectedCategory objectAtIndex:indexPath.row];
    cell.coverImage.image = [[UIImage alloc] initWithData:book.coverThumbnailImage];
    cell.bookTitle.text = book.title;
    cell.shortDescription.text = book.descriptionString;
    cell.rateImage.image = [[UIImage alloc] initWithData:book.rateImageUp];
    cell.tagImage.image = [[UIImage alloc] initWithData:book.tagImageSmall];
    
    if ([book.status isEqualToString:@"qued"]) {
        cell.transparencyView.hidden = NO;
        cell.activityView.hidden = NO;
        if (![cell.activityView isAnimating]) {
            [cell.activityView startAnimating];
            [cell.activityView setNeedsDisplay];
        }
        cell.statusLabel.text = @"Waiting";
    }
    else if ([book.status isEqualToString:@"extracting"]) {
        cell.transparencyView.hidden = NO;
        cell.activityView.hidden = NO;
        if (![cell.activityView isAnimating]) {
            [cell.activityView startAnimating];
        }
        
        cell.statusLabel.text = @"Extracting";
    }
    else if ([book.status isEqualToString:@"saving"]) {
        cell.transparencyView.hidden = NO;
        cell.activityView.hidden = NO;
        if (![cell.activityView isAnimating]) {
            [cell.activityView startAnimating];
        }
        
        cell.statusLabel.text = @"Saving";
    }
    else if ([book.status isEqualToString:@"downloading"]) {
        cell.transparencyView.hidden = NO;
        cell.activityView.hidden = NO;
        if (![cell.activityView isAnimating]) {
            [cell.activityView startAnimating];
        }
        
        cell.statusLabel.text = @"Downloading";
    }
    else {
        cell.transparencyView.hidden = YES;
        cell.activityView.hidden = YES;
        if ([cell.activityView isAnimating]) {
            [cell.activityView stopAnimating];
        }
        cell.statusLabel.text = @"";
                
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
 
    [self bookSelectedAtIndexPath:indexPath];
    [self.booksTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToCategoryTable"]) {
        UIStoryboardPopoverSegue *popoverSegue;
        popoverSegue = (UIStoryboardPopoverSegue *)segue;
        
        UIPopoverController *popoverController;
        popoverController = popoverSegue.popoverController;
        
        CategoryTableViewController *categoryVC = (CategoryTableViewController *)popoverSegue.destinationViewController;
        categoryVC.categories = self.categoriesInDatabase;
   
        categoryVC.delegate = self;
        categoryVC.popoverController = popoverController;
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    } else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
    return YES;
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

#pragma mark - YouTube Button
- (void)embedYouTube:(NSString *)urlString frame:(CGRect)frame {
    
    NSString *embedHTML = @"\
                            <html><head>\
                            <style type=\"text/css\">\
                            body {\
                                background-color: transparent;\
                                color: white;\
                            }\
                            </style>\
                            </head><body style=\"margin:0\">\
                            <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
                            width=\"%0.0f\" height=\"%0.0f\"></embed>\
                            </body></html>";
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat scale = 0.5;
    CGFloat cbX = width * (1 + scale) / 2; 
    CGFloat cbY = height * (1 - scale) / 2;
    CGFloat cbD = 17;
    
    CGRect youTubeFrame = CGRectMake(width * (1 - scale) / 2, height * (1 - scale) / 2, width * scale, height * scale);
    CGRect closeButtonFrame = CGRectMake(cbX - cbD, cbY - cbD, 2 * cbD, 2 * cbD);
    NSString *html = [NSString stringWithFormat:embedHTML, urlString, youTubeFrame.size.width, youTubeFrame.size.height];
    UIImage *closeButtonImage = [UIImage imageNamed:@"close.png"];
    
    self.youTubeTransparentView = [[UIView alloc] initWithFrame:self.view.frame];
    self.youTubeTransparentView.backgroundColor = [UIColor blackColor];
    self.youTubeTransparentView.alpha = 0.0;     
    [self.view addSubview:self.youTubeTransparentView];
    
    self.youTubeVideoView = [[UIWebView alloc] init];
    self.youTubeVideoView.delegate = self;
    [self.view addSubview:self.youTubeVideoView];
    
    self.youTubeCloseButton = [[UIButton alloc] init];
    [self.youTubeCloseButton setImage:closeButtonImage forState:UIControlStateNormal];
    self.youTubeCloseButton.backgroundColor = [UIColor clearColor];
    [self.youTubeCloseButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.youTubeCloseButton];
    
    
    self.youTubeVideoView.frame = CGRectMake(width * (1 - scale) / 2, 0.0f, width * scale, height * scale);
    self.youTubeCloseButton.frame = CGRectMake(cbX - cbD, cbY - cbD - height * (1 - scale * 1.5), 2 * cbD, 2 * cbD);
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.youTubeTransparentView.alpha = 0.8;
                         self.youTubeVideoView.frame = youTubeFrame;
                         self.youTubeCloseButton.frame = closeButtonFrame;
                     }];

    [self.youTubeVideoView loadHTMLString:html baseURL:nil];
    
    
    
}

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        NSLog(@"Button found");
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIButton *button = [self findButtonInView:webView];
    NSLog(@"Webview loaded");
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)doneButtonClick:(NSNotification*)notification {
    NSLog(@"Done button clicked");
    [self.youTubeVideoView removeFromSuperview];
    [self.youTubeTransparentView removeFromSuperview];
    [self.youTubeCloseButton removeFromSuperview];
}

- (void)closeButtonClick {

    NSLog(@"Close button clicked");
    [self.youTubeVideoView loadHTMLString:@"" baseURL:nil];
    [self.youTubeVideoView removeFromSuperview];    
    [self.youTubeTransparentView removeFromSuperview];
    [self.youTubeCloseButton removeFromSuperview];
   
    
}

@end
