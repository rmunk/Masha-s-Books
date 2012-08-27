//
//  CategoryTableViewController.h
//  Masha's Books
//
//  Created by Luka Miljak on 8/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicturebookShop.h"
#import "Category.h"
#import "Category+Addon.h"

@interface CategoryTableViewController : UITableViewController

@property (nonatomic, strong) PicturebookShop *shop;
@property (nonatomic, strong) UIManagedDocument *libraryDatabase;
@property (nonatomic, strong) NSOrderedSet *categories;

@end
