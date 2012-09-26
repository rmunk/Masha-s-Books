//
//  SettingsViewController.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "Book.h"
#import "Page.h"
#import "Image.h"
#import "UIImage+Resize.h"


@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSOrderedSet *boughtBooks;
@property (weak, nonatomic) IBOutlet UITableView *myBooksTableView;
@property (strong, nonatomic) Book *selectedBook;
@property (nonatomic, weak) MBDatabase *database;

@end

@implementation SettingsViewController
@synthesize boughtBooks = _boughtBooks;
@synthesize myBooksTableView = _myBooksTableView;
@synthesize selectedBook = _selectedBook;
@synthesize database = _database;

- (void)refresh
{
    self.boughtBooks = [self.database getBoughtBooks];
    [self.myBooksTableView reloadData];
}

- (void)setMBD:(MBDatabase *)database {
    self.database = database;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"BookReady" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"BookDeleted" object:nil ];
    self.myBooksTableView.editing = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setMyBooksTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.boughtBooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyBooksTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier];
    }
    
    Book *book = [self.boughtBooks objectAtIndex:indexPath.row];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f MB", [book.size floatValue]];
    cell.imageView.image = [[UIImage imageWithData:book.coverThumbnailImage] resizedImage:CGSizeMake(64, 48) interpolationQuality:kCGInterpolationMedium];
    if ([[cell.subviews lastObject] isKindOfClass:[UIActivityIndicatorView class]] == NO) {
        UIActivityIndicatorView *bookLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        bookLoadingIndicator.frame = CGRectMake(0, 0, 41, cell.frame.size.height-1);
        bookLoadingIndicator.contentMode = UIViewContentModeCenter;
        [cell addSubview:bookLoadingIndicator];
    }
    if (book.status == @"downloading" || book.status == @"deleting" || book.status == @"queued") {
        [[cell.subviews lastObject] startAnimating];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selectedBook = [self.boughtBooks objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Book"
                                                        message:[NSString stringWithFormat:@"Do you want to delete book\n \"%@\"?", self.selectedBook.title]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Book"
                                                        message:[NSString stringWithFormat:@"Do you want to restore book\n \"%@\"?", self.selectedBook.title]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.title == @"Delete Book") {
        if (buttonIndex == 1)
        {
            [self.database userDeletesBook:self.selectedBook];
            [self refresh];
        }
        else
            [self.myBooksTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.boughtBooks indexOfObject:self.selectedBook] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

    }
    else if (alertView.title == @"Restore Book") {
        if (buttonIndex == 1)
        {
            [self.database userBuysBook:self.selectedBook];
            [self refresh];
        }
    }
    else if (alertView.title == @"Leave Masha's Bookstore?") {
        if (buttonIndex == 1) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.accessibilityHint]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = [self.boughtBooks objectAtIndex:indexPath.row];
    
    if ([book.status isEqualToString:@"ready"])
        return UITableViewCellEditingStyleDelete;
    else if ([book.status isEqualToString:@"bought"])
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleNone;
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

@end
