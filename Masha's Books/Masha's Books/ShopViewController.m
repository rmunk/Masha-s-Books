//
//  ShopViewController.m
//  Masha's Books
//
//  Created by Luka Miljak on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) PicturebookShop *picturebookShop;
@property (nonatomic, strong) NSOrderedSet *booksInSelectedCategory;
@property (nonatomic, strong) UIView *youTubeTransparentView;
@property (nonatomic, strong) UIWebView *youTubeVideoView;
@property (nonatomic, strong) UIButton *youTubeCloseButton;

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
@synthesize activityView = _activityView;
@synthesize picturebookShop = _picturebookShop;
@synthesize booksInSelectedCategory = _booksInSelectedCategory;
@synthesize youTubeTransparentView = _youTubeTransparentView;
@synthesize youTubeVideoView = _youTubeVideoView;
@synthesize youTubeCloseButton = _youTubeCloseButton;


- (PicturebookShop *)picturebookShop
{
    if (!_picturebookShop) {
        _picturebookShop = [[PicturebookShop alloc] initShop];
    }
    return _picturebookShop;
}

- (void)categoryPicked:(Category *)category inController:(CategoryTableViewController *)controller {
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.picturebookShop userSelectsCategory:category];
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.image = [[UIImage alloc] initWithData:category.bgImage];
                    } completion:NULL];
 
    self.categoryButton.titleLabel.text = category.name;
    self.booksInSelectedCategory = [self.picturebookShop getBooksForSelectedCategory];
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

#pragma mark - View events responders

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.downloadProgressView.hidden = YES;
    if (self.picturebookShop.libraryLoaded == YES) {
        [self.picturebookShop refreshShop];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookExtractingError:) name:@"BookExtractingError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookExtractingError:) name:@"BookExtracted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookReady:) name:@"BookReady" object:self.picturebookShop];
}

- (void)viewWillAppear:(BOOL)animated {
    // progress bar update notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDownloadStatus:) name:@"NewShopReceivedZipData" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewShopReceivedZipData" object:nil];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PicturebookShopFinishedLoading" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PicturebookShopLoadingError" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookExtracted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookExtractingError" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BookReady" object:nil];
}

#pragma mark - Button action

- (IBAction)bookBought:(UIButton *)sender {

    Book *bookJustBought = [self.picturebookShop getSelectedBook]; 
 
    [self.picturebookShop userBuysBook:bookJustBought];
    self. booksInSelectedCategory = [self.picturebookShop getBooksForSelectedCategory];
    [self.booksTableView reloadData];
    
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    int i = 0;
    for (i = 0; i < self.booksInSelectedCategory.count; i++) {
        if (bookJustBought.bookID == ((Book *)[self.booksInSelectedCategory objectAtIndex:i]).bookID) {
            break;
        }
    }
    
    indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    [self bookSelectedAtIndexPath:indexPath];
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
    
    [self.picturebookShop refreshShop];
    
    [self.view setNeedsDisplay];
}

#pragma mark - Database events responders

- (void)picturebookShopFinishedLoading:(NSNotification *) notification {
    PBDLOG(@"Picture book shop reports loading finished!");
        
    [self.picturebookShop userSelectsCategoryAtIndex:0];
    if ([self.picturebookShop getCategoriesInShop].count) {
        NSIndexPath *indexPath = [[NSIndexPath alloc] init];
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.categoryButton.titleLabel.text = [NSString stringWithString:self.picturebookShop.selectedCategory.name];
        
        self.booksInSelectedCategory = [self.picturebookShop getBooksForSelectedCategory];
        
        [self.booksTableView reloadData];
        [self bookSelectedAtIndexPath:indexPath];
        
        [self.view setNeedsDisplay];
    }
    
    
}

- (void)picturebookShopLoadingError:(NSNotification *) notification {
    PBDLOG(@"ERROR: Picture book shop reports loading error!");
}

- (void)bookExtracted:(NSNotification *) notification {
    NSLog(@"ShopViewController: Received BookExtracted notification");
}

- (void)bookExtractingError:(NSNotification *) notification {
    NSLog(@"ShopViewController: Received BookExtracting error notification");
    [self.booksTableView reloadData];
}

- (void)setDownloadStatus:(NSNotification *) notification {
    
    if ([self.downloadProgressView isHidden]) 
        self.downloadProgressView.hidden = NO;
    else 
        self.downloadProgressView.progress = self.picturebookShop.lastPercentage;
    
}

