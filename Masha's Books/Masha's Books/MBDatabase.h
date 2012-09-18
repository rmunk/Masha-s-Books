//
//  MBDatabase.h
//  Masha's Books
//
//  Created by Luka Miljak on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "Book+Addon.h"
#import "Category.h"
#import "Category+Addon.h"
#import "CategoryToBookMap.h"

#define MBD_DEBUG 1

#ifdef MBD_DEBUG
#define MBDLOG NSLog
#else
#define MBDLOG 
#endif

#define URL_BookstoreXML @"http://www.mashasbookstore.com/storeops/bookstore-xml.aspx"
#define URL_BookCovers @"http://www.mashasbookstore.com/storeops/bookstore-xml.aspx"

@class MDDatabase;

@interface MBDatabase : NSObject <NSXMLParserDelegate>

- (MBDatabase *)initMBD;

- (void)userBuysBook:(Book *)book;
- (void)userDeletesBook:(Book *)book;
- (void)coversLoaded;

- (NSOrderedSet *)getCategoriesInShop;
- (NSOrderedSet *)getBooksForCategory:(Category *)category;


@end
