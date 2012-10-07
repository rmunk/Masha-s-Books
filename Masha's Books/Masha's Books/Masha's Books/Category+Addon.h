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

+ (void)categoryWithAttributes:(NSDictionary *)attributes;

+ (void)pickBookFromLinker:(CategoryToBookMap *)categoryToBookMap forCategory:(Category *)category;

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap;

+ (NSOrderedSet *)getAllCategories;

+ (void)loadBackgrounds;

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap;

@end
