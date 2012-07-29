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

+ (Book *)bookWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;
+ (void)pickBookCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context forBook:(Book *)book;
+ (void)linkBooksToCategoriesWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;
+ (void)linkBooksToAuthorsInContext:(NSManagedObjectContext *)context;
+ (void)loadCoversFromURL:(NSString *)coverUrlString forShop:(PicturebookShop *)shop;
+ (void)updateBook:(Book *)book withAttributes:(NSDictionary *)attributes;
+ (NSArray *)getAllBooksFromContext:(NSManagedObjectContext *)context;
+ (NSOrderedSet *)getBooksForCategory:(Category *)category inContext:(NSManagedObjectContext *)context;
+ (Book *)getBookWithId:(NSNumber *)bookID inContext:(NSManagedObjectContext *)context withErrorHandler:(NSError *)error;

- (void)fillBookElement:(NSString *)element withDescription:(NSString *)description;
- (void)pickYourCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;
- (void)downloadBookZipFileforShop:(PicturebookShop *)shop;
@end
