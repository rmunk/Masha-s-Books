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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"]; 
    NSError *error;
    
    request.predicate = [NSPredicate predicateWithFormat:@"categoryID = %d", [[attributes objectForKey:@"ID"] integerValue]];
    NSArray *categoryWithID = [context executeFetchRequest:request error:&error];
    
    if (categoryWithID.count == 0) {
        Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        
        category.categoryID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        
        category.name = [attributes objectForKey:@"Name"];
    }
    else if (categoryWithID.count == 1) {
        Category *category = [categoryWithID lastObject];
        
        if (![category.categoryID isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]]]) {
            category.categoryID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        }
        
        if (![category.name isEqualToString:[attributes objectForKey:@"Name"]]) {
            category.name = [attributes objectForKey:@"Name"];
        }
    }
    else {
         NSLog(@"ERROR: Database inconsisctency: To many categories with sam ID in database!");
    }
    
    

}

+ (void)pickBookFromLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context forCategory:(Category *)category {
    
    //kreiranje fetch requesta
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"]; 
    NSError *error;
    NSArray *bookForCategory = [categoryToBookMap getBookIdentifiersForCategoryIdentifier:[category.categoryID intValue]];
    
    for (NSNumber *bookID in bookForCategory) {        
        request.predicate = [NSPredicate predicateWithFormat:@"bookID = %d", [bookID intValue]];
        NSArray *booksWithID = [context executeFetchRequest:request error:&error];
        if (booksWithID.count == 1) {
            [category addBooksObject:(Book *)[booksWithID lastObject]];
            NSLog(@"Dodajem knjigu %@ u kategoriju %@", ((Book *)[booksWithID lastObject]).title, category.name);
        }
        else if (booksWithID.count > 1) {
            NSLog(@"ERROR: Multiple entries for category ID = %d in database!", [bookID intValue]);
        }
        else {
            NSLog(@"ERROR: No entries for category ID = %d in database! Linker error.", [bookID intValue]);
        }                  
    }
}

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"]; 
    NSError *error;
    NSArray *categories = [context executeFetchRequest:request error:&error];
    
    for (Category *category in categories) 
        [self pickBookFromLinker:categoryToBookMap inContext:context forCategory:category];
    
}

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap {
    
}

@end
