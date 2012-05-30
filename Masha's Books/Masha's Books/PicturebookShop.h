//
//  PicturebookShop.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PicturebookInfo.h"
#import "PicturebookCategory.h"
#import "PicturebookAuthor.h"

@interface PicturebookShop : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSURL *urlBase;
@property (nonatomic, strong) NSMutableOrderedSet *books;
@property (nonatomic, strong) NSMutableOrderedSet *categories;
@property (nonatomic, strong) NSMutableOrderedSet *authors;
@property (readwrite) BOOL isShopLoaded;

- (PicturebookShop *)initShop;
- (void)refreshShop;    
- (NSOrderedSet *)getBooksForCategory:(PicturebookCategory *)pbCategory;
- (NSOrderedSet *)getBooksForCategoryName:(PicturebookCategory *)pbCategory;


@end