- (void)setPercentage {
    self.downloadProgressView.progress = self.picturebookShop.lastPercentage;
}

- (void)bookReady:(NSNotification *)notification {
    NSLog(@"ShopViewController: Received BookReady notification");
    self.downloadProgressView.hidden = YES;
    [self.downloadProgressView setNeedsDisplay];
    
    [self.booksTableView reloadData];
    
    NSLog(@"ShopViewController: Posting PagesAdded notification");

}

#pragma mark - Database modifiers

- (void)bookSelectedAtIndexPath:(NSIndexPath *)indexPath {

    if (self.booksInSelectedCategory.count > 0) {
        if (![self.downloadProgressView isHidden]) {
            self.downloadProgressView.hidden = YES;
        }
    
        self.picturebookShop.selectedBook = [self.booksInSelectedCategory objectAtIndex:indexPath.row];
        
        NSLog(@"User selects book %@", self.picturebookShop.selectedBook.title);
        [self.picturebookShop userSelectsBook:self.picturebookShop.selectedBook];
    
        self.thumbImageView.image = [[UIImage alloc] initWithData:self.picturebookShop.selectedBook.coverThumbnailImageMedium];
        self.tagViewLarge.image = [[UIImage alloc] initWithData:self.picturebookShop.selectedBook.tagImageLarge];
        self.rateImage.image = [[UIImage alloc] initWithData:self.picturebookShop.selectedBook.rateImageUp];
        self.bookTitleLabel.text = self.picturebookShop.selectedBook.title;
        self.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [self.picturebookShop.selectedBook.price floatValue]];
       [self.booksTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        self.youtubeButton.titleLabel.text = self.picturebookShop.selectedBook.youTubeVideoURL;
    
        NSString *siteURL = @"http://www.mashasbookstore.com/storeops/story-long-description.aspx?id=";
        NSString *urlAddress = [siteURL stringByAppendingString:[NSString stringWithFormat:@"%d", [self.picturebookShop.selectedBook.bookID intValue]]];
    
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.picturebookShop.isShopLoaded) {
        PBDLOG_ARG(@"Category table number of rows: %i", [self.picturebookShop getCategoriesInShop].count);
        return [self.picturebookShop getBooksForSelectedCategory].count;        
    }
    else {
        PBDLOG(@"Category table number of rows: Shop not red yet");
        return 0;
    }
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
        cell.statusLabel.text = @"Waiting...";
    }
    else if ([book.status isEqualToString:@"downloading"]) {
        cell.transparencyView.hidden = NO;
        cell.activityView.hidden = NO;
        if (![cell.activityView isAnimating]) {
            [cell.activityView startAnimating];
        }
        
        cell.statusLabel.text = @"Downloading...";
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
        categoryVC.categories = [Category getAllCategories];
   
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
    CGFloat cbD = 15;
    
    CGRect youTubeFrame = CGRectMake(width * (1 - scale) / 2, height * (1 - scale) / 2, width * scale, height * scale);
    CGRect closeButtonFrame = CGRectMake(cbX - cbD, cbY - cbD, 2 * cbD, 2 * cbD);
    NSString *html = [NSString stringWithFormat:embedHTML, urlString, youTubeFrame.size.width, youTubeFrame.size.height];
    UIImage *closeButtonImage = [UIImage imageNamed:@"close.png"];
    
    self.youTubeTransparentView = [[UIView alloc] initWithFrame:self.view.frame];
    self.youTubeTransparentView.backgroundColor = [UIColor blackColor];
    self.youTubeTransparentView.alpha = 0.8;     
    [self.view addSubview:self.youTubeTransparentView];
    
    self.youTubeVideoView = [[UIWebView alloc] initWithFrame:youTubeFrame];
    [self.youTubeVideoView loadHTMLString:html baseURL:nil];
    [self.view addSubview:self.youTubeVideoView];
    
    self.youTubeCloseButton = [[UIButton alloc] initWithFrame:closeButtonFrame];
    [self.youTubeCloseButton setImage:closeButtonImage forState:UIControlStateNormal];
    self.youTubeCloseButton.backgroundColor = [UIColor clearColor];
    [self.youTubeCloseButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.youTubeCloseButton];
    
}

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
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


- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    UIButton *button = [self findButtonInView:_webView];
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
