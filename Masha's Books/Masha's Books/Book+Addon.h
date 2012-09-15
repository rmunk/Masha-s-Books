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

@class PicturebookShop;

@interface Book (Addon)

//+ (Book *)bookWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;
+ (Book *)bookWithAttributes:(NSDictionary *)attributes;

//+ (void)pickBookCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context forBook:(Book *)book;
+ (void)pickBookCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap forBook:(Book *)book;

//+ (void)linkBooksToCategoriesWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;
+ (void)linkBooksToCategoriesWithLinker:(CategoryToBookMap *)categoryToBookMap;

//+ (void)linkBooksToAuthorsInContext:(NSManagedObjectContext *)context;
+ (void)linkBooksToAuthors;

+ (void)loadCoversFromURL:(NSString *)coverUrlString forShop:(PicturebookShop *)shop;
//+ (void)loadCoversFromURL:(NSString *)coverUrlString;

+ (void)updateBook:(Book *)book withAttributes:(NSDictionary *)attributes;

//+ (NSArray *)getAllBooksFromContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllBooks;

//+ (NSOrderedSet *)getBooksForCategory:(Category *)category inContext:(NSManagedObjectContext *)context;
+ (NSOrderedSet *)getBooksForCategory:(Category *)category;

//+ (Book *)getBookWithId:(NSNumber *)bookID inContext:(NSManagedObjectContext *)context withErrorHandler:(NSError *)error;
+ (Book *)getBookWithId:(NSNumber *)bookID withErrorHandler:(NSError *)error;

- (void)fillBookElement:(NSString *)element withDescription:(NSString *)description;

//- (void)pickYourCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;
- (void)pickYourCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMa;

- (void)downloadBookZipFileforShop:(PicturebookShop *)shop;
@end
