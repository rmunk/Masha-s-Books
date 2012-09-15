//
//  SettingsViewController.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "Book.h"


@interface SettingsViewController () <UITableViewDataSource>
@property (nonatomic, strong) NSArray *myBooks;

@end

@implementation SettingsViewController
@synthesize myBooks = _myBooks;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
    self.myBooks = [Book MR_findAllSortedBy:@"downloadDate" ascending:NO withPredicate:predicate];

    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
}

@end
