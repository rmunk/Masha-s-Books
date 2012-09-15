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
        
        category.bgImageURL = [attributes objectForKey:@"BGImage"];
    }
    else if (categoryWithID.count == 1) {
        Category *category = [categoryWithID lastObject];
        NSLog(@"Category with ID=%d already exists in database. Updating...", [category.categoryID intValue]);

        
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
        NSLog(@"Category with ID=%d already exists in database. Updating...", [category.categoryID intValue]);
        
        
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

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"]; 
    NSError *error;
    NSArray *categories = [context executeFetchRequest:request error:&error];
    
    for (Category *category in categories) 
        [self pickBookFromLinker:categoryToBookMap inContext:context forCategory:category];
    
}

+ (void)linkCategoriesToBooksWithLinker:(CategoryToBookMap *)categoryToBookMap {
    
    NSArray *categories = [Category MR_findAll];
    
    for (Category *category in categories) 
        [self pickBookFromLinker:categoryToBookMap forCategory:category];
    
}

+ (NSOrderedSet *)getAllCategoriesFromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"]; 
    NSError *error;
    
    //request.sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"name"
    //                              ascending:YES
    //                               selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *authorWithID = [context executeFetchRequest:request error:&error];
    NSOrderedSet *authorWithIDSet = [[NSOrderedSet alloc] initWithArray:authorWithID];
    return authorWithIDSet;
    
}

+ (NSOrderedSet *)getAllCategories {
    
    NSArray *categoriesArray = [Category MR_findAll];
    NSOrderedSet *categories = [[NSOrderedSet alloc] initWithArray:categoriesArray];
    return categories;
    
}

+ (void)loadBackgroundsForContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSError *error;
    NSArray *categories = [context executeFetchRequest:request error:&error];
    
    for (Category *category in categories) {
        
        NSURL *backgroundURL = [[NSURL alloc] initWithString:
                                    [NSString stringWithFormat:@"%@%@", 
                                     @"http://www.mashasbookstore.com", category.bgImageURL]];
      
        
        NSLog(@"Downloading background image for category %@ at %@", category.name, backgroundURL);
        
        // Get an image from the URL below
        dispatch_queue_t backgroundsDownloadQueue = dispatch_queue_create("category download", NULL);
        dispatch_async(backgroundsDownloadQueue, ^{
            
            UIImage *background = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:backgroundURL]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{                    
                if (background != nil) {                                    
                               
                    category.bgImage = background;
                    
                    NSLog(@"Downloaded background image for category %@", category.name);
                        
                    
                }
            });   
        });
        dispatch_release(backgroundsDownloadQueue);
    } 

    
}

+ (void)loadBackgrounds {

    NSArray *categories = [Category MR_findAll];
    
    for (Category *category in categories) {
        
        NSURL *backgroundURL = [[NSURL alloc] initWithString:
                                [NSString stringWithFormat:@"%@%@", 
                                 @"http://www.mashasbookstore.com", category.bgImageURL]];
        
        
        NSLog(@"Downloading background image for category %@ at %@", category.name, backgroundURL);
    
        [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext)
        {
            UIImage *background = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:backgroundURL]]; 
            if (background != nil) {                                    
                
                category.bgImage = background;
                
                NSLog(@"Downloaded background image for category %@", category.name);
                
                
            } 
        }
        completion:^{NSLog(@"My Books BG images downloaded and saved to database.");}
        errorHandler:^(NSError *error){ NSLog(@"%@", error.localizedDescription); }]; 

        
        // Get an image from the URL below
        
    } 
    
    
}

- (void)pickYourBooksFromLinkerObject:(CategoryToBookMap *)categoryToBookMap {
    
}

@end
