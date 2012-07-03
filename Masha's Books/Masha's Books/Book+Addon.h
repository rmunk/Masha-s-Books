//
//  Book+Addon.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Book.h"

@interface Book (Addon)

+ (Book *)bookWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;
+ (void)fillBookElement:(NSString *)element withDescription:(NSString *)description forBook:(Book *)book;
+ (Book *)refreshBook:(Book *)book withNewAttributes:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;
+ (void)refreshBook:(Book *)book withNewDescription:(NSString *)description forElement:(NSString *)element;
//+ (void)pickYourCategories()

@end
