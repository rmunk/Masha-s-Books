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
@property (nonatomic, strong) NSArray *myBooks;
@property (weak, nonatomic) IBOutlet UITableView *myBooksTableView;
@property (strong, nonatomic) Book *selectedBook;
@property (nonatomic, weak) MBDatabase *database;

@end

@implementation SettingsViewController
@synthesize myBooks = _myBooks;
@synthesize myBooksTableView = _myBooksTableView;
@synthesize selectedBook = _selectedBook;
@synthesize database = _database;

- (void)refresh
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status like 'ready' OR status like 'bought'"];
    self.myBooks = [Book MR_findAllSortedBy:@"size" ascending:NO withPredicate:predicate];
    [self.myBooksTableView reloadData];
}

- (void)setMBD:(MBDatabase *)database {
    self.database = database;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBookReady:) name:@"BookReady" object:nil ];
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

#pragma mark - Store notifications

- (void)newBookReady:(NSNotification *)notification
{
    [self refresh];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selectedBook = [self.myBooks objectAtIndex:indexPath.row];
    
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
            [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext) {
            
                Book *book = [self.selectedBook MR_inContext:localContext];
                Image *coverImage = [self.selectedBook.coverImage MR_inContext:localContext];
                NSLog(@"Fetched book %@ to delete", book.title);
                for (Page *pageToDelete in book.pages) [pageToDelete MR_deleteEntity];
                [coverImage MR_deleteEntity];
                book.backgroundMusic = nil;
                book.downloaded = 0;
                book.status = @"bought";
            }
            completion:^{
                [[NSManagedObjectContext MR_defaultContext] save:nil];
                [self refresh];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BookDeleted" object:self];
            }
            errorHandler:nil];
        }
        else
            [self.myBooksTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.myBooks indexOfObject:self.selectedBook] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

    }
    else if (alertView.title == @"Restore Book") {
        if (buttonIndex == 1)
        {
            // Restore Book
        }
    }
    else if (alertView.title == @"Leave Masha's Bookstore?") {
        if (buttonIndex == 1) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.accessibilityHint]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = [self.myBooks objectAtIndex:indexPath.row];
    
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
