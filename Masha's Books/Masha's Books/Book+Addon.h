//
//  Book+Addon.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Book.h"
#import "Category.h"
#import "Author.h"
#import "Image.h"
#import "CategoryToBookMap.h"
#import "Author+Addon.h"
#import "PicturebookShop.h"
#import "MBDatabase.h"

@class PicturebookShop;
@class MBDatabase;

@interface Book (Addon)

+ (Book *)bookWithAttributes:(NSDictionary *)attributes;

+ (void)pickBookCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap forBook:(Book *)book;

+ (void)linkBooksToCategoriesWithLinker:(CategoryToBookMap *)categoryToBookMap;

+ (void)linkBooksToAuthors;

+ (void)loadCoversFromURL:(NSString *)coverUrlString forShop:(PicturebookShop *)shop;

+ (void)loadCoversFromURL:(NSString *)coverUrlString forDatabase:(MBDatabase *)database;

+ (void)updateBook:(Book *)book withAttributes:(NSDictionary *)attributes;

+ (NSArray *)getAllBooks;

+ (NSOrderedSet *)getBooksForCategory:(Category *)category;

+ (NSOrderedSet *)getMyBooks;

+ (NSOrderedSet *)getBoughtBooks;

+ (Book *)getBookWithId:(NSNumber *)bookID withErrorHandler:(NSError *)error;

- (void)fillBookElement:(NSString *)element withDescription:(NSString *)description;

- (void)pickYourCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap;

- (void)preloadPageNumber:(NSNumber *)pageNumber;

@end
