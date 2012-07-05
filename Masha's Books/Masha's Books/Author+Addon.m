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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Author"]; 
    NSError *error;
    
    request.predicate = [NSPredicate predicateWithFormat:@"authorID = %d", [[attributes objectForKey:@"ID"] integerValue]];
    NSArray *authorWithID = [context executeFetchRequest:request error:&error];
    
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
        
        if (author.authorID != [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]]) {
            author.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        }
        
        if (author.name != [attributes objectForKey:@"Name"]) {
            author.name = [attributes objectForKey:@"Name"];
        }
        
        if (author.websiteURL != [attributes objectForKey:@"AuthorWebsiteURL"]) {
            author.websiteURL = [attributes objectForKey:@"AuthorWebsiteURL"];
        }
        
        return author;      
    }
    else {
        NSLog(@"ERROR: Database inconsisctency: To many authors with sam ID in database!");
        return nil;
    }
       
    
}

- (void)fillAuthorElement:(NSString *)element withDescription:(NSString *)description {
    if ([element isEqualToString:@"AuthorBioHTML"]) {
        self.bioHtml = description;
    }
}

@end
