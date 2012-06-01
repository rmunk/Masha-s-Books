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
@property (nonatomic, strong) PicturebookCategory *selectedPicturebookCategory;
@end

@implementation PicturebookShopViewController
@synthesize shopRefreshButton = _shopRefreshButton;
@synthesize shopWebView = _shopWebView;
@synthesize selectedCoverTumbnailView = _selectedCoverTumbnailView;
@synthesize buyButton = _buyButton;

@synthesize picturebookShop = _picturebookShop;
@synthesize selectedPicturebookCategory = _selectedPicturebookCategory;

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
}

- (void)picturebookShopFinishedLoading:(NSNotification *) notification {
    PBDLOG(@"Picture book shop reports loading finished!");
    
    
    /* Za testiranje kad bude implementiran description html
    PicturebookInfo *pbInfo = [[self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory] objectAtIndex:0];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    [self.shopWebView loadHTMLString:pbInfo. baseURL:
     */
    
    [[self getTableViewForTag:COVERS_TABLEVIEW_TAG] reloadData];
    [self.view setNeedsDisplay];
}

- (void)picturebookShopLoadingError:(NSNotification *) notification {
    PBDLOG(@"ERROR: Picture book shop reports loading error!");
}

- (IBAction)shopItemTapped:(PicturebookCover *)sender{
    PBDLOG_ARG(@"Shop item tapped: %@", sender.pbInfo.title);
    
    [self.shopWebView loadHTMLString:sender.pbInfo.descriptionHTML baseURL:nil];
    PBDLOG_ARG(@"Picturebook descriptionHTML: %@", sender.pbInfo.descriptionHTML);
    self.selectedCoverTumbnailView.image = sender.pbInfo.coverImage;
    [self.selectedCoverTumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    //[self.shopWebView reload];
    self.buyButton.hidden = FALSE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Registering to PicturebookShop notifications (laoding succesful and loading error)
    self.selectedPicturebookCategory = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    self.buyButton.hidden = TRUE;
    
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
            PBDLOG_ARG(@"Category table number of rows: %i", self.picturebookShop.categories.count);
            return self.picturebookShop.categories.count;
            
            
        }
        else if (tableView.tag == COVERS_TABLEVIEW_TAG) {
            int numOfRows = [self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory].count / NUM_OF_COVERS_IN_ROW_PORTRAIT;
            if ([self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory].count % NUM_OF_COVERS_IN_ROW_PORTRAIT)
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
    static NSString *CellIdentifier = @"Cell";

    CoverTableRowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	
	if (tableView.tag == CATEGORY_TABLEVIEW_TAG) {
        if (cell == nil) 
            cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero];
        PicturebookCategory *pbCategory = [self.picturebookShop.categories objectAtIndex:indexPath.row];
        cell.textLabel.text = pbCategory.name;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        //[cell.textLabel setTextColor:[UIColor lightTextColor]];
        //[cell.textLabel setFont:[UIFont systemFontOfSize:22.0]];
        //cell.backgroundColor = [UIColor clearColor];
    }
    else if (tableView.tag == COVERS_TABLEVIEW_TAG) {
        if (cell == nil) {
            NSMutableOrderedSet *rowPbInfos = [[NSMutableOrderedSet alloc] init];
            for (int i = indexPath.row * NUM_OF_COVERS_IN_ROW_PORTRAIT; (i < (indexPath.row * NUM_OF_COVERS_IN_ROW_PORTRAIT + NUM_OF_COVERS_IN_ROW_PORTRAIT)) && i < [self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory].count; i++) {
                [rowPbInfos addObject:[[self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory] objectAtIndex:i]];
            }
                
            cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero 
                                    withNumberOfCoversInRow:NUM_OF_COVERS_IN_ROW_PORTRAIT
                                                withWidthOf:tableView.bounds.size.width 
                               desiredDistanceBetweenCovers:20 
                                       andPictureBookCovers:rowPbInfos 
                                                 withTarget:self 
                                                 withAction:@selector(shopItemTapped:)];
            
            if (tableView.rowHeight != cell.cellHeight) {
                tableView.rowHeight = cell.cellHeight;
                [tableView reloadData];
            }            
        }
    }	
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (tableView.tag == CATEGORY_TABLEVIEW_TAG) {
        PicturebookCategory *pbCategory = [self.picturebookShop.categories objectAtIndex:indexPath.row];
        self.selectedPicturebookCategory = pbCategory;
        [[self getTableViewForTag:COVERS_TABLEVIEW_TAG] reloadData];
    }
}


@end
