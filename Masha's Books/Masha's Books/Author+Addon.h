//
//  Author+Addon.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Author.h"

@interface Author (Addon)

//+ (Author *)authorWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context;
+ (Author *)authorWithAttributes:(NSDictionary *)attributes;

//+ (NSArray *)getAllAuthorsFromContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllAuthors;

//+ (NSArray *)getAuthorWithID:(NSNumber *)iD fromContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAuthorWithID:(NSNumber *)iD;

//+ (NSArray *)getAuthorWithName:(NSString *)name fromContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAuthorWithName:(NSString *)name;


- (void)fillAuthorElement:(NSString *)element withDescription:(NSString *)description;

@end
