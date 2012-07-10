//
//  PicturebookShopViewController.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicturebookShopViewController.h"
#define CATEGORY_TABLEVIEW_TAG 1
#define COVERS_TABLEVIEW_TAG 2
#define NUM_OF_COVERS_IN_ROW_PORTRAIT 4


@interface PicturebookShopViewController ()
@property (nonatomic, strong) PicturebookShop *picturebookShop;
@end

@implementation PicturebookShopViewController
@synthesize shopRefreshButton = _shopRefreshButton;
@synthesize shopWebView = _shopWebView;
@synthesize selectedCoverTumbnailView = _selectedCoverTumbnailView;
@synthesize buyButton = _buyButton;

@synthesize picturebookShop = _picturebookShop;
@synthesize managedObjectContext = _managedObjectContext;

- (PicturebookShop *)picturebookShop
{
    if (!_picturebookShop) 
        _picturebookShop = [[PicturebookShop alloc] initShop];
    return _picturebookShop;
}

- (UITableView *)getTableViewForTag:(NSInteger)tag {
    for ( UIView *subview in self.view.subviews ) 
        if ([subview isKindOfClass:[UITableView class]] && subview.tag == tag)         
            return (UITableView *)subview;   

    return nil;
}

- (IBAction)refreshPicturebookShop:(UIBarButtonItem *)sender {
    
    PBDLOG(@"PicturebookShopViewController: Calling refreshShop."); 
    
    self.shopRefreshButton.style = UIBarButtonSystemItemRedo;
    //[self.shopRefreshButton setStyle:UIBarButtonSystemItemCamera];
    [self.picturebookShop refreshShop];
    
    [[self getTableViewForTag:CATEGORY_TABLEVIEW_TAG] reloadData];
    [[self getTableViewForTag:COVERS_TABLEVIEW_TAG] reloadData];
    
    [self.view setNeedsDisplay];
    
    /*
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = activityItem;*/

}

- (IBAction)buyPictureBook:(UIButton *)sender {
    //[self.picturebookShop refreshDatabase];
    Book *bookJustBought = [self.picturebookShop getSelectedBook];
    [bookJustBought downloadBookZipFileforShop:self.picturebookShop];
//    PBDLOG_ARG(@"Picture book %@ bought!", bookJustBought.title);
    bookJustBought.downloaded = [NSNumber numberWithInt:1];
    
}

