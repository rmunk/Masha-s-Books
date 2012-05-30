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
    [self.picturebookShop refreshShop];
    NSLog(@"PicturebookShopViewController: Calling refreshShop."); 
    [self.view setNeedsDisplay];
    [[self getTableViewForTag:CATEGORY_TABLEVIEW_TAG] reloadData];
    [[self getTableViewForTag:COVERS_TABLEVIEW_TAG] reloadData];

}

- (void)picturebookShopFinishedLoading:(NSNotification *) notification {
    NSLog(@"Picture book shop reports loading finished!");
    
    /* Za testiranje kad bude implementiran description html
    PicturebookInfo *pbInfo = [[self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory] objectAtIndex:0];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    [self.shopWebView loadHTMLString:pbInfo. baseURL:
     */
}

- (void)picturebookShopLoadingError:(NSNotification *) notification {
    NSLog(@"ERROR: Picture book shop reports loading error!");
}

- (IBAction)shopItemTapped:(PicturebookCover *)sender{
    //NSLog(@"Shop item tapped!");
    NSLog(@"Shop item tapped: %@", sender.pbInfo.title);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Registering to PicturebookShop notifications (laoding succesful and loading error)
    self.selectedPicturebookCategory = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopFinishedLoading:) name:@"PicturebookShopFinishedLoading" object:nil ]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picturebookShopLoadingError:) name:@"PicturebookShopLoadingError" object:nil ];
    [((UIWebView *)[self getTableViewForTag:0]) loadHTMLString:@"smileys.html" baseURL:nil];
    
}

- (void)viewDidUnload
{
    [self setShopRefreshButton:nil];
    [self setShopWebView:nil];
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
            NSLog(@"Category table number of rows: %i", self.picturebookShop.categories.count);
            return self.picturebookShop.categories.count;
            
            
        }
        else if (tableView.tag == COVERS_TABLEVIEW_TAG) {
            int numOfRows = [self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory].count / NUM_OF_COVERS_IN_ROW_PORTRAIT;
            if ([self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory].count % NUM_OF_COVERS_IN_ROW_PORTRAIT)
                numOfRows++;
            NSLog(@"Picture books table number of rows: %i", numOfRows);
            //return self.picturebookShop.books.count;
            return numOfRows;
        }
        else {
            return 0;
        }
    }
    else {
        NSLog(@"Category table number of rows: Shop not red yet");
        return 0;
    }
}
    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CoverTableRowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (cell == nil) 
     //   cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero];
    
    //NSLog(@"Table view tag: %d", tableView.tag);
	
	if (tableView.tag == CATEGORY_TABLEVIEW_TAG) {
        if (cell == nil) 
            cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero];
        PicturebookCategory *pbCategory = [self.picturebookShop.categories objectAtIndex:indexPath.row];
        cell.textLabel.text = pbCategory.name;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        //NSLog(@"Setting category table cell");
    }
    else if (tableView.tag == COVERS_TABLEVIEW_TAG) {
        if (cell == nil) {
            NSMutableOrderedSet *rowPbInfos = [[NSMutableOrderedSet alloc] init];
            for (int i = indexPath.row * NUM_OF_COVERS_IN_ROW_PORTRAIT; (i < (indexPath.row * NUM_OF_COVERS_IN_ROW_PORTRAIT + NUM_OF_COVERS_IN_ROW_PORTRAIT)) && i < [self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory].count; i++) {
                [rowPbInfos addObject:[[self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory] objectAtIndex:i]];
            }
                
            cell = [[CoverTableRowCell alloc] initWithFrame:CGRectZero withWidthOf:tableView.bounds.size.width desiredDistanceBetweenCovers:20 
                                       andPictureBookCovers:rowPbInfos withTarget:self withAction:@selector(shopItemTapped:)];
        }
        
                                                                                                                                                                    
        
        /*
        PicturebookInfo *pbInfo = [[self.picturebookShop getBooksForCategory:self.selectedPicturebookCategory] objectAtIndex:indexPath.row];
        
        PicturebookCover *iView1 = [[PicturebookCover alloc] initWithFrame:CGRectMake(10, 10, 160, 160) AndPicturebookInfo:pbInfo];
        //UIButton *iView1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 160, 160)];
        [iView1 setImage:pbInfo.coverImage forState:UIControlStateNormal];
        [iView1 addTarget:self action:@selector(shopItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        //iView1.titleLabel.text = pbInfo.title;
        [cell.contentView addSubview:iView1];
        iView1.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *iView2 = [[UIImageView alloc] initWithFrame:CGRectMake(190, 10, 160, 160)];
        [cell.contentView addSubview:iView2];
        iView2.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *iView3 = [[UIImageView alloc] initWithFrame:CGRectMake(370, 10, 160, 160)];
        [cell.contentView addSubview:iView3];
        iView3.contentMode = UIViewContentModeScaleAspectFit;
        
        //cell.imageView.image = pbInfo.coverImage; 
        //((UIImageView *)[cell.contentView.subviews objectAtIndex:0]).image = pbInfo.coverImage;
        ((UIImageView *)[cell.contentView.subviews objectAtIndex:1]).image = pbInfo.coverImage;
        ((UIImageView *)[cell.contentView.subviews objectAtIndex:2]).image = pbInfo.coverImage;
        //NSLog(@"Setting picture books table cell");
         */
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
