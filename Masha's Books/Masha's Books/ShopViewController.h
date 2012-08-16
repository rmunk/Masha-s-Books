//
//  ShopViewController.h
//  Masha's Books
//
//  Created by Luka Miljak on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicturebookShop.h"
#import "Book.h"
#import "Category.h"
#import "BookExtractor.h"
#import "BooksTableCell.h"

#define BOOKCELL_HEIGHT 200


@interface ShopViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *categoryButton;
@property (strong, nonatomic) IBOutlet UITableView *booksTableView;
@property (strong, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (strong, nonatomic) IBOutlet UIWebView *bookWebView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
