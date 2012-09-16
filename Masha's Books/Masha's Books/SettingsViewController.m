//
//  SettingsViewController.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "Book.h"
#import "UIImage+Resize.h"


@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *myBooks;
@property (weak, nonatomic) IBOutlet UITableView *myBooksTableView;

@end

@implementation SettingsViewController
@synthesize myBooks = _myBooks;
@synthesize myBooksTableView = _myBooksTableView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBookReady:) name:@"BookReady" object:nil ];
    self.myBooksTableView.editing = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
    self.myBooks = [Book MR_findAllSortedBy:@"downloadDate" ascending:NO withPredicate:predicate];
    [self.myBooksTableView reloadData];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setMyBooksTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Store notifications

- (void)newBookReady:(NSNotification *)notification
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
    self.myBooks = [Book MR_findAllSortedBy:@"downloadDate" ascending:NO withPredicate:predicate];
    [self.myBooksTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myBooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyBooksTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier];
    }
    
    Book *book = [self.myBooks objectAtIndex:indexPath.row];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f MB", [book.size floatValue]];
    cell.imageView.image = [[UIImage imageWithData:book.coverThumbnailImage] resizedImage:CGSizeMake(64, 48) interpolationQuality:kCGInterpolationMedium];
    
    return cell;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row % 2 == 0)
//        return UITableViewCellEditingStyleInsert;
//    else
//        return UITableViewCellEditingStyleDelete;
//}
//
@end
