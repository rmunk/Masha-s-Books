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
//@property (nonatomic, strong) NSMutableArray *allPicturebookCovers;
@property (nonatomic, strong) NSOrderedSet *booksInSelectedCategory;

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
//@synthesize managedObjectContext = _managedObjectContext;
@synthesize picturebookShop = _picturebookShop;
//@synthesize allPicturebookCovers = _allPicturebookCovers;
@synthesize booksInSelectedCategory = _booksInSelectedCategory;

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
                        self.backgroundView.image = category.bgImage;
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

- (void)viewDidLoad
{
	[super viewDidLoad];

    //self.allPicturebookCovers = [[NSMutableArray alloc] init];
    //self.booksInSelectedCategory = [self.picturebookShop getBooksForSelectedCategory];
    self.downloadProgressView.hidden = YES;
    if (self.picturebookShop.libraryLoaded == YES) {
        [self.picturebookShop refreshShop];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDownloadStatus:) name:@"NewShopReceivedZipData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookExtracted:) name:@"BookExtracted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookExtractingError:) name:@"BookExtractingError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookReady:) name:@"BookReady" object:self.picturebookShop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSError *error = nil;
   // NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (self.picturebookShop.libraryDatabase.managedObjectContext != nil) {
        if ([self.picturebookShop.libraryDatabase.managedObjectContext hasChanges] && ![self.picturebookShop.libraryDatabase.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
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
}
- (IBAction)categorySelection:(UIButton *)sender {
}
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
}
- (IBAction)shopRefresh:(UIBarButtonItem *)sender {
    PBDLOG(@"PicturebookShopViewController: Calling refreshShop."); 
    
    [self.picturebookShop refreshShop];
    
    [self.view setNeedsDisplay];
}

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
    //[self.picturebookShop refreshCovers:self.allPicturebookCovers];
    
    if ([self.downloadProgressView isHidden]) {
        self.downloadProgressView.hidden = NO;
    }
    else {
    //    self per
        self.downloadProgressView.progress = self.picturebookShop.lastPercentage;
    }
}

- (void)setPercentage {
    self.downloadProgressView.progress = self.picturebookShop.lastPercentage;
}

- (void)bookReady:(NSNotification *)notification {
    NSLog(@"ShopViewController: Received BookReady notification");
    self.downloadProgressView.hidden = YES;
    [self.downloadProgressView setNeedsDisplay];
    
   // NSIndexPath *selectedIndexPath = [self.booksTableView indexPathForSelectedRow];
    //[self bookSelectedAtIndexPath:selectedIndexPath];
    [self.booksTableView reloadData];
    
    
    NSLog(@"ShopViewController: Posting PagesAdded notification");
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"PagesAdded" object:nil];
}

- (void)bookSelectedAtIndexPath:(NSIndexPath *)indexPath {
   //NSOrderedSet *books = self.booksInSelectedCategory;//[self.picturebookShop getBooksForSelectedCategory];
    if (self.booksInSelectedCategory.count > 0) {
        NSLog(@"bookSelected: Number of books in category %@ is %d", self.picturebookShop.selectedCategory.name, self.booksInSelectedCategory.count);
        if (![self.downloadProgressView isHidden]) {
            self.downloadProgressView.hidden = YES;
        }
        
    
        self.picturebookShop.selectedBook = [self.booksInSelectedCategory objectAtIndex:indexPath.row];
        
        NSLog(@"User selects book %@", self.picturebookShop.selectedBook.title);
        [self.picturebookShop userSelectsBook:self.picturebookShop.selectedBook];
    
        self.thumbImageView.image = self.picturebookShop.selectedBook.coverThumbnailImageMedium;
        self.tagViewLarge.image = self.picturebookShop.selectedBook.tagImageLarge;
        self.rateImage.image = self.picturebookShop.selectedBook.rateImageUp;
        self.bookTitleLabel.text = self.picturebookShop.selectedBook.title;
        self.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [self.picturebookShop.selectedBook.price floatValue]];
        [self.booksTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
        NSString *siteURL = @"http://www.mashasbookstore.com/storeops/story-long-description.aspx?id=";
        NSString *urlAddress = [siteURL stringByAppendingString:[NSString stringWithFormat:@"%d", [self.picturebookShop.selectedBook.bookID intValue]]];
    
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
    
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
        //Load the request in the UIWebView.
        [self.bookWebView loadRequest:requestObj];
        //    self.priceLabel.text = book.price;
        //    [self.bookWebView loadHTMLString:book.descriptionLongHTML baseURL:nil];
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
    //Book *book = [[self.picturebookShop getBooksForSelectedCategory] objectAtIndex:indexPath.row];
    Book *book = [self.booksInSelectedCategory objectAtIndex:indexPath.row];
    cell.coverImage.image = book.coverThumbnailImage;
    cell.bookTitle.text = book.title;
    cell.shortDescription.text = book.descriptionString;
    cell.rateImage.image = book.rateImageUp;
    cell.tagImage.image = book.tagImageSmall;
    
    if ([book.status isEqualToString:@"qued"]) {
        cell.transparencyView.hidden = NO;
        if (![cell.activityView isAnimating]) {
            [cell.activityView startAnimating];
        }
        cell.statusLabel.text = @"Waiting...";
    }
    else if ([book.status isEqualToString:@"downloading"]) {
        cell.transparencyView.hidden = NO;
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

    
    //        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
    //        self.backgroundView.contentMode = UIViewContentModeTopLeft;
    //        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_sel"]];
    //        self.selectedBackgroundView.contentMode = UIViewContentModeTopLeft;
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
//    cell.backgroundView.contentMode = UIViewContentModeTopLeft;
//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_sel.png"]];
//    cell.selectedBackgroundView.contentMode = UIViewContentModeTopLeft;
//    
    
//    CGRect bookCellFrame = CGRectMake(0, 0, tableView.bounds.size.width, BOOKCELL_HEIGHT);
//    
//    Book *book = [[self.picturebookShop getBooksForSelectedCategory] objectAtIndex:indexPath.row];
//    if (cell == nil) 
//        cell = [[BooksTableCell alloc] initWithFrame:bookCellFrame forBook:book];
//  
    return cell;
    
       
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSLog(@"User selects book at index %d", indexPath.row);
 
 //   [self.allPicturebookCovers removeAllObjects];
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
        categoryVC.categories = [Category getAllCategoriesFromContext:self.picturebookShop.libraryDatabase.managedObjectContext];
   
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


@end
