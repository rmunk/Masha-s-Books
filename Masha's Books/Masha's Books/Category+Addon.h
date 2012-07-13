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

+ (void)categoryWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;

+ (void)pickBookFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context forCategory:(Category *)category;

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context;

+ (NSOrderedSet *)getAllCategoriesFromContext:(NSManagedObjectContext *)context;

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap;

@end
