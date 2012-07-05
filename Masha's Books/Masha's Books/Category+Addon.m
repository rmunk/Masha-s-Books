//
//  Category+Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category+Addon.h"

@implementation Category (Addon)

+ (void)categoryWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context {
    
    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
    
    category.categoryID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
    
    category.name = [attributes objectForKey:@"Name"];

}

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap {
    
}

@end
