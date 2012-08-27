//
//  ShopViewController.m
//  Masha's Books
//
//  Created by Luka Miljak on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController ()
@property (nonatomic, strong) PicturebookShop *picturebookShop;
@property (nonatomic, strong) BookExtractor *bookExtractor;
@property (nonatomic, strong) NSMutableArray *allPicturebookCovers;

@end

@implementation ShopViewController
@synthesize categoryButton = _categoryButton ;
@synthesize booksTableView = _booksTableView;
@synthesize thumbImageView = _thumbImageView;
@synthesize bookWebView = _bookWebView;
@synthesize priceLabel = _priceLabel;
@synthesize buyButton = _buyButton;
@synthesize facebookButton = _facebookButton;
@synthesize twitterButton = _twitterButton;
@synthesize youtubeButton = _youtubeButton;
@synthesize downloadProgressView = _downloadProgressView;
@synthesize bookTitleLabel = _bookTitleLabel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize picturebookShop = _picturebookShop;
@synthesize bookExtractor = _bookExtractor;
@synthesize allPicturebookCovers = _allPicturebookCovers;

- (PicturebookShop *)picturebookShop
{
    if (!_picturebookShop) {
        _picturebookShop = [[PicturebookShop alloc] initShop];
        _bookExtractor = [[BookExtractor alloc] initExtractorWithShop:_picturebookShop andContext:self.picturebookShop.libraryDatabase.managedObjectContext];
    }
    return _picturebookShop;
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

    self.allPicturebookCovers = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyCoversStatus:) name:@"ShopReceivedZipData" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCoversTable:) name:@"BookExtracted" object:nil ];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (IBAction)categorySelection:(UIButton *)sender {
}
- (IBAction)bookBought:(UIButton *)sender {
  
    Book *bookJustBought = [self.picturebookShop getSelectedBook]; 
    NSLog(@"Buying book %@", bookJustBought.title);
    [self.bookExtractor addBookToQue:bookJustBought];
    //[self.booksTableView reloadData];
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
        self.categoryButton.titleLabel.text = [NSString stringWithString:self.picturebookShop.selectedCategory.name];
        [self.booksTableView reloadData];
        
        [self.view setNeedsDisplay];
    }
    
    
}

- (void)picturebookShopLoadingError:(NSNotification *) notification {
    PBDLOG(@"ERROR: Picture book shop reports loading error!");
}

- (void)getMyCoversStatus:(NSNotification *) notification {
    [self.picturebookShop refreshCovers:self.allPicturebookCovers];
    
}

- (void)refreshCoversTable:(NSNotification *) notification {
        
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
    Book *book = [[self.picturebookShop getBooksForSelectedCategory] objectAtIndex:indexPath.row];
    cell.coverImage.image = book.coverThumbnailImage;
    cell.bookTitle.text = book.title;
    cell.shortDescription.text = book.descriptionString;
    
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
 
    [self.allPicturebookCovers removeAllObjects];
    //[self.picturebookShop userSelectsCategoryAtIndex:indexPath.row];
    Book *book = [[self.picturebookShop getBooksForSelectedCategory] objectAtIndex:indexPath.row];
    
    [self.picturebookShop userSelectsBook:book];
    
    self.thumbImageView.image = book.coverThumbnailImageMedium;
    self.bookTitleLabel.text = book.title;
    
    NSString *siteURL = @"http://www.mashasbookstore.com/storeops/story-long-description.aspx?id=";
    NSString *urlAddress = [siteURL stringByAppendingString:[NSString stringWithFormat:@"%d", [book.bookID intValue]]];
    
    
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.bookWebView loadRequest:requestObj];
//    self.priceLabel.text = book.price;
//    [self.bookWebView loadHTMLString:book.descriptionLongHTML baseURL:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToCategoryTable"]) {
        CategoryTableViewController *controller = (CategoryTableViewController *)segue.destinationViewController;
        controller.categories = [Category getAllCategoriesFromContext:self.managedObjectContext];
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

@end
