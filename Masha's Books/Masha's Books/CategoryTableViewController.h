//
//  CategoryTableViewController.h
//  Masha's Books
//
//  Created by Luka Miljak on 8/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class CategoryTableViewController;

#import <UIKit/UIKit.h>
#import "PicturebookShop.h"
#import "Category.h"
#import "Category+Addon.h"

@protocol categoryTableViewControllerProtocol <NSObject>

- (void)categoryPicked:(Category *)category inController:(CategoryTableViewController *)controller;

@end

@interface CategoryTableViewController : UITableViewController

@property (nonatomic, strong) NSOrderedSet *categories;
@property (nonatomic, strong) id <categoryTableViewControllerProtocol> delegate;
@property (weak, nonatomic) UIPopoverController *popoverController;


@end
