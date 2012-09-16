//
//  Category+Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category+Addon.h"

@implementation Category (Addon)

+ (void)categoryWithAttributes:(NSDictionary *)attributes {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID = %d", [[attributes objectForKey:@"ID"] integerValue]];
    NSArray *categoryWithID = [Category MR_findAllWithPredicate:predicate];
    
    if (categoryWithID.count == 0) {
        Category *category = [Category createEntity];
        
        category.categoryID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        
        category.name = [attributes objectForKey:@"Name"];
        
        category.bgImageURL = [attributes objectForKey:@"BGImage"];
    }
    else if (categoryWithID.count == 1) {
        Category *category = [categoryWithID lastObject];
        //NSLog(@"Category with ID=%d already exists in database. Updating...", [category.categoryID intValue]);
        
        
        if (![category.categoryID isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]]]) {
            category.categoryID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        }
        
        if (![category.name isEqualToString:[attributes objectForKey:@"Name"]]) {
            category.name = [attributes objectForKey:@"Name"];
        }
        
        if (![category.bgImageURL isEqualToString:[attributes objectForKey:@"BGImage"]]) {
            category.bgImageURL = [attributes objectForKey:@"BGImage"];
        }
    }
    else {
        NSLog(@"ERROR: Database inconsisctency: To many categories with sam ID in database!");
    }
}

+ (void)pickBookFromLinker:(CategoryToBookMap *)categoryToBookMap forCategory:(Category *)category {
    
    //kreiranje fetch requesta
    NSArray *bookForCategory = [categoryToBookMap getBookIdentifiersForCategoryIdentifier:[category.categoryID intValue]];
    
    for (NSNumber *bookID in bookForCategory) {        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID = %d", [bookID intValue]];
        NSArray *booksWithID = [Category MR_findAllWithPredicate:predicate];
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

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap {
    
    NSArray *categories = [Category MR_findAll];
    
    for (Category *category in categories) 
        [self pickBookFromLinker:categoryToBookMap forCategory:category];
    
}

+ (NSOrderedSet *)getAllCategories {
    
    NSArray *categoriesArray = [Category MR_findAll];
    NSOrderedSet *categories = [[NSOrderedSet alloc] initWithArray:categoriesArray];
    return categories;
    
}

+ (void)loadBackgrounds {

    NSArray *categories = [Category MR_findAll];
    
    [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext)
     {
    
         for (Category *category in categories) {
             
             //Category *localCategory = [category MR_inContext:localContext];
        
             NSURL *backgroundURL = [[NSURL alloc] initWithString:
                                     [NSString stringWithFormat:@"%@%@", 
                                      @"http://www.mashasbookstore.com", category.bgImageURL]];
        
        
             NSLog(@"Downloading background image for category %@ at %@", category.name, backgroundURL);
    
        
             NSData *background = [NSData dataWithContentsOfURL:backgroundURL]; 
             if (background != nil) {                                    
                
                category.bgImage = background;
                
                NSLog(@"Downloaded background image for category %@", category.name);
                
            } 
        }
     }
    completion:^{
        [[NSManagedObjectContext MR_defaultContext] save:nil];
        NSLog(@"Categories background images downloaded and saved to database.");
    }
                                errorHandler:nil];
}

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap {
    
}

@end
