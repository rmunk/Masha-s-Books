//
//  Category+Addon.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category.h"
#import "Book.h"
#import "CategoryToBookMap.h"

@interface Category (Addon)

//+ (void)categoryWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;

+ (void)categoryWithAttributes:(NSDictionary *)attributes;

//+ (void)pickBookFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context forCategory:(Category *)category;

+ (void)pickBookFromLinker:(CategoryToBookMap *)categoryToBookMap forCategory:(Category *)category;

//+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap;

//+ (NSOrderedSet *)getAllCategoriesFromContext:(NSManagedObjectContext *)context;

+ (NSOrderedSet *)getAllCategories;

//+ (void)loadBackgroundsForContext:(NSManagedObjectContext *)context;

+ (void)loadBackgrounds;

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap;

@end
