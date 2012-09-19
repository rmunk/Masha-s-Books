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


@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *myBooks;
@property (weak, nonatomic) IBOutlet UITableView *myBooksTableView;
@property (nonatomic, weak) MBDatabase *database;

@end

@implementation SettingsViewController
@synthesize myBooks = _myBooks;
@synthesize myBooksTableView = _myBooksTableView;
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
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Book *bookFromMainThread = [self.myBooks objectAtIndex:indexPath.row];
        
        [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext) {
        
            Book *book = [bookFromMainThread MR_inContext:localContext];
            Image *coverImage = [bookFromMainThread.coverImage MR_inContext:localContext];
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
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        //tu dodati da se ponovo skine knjiga
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

@end
