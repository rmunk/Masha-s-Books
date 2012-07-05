//
//  Book+Addon.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Book.h"
#import "Category.h"
#import "CategoryToBookMap.h"

@interface Book (Addon)

+ (Book *)bookWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;

- (void)fillBookElement:(NSString *)element withDescription:(NSString *)description;
- (Book *)refreshBook:(Book *)book withNewAttributes:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;
- (void)refreshBook:(Book *)book withNewDescription:(NSString *)description forElement:(NSString *)element;
- (void)pickYourCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;
- (void)pickYourAuthorFromContext:(NSManagedObjectContext *)context;
- (void)pickYourCoversFromURL:(NSURL *)coverUrl;

+ (void)linkBooksToCategoriesWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;

+ (void)pickBookCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context forBook:(Book *)book;

@end
