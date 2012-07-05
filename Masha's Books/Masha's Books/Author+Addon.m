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
    
    //Initialize new author in context
    Author *author = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:context];
    
    //Extract the author attributes from XML
    author.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
    
    author.name = [attributes objectForKey:@"Name"];
    
    author.websiteURL = [attributes objectForKey:@"AuthorWebsiteURL"];
    
    return author; 
    
}

- (void)fillAuthorElement:(NSString *)element withDescription:(NSString *)description {
    if ([element isEqualToString:@"AuthorBioHTML"]) {
        self.bioHtml = description;
    }
}

@end
