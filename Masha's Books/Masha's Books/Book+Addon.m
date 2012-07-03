//
//  Book+Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Book+Addon.h"

@implementation Book (Addon)

+ (Book *)bookWithAttributes:(NSDictionary *)attributes forContext:(NSManagedObjectContext *)context {
    
    Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.mm.yyyy"];
    
    book.bookID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
    
    book.type = [NSNumber numberWithInt:[[attributes objectForKey:@"Type"] integerValue]];
    
    book.title = [attributes objectForKey:@"Title"];
    
    book.appStoreID = [NSNumber numberWithInt:[[attributes objectForKey:@"AppleStoreID"] integerValue]];
    
    book.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"AuthorID"] integerValue]];
    
    book.publishDate = [df dateFromString:[attributes objectForKey:@"PublishDate"]];
    
    book.downloadURL = [attributes objectForKey:@"DownloadURL"];
    
    book.facebookLikeURL = [attributes objectForKey:@"FacebookLikeURL"];
    
    book.youTubeVideoURL = [attributes objectForKey:@"YouTubeVideoURL"];
    
    book.active = [attributes objectForKey:@"Active"];
    
    return book;

}

+ (void)fillBookElement:(NSString *)element withDescription:(NSString *)description forBook:(Book *)book {
    if ([element isEqualToString:@"DescriptionHTML"]) {
        book.descriptionHTML = description;
    }
    else if ([element isEqualToString:@"DescriptionLongHTML"]) {
        book.descriptionLongHTML = description;
    }
}

+ (Book *)refreshBook:(Book *)book withNewAttributes:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context {
    return book;
    #warning Implement!
    
}
+ (void)refreshBook:(Book *)book withNewDescription:(NSString *)description forElement:(NSString *)element {
    #warning Implement!
}

@end
