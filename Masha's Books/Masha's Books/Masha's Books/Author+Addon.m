//
//  Author+Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Author+Addon.h"

@implementation Author (Addon)

+ (Author *)authorWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context {
    
    NSArray *authorWithID = [Author getAuthorWithID:[NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]] fromContext:context];
    
    if (authorWithID.count == 0) {
        //Initialize new author in context
        Author *author = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:context];
        
        //Extract the author attributes from XML
        author.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        
        author.name = [attributes objectForKey:@"Name"];
        
        author.websiteURL = [attributes objectForKey:@"AuthorWebsiteURL"];
        
        return author;
    }
    else if (authorWithID.count == 1) {
        Author *author = [authorWithID lastObject];
        
        NSLog(@"Author with ID=%d already exists in database. Updating...", [author.authorID intValue]);
        
        if (![author.authorID isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]]]) {
            author.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        }
        
        if (![author.name isEqualToString:[attributes objectForKey:@"Name"]]) {
            author.name = [attributes objectForKey:@"Name"];
        }
        
        if (![author.websiteURL isEqualToString:[attributes objectForKey:@"AuthorWebsiteURL"]]) {
            author.websiteURL = [attributes objectForKey:@"AuthorWebsiteURL"];
        }
                
        
        return author;      
    }
    else {
        NSLog(@"ERROR: Database inconsisctency: To many authors with same ID in database!");
        return nil;
    }
       
    
}

+ (Author *)authorWithAttributes:(NSDictionary *)attributes {
    
    NSArray *authorWithID = [Author getAuthorWithID:[NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]]];
    
    if (authorWithID.count == 0) {
        //Initialize new author in context
        Author *author = [Author createEntity];
        
        //Extract the author attributes from XML
        author.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        
        author.name = [attributes objectForKey:@"Name"];
        
        author.websiteURL = [attributes objectForKey:@"AuthorWebsiteURL"];
        
        return author;
    }
    else if (authorWithID.count == 1) {
        Author *author = [authorWithID lastObject];
        
        NSLog(@"Author with ID=%d already exists in database. Updating...", [author.authorID intValue]);
        
        if (![author.authorID isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]]]) {
            author.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        }
        
        if (![author.name isEqualToString:[attributes objectForKey:@"Name"]]) {
            author.name = [attributes objectForKey:@"Name"];
        }
        
        if (![author.websiteURL isEqualToString:[attributes objectForKey:@"AuthorWebsiteURL"]]) {
            author.websiteURL = [attributes objectForKey:@"AuthorWebsiteURL"];
        }
        
        
        return author;      
    }
    else {
        NSLog(@"ERROR: Database inconsisctency: To many authors with same ID in database!");
        return nil;
    }
    
    
}


+ (NSArray *)getAllAuthorsFromContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Author"]; 
    NSError *error;
    
    NSArray *authors = [context executeFetchRequest:request error:&error];
    
    return authors;
    
}

+ (NSArray *)getAllAuthors {
    
    return [Author MR_findAll];
    
}

+ (NSArray *)getAuthorWithID:(NSNumber *)iD fromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Author"]; 
    NSError *error;
    
    request.predicate = [NSPredicate predicateWithFormat:@"authorID = %d", [iD intValue]];
    NSArray *authorWithID = [context executeFetchRequest:request error:&error];
    
    return authorWithID;
}

+ (NSArray *)getAuthorWithID:(NSNumber *)iD {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"authorID = %d", [iD intValue]];
    NSArray *authorWithID = [Author MR_findAllWithPredicate:predicate];
    
    return authorWithID;
}

+ (NSArray *)getAuthorWithName:(NSString *)name fromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Author"]; 
    NSError *error;
    
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSArray *authorWithName = [context executeFetchRequest:request error:&error];
    return authorWithName;
}

+ (NSArray *)getAuthorWithName:(NSString *)name {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"authorID = %d", name];
    NSArray *authorWithID = [Author MR_findAllWithPredicate:predicate];
    
    return authorWithID;
}

- (void)fillAuthorElement:(NSString *)element withDescription:(NSString *)description {
    if ([element isEqualToString:@"AuthorBioHTML"]) {
        self.bioHtml = description;
    }
}

@end