- (void)picturebookShopFinishedLoading:(NSNotification *) notification {
    PBDLOG(@"Picture book shop reports loading finished!");
    
    
    /* Za testiranje kad bude implementiran description html
    PicturebookInfo *pbInfo = [[self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory] objectAtIndex:0];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    [self.shopWebView loadHTMLString:pbInfo. baseURL:
     */
    [self.picturebookShop userSelectsCategoryAtIndex:0];
    [[self getTableViewForTag:CATEGORY_TABLEVIEW_TAG] reloadData];
    [[self getTableViewForTag:CATEGORY_TABLEVIEW_TAG] selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [[self getTableViewForTag:COVERS_TABLEVIEW_TAG] reloadData];

    [self.view setNeedsDisplay];
    
}

- (void)picturebookShopLoadingError:(NSNotification *) notification {
    PBDLOG(@"ERROR: Picture book shop reports loading error!");
}

- (IBAction)shopItemTapped:(PicturebookCover *)sender{
    PBDLOG_ARG(@"Shop item tapped: %@", sender.bookForCover.title);
    
   // [sender.pbInfo pickYourCategories:self.picturebookShop.categories];
    
    [self.picturebookShop userSelectsBook:sender.bookForCover];
    
    [self.shopWebView loadHTMLString:sender.bookForCover.descriptionHTML baseURL:nil];

    self.selectedCoverTumbnailView.image = sender.bookForCover.coverThumbnailImage;
    [self.selectedCoverTumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    //[self.shopWebView reload];
    self.buyButton.hidden = FALSE;
    sender.taskProgress.alpha = 1;
    sender.taskProgress.progress = 0.3;
    sender.bookStatus.alpha = 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Registering to PicturebookShop notifications (laoding succesful and loading error)
    //self.selectedPicturebookCategory = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    self.buyButton.hidden = TRUE;
    
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
    [self setShopRefreshButton:nil];
    [self setShopWebView:nil];
    [self setSelectedCoverTumbnailView:nil];
    [self setBuyButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
        if (tableView.tag == CATEGORY_TABLEVIEW_TAG) {
            PBDLOG_ARG(@"Category table number of rows: %i", [self.picturebookShop getCategoriesInShop].count);
            return [self.picturebookShop getCategoriesInShop].count;
        }
        else if (tableView.tag == COVERS_TABLEVIEW_TAG) {
            //NSOrderedSet *bookInCategory = [self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory];
            

            NSOrderedSet *booksInCat = [self.picturebookShop getBooksForSelectedCategory];
            
                
            // Broj redova u tablici s coverima za neku kategoriju je (broj covera / broj covera u jednom redu) 
            int numOfRows = booksInCat.count / NUM_OF_COVERS_IN_ROW_PORTRAIT;
            // Da li treba dodat jos jedan red ako (broj covera / broj covera u jednom redu) nije cijeli broj?
            if (booksInCat.count % NUM_OF_COVERS_IN_ROW_PORTRAIT)
                numOfRows++;
            PBDLOG_ARG(@"Picture books table number of rows: %i", numOfRows);
            //return self.picturebookShop.books.count;
            return numOfRows;
        }
        else {
            return 0;
        }
    }
    else {
        PBDLOG(@"Category table number of rows: Shop not red yet");
        return 0;
    }
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == CATEGORY_TABLEVIEW_TAG) {
        
        static NSString *CellIdentifier = @"CategoryTableCell";        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
            cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero];
        Category *category = [[self.picturebookShop getCategoriesInShop] objectAtIndex:indexPath.row];
        cell.textLabel.text = category.name;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        //[cell.textLabel setTextColor:[UIColor lightTextColor]];
        //[cell.textLabel setFont:[UIFont systemFontOfSize:22.0]];
        //cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else if (tableView.tag == COVERS_TABLEVIEW_TAG) {
        
        static NSString *CellIdentifier = @"CoverTableCell";        
        CoverTableRowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
                        
            NSOrderedSet *booksInCat = [self.picturebookShop getBooksForSelectedCategory];
            
            NSLog(@"Books in selected category:");
            for (Book *book in booksInCat) {
                NSLog(@"Book title = %@", book.title);
            }
            
            NSMutableOrderedSet *booksInRow = [[NSMutableOrderedSet alloc] init];
           
            for (int i = indexPath.row * NUM_OF_COVERS_IN_ROW_PORTRAIT; (i < (indexPath.row * NUM_OF_COVERS_IN_ROW_PORTRAIT + NUM_OF_COVERS_IN_ROW_PORTRAIT)) && i < booksInCat.count; i++) {
                [booksInRow addObject:[booksInCat objectAtIndex:i]];
            }
            
            cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero 
                                    withNumberOfCoversInRow:NUM_OF_COVERS_IN_ROW_PORTRAIT
                                                withWidthOf:tableView.bounds.size.width 
                               desiredDistanceBetweenCovers:20 
                                                   forBooks:booksInRow 
                                                 withTarget:self 
                                                 withAction:@selector(shopItemTapped:)];
            
            if (tableView.rowHeight != cell.cellHeight) {
                tableView.rowHeight = cell.cellHeight;
                [tableView reloadData];
            }
        }
        return cell;
    }	
    else {
        return NULL;
    }
    
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (tableView.tag == CATEGORY_TABLEVIEW_TAG) {
        [self.picturebookShop userSelectsCategoryAtIndex:indexPath.row];
        [[self getTableViewForTag:COVERS_TABLEVIEW_TAG] reloadData];
        
    }
}

@end
