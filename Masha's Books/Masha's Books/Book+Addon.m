//
//  Book+Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Book+Addon.h"
#import "BookExtractor.h"

@implementation Book (Addon)

+ (Book *)bookWithAttributes:(NSDictionary *)attributes {
    
    //kreiranje fetch requesta
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID = %d", [[attributes objectForKey:@"ID"] integerValue]];
    NSArray *booksWithID = [Book MR_findAllWithPredicate:predicate];
    
    
    if ([booksWithID count] == 0) {
        //ako knjige nema u bazi onda ovo
        
        Book *book = [Book createEntity];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd.mm.yyyy"];
        
        book.bookID = [NSNumber numberWithInt:[[attributes objectForKey:@"ID"] integerValue]];
        
        book.type = [NSNumber numberWithInt:[[attributes objectForKey:@"Type"] integerValue]];
        
        book.price = [NSNumber numberWithFloat:[[attributes objectForKey:@"Price"] floatValue]];
        
        book.rate = [NSNumber numberWithFloat:[[attributes objectForKey:@"Rate"] floatValue]];
        
        book.tag = [NSNumber numberWithFloat:[[attributes objectForKey:@"Tag"] floatValue]];
        
        book.title = [attributes objectForKey:@"Title"];
        
        book.appStoreID = [NSNumber numberWithInt:[[attributes objectForKey:@"AppleStoreID"] integerValue]];
        
        book.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"AuthorID"] integerValue]];
        
        book.publishDate = [df dateFromString:[attributes objectForKey:@"PublishDate"]];
        
        book.downloadURL = [attributes objectForKey:@"DownloadURL"];
        
        book.facebookLikeURL = [attributes objectForKey:@"FacebookLikeURL"];
        
        book.youTubeVideoURL = [attributes objectForKey:@"YouTubeVideoURL"];
        
        book.active = [attributes objectForKey:@"Active"];
        
        book.downloaded = [NSNumber numberWithInt:0];
        
        /* ovde se treba provjerit jeli knjiga vec kupljena, ako je drugaciji botun treba bit za nju u shopu
         i za knjigu treba postavit status bought */
        
        book.status = [NSString stringWithString:@"available"];
        
        return book;
    }
    else if ([booksWithID count] == 1)       
    {
        Book *book = [booksWithID lastObject];
        // ovdje treba refreshat postojecu knjigu s novi atributima
        NSLog(@"Book with ID=%d already exists in database. Updating...", [book.bookID intValue]);
        [Book updateBook:book withAttributes:attributes];
        
        return book;
    }
    else {
        NSLog(@"ERROR: More than one book with ID $d exists in database!");
        return nil;
    }   
}

+ (void)pickBookCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap forBook:(Book *)book {
    
    //kreiranje fetch requesta
    NSArray *categoriesForBook = [categoryToBookMap getCategoryIdentifiersForBookIdentifier:[book.bookID intValue]];
    
    for (NSNumber *catID in categoriesForBook) {        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID = %d", [catID intValue]];
        NSArray *categoriesWithID = [Category MR_findAllWithPredicate:predicate];
        if (categoriesWithID.count == 1) {
            [book addCategoriesObject:(Category *)[categoriesWithID lastObject]];
            //NSLog(@"Dodajem kategoriju %@ u knjigu %@", ((Category *)[categoriesWithID lastObject]).name, book.title);
        }
        else if (categoriesWithID.count > 1) {
            NSLog(@"ERROR: Multiple entries for category ID = %d in database!", [catID intValue]);
        }
        else {
            NSLog(@"ERROR: No entries for category ID = %d in database! Linker error.", [catID intValue]);
        }                  
    }
}

+ (void)linkBooksToCategoriesWithLinker:(CategoryToBookMap *)categoryToBookMap {
    
    NSArray *books = [Book MR_findAll];
    
    for (Book *book in books) 
        [self pickBookCategoriesFromLinker:categoryToBookMap forBook:book];
    
}

+ (void)linkBooksToAuthors {
    
    NSArray *books = [Book MR_findAll];
    
    for (Book *book in books) {
        
        NSArray *author = [Author getAuthorWithID:book.authorID];        
        if (author.count == 1) {
            book.author = [author lastObject];
            NSLog(@"Found autor %@ for book %@ in database!", ((Author *)[author lastObject]).name, book.title);
        }
        else if (author.count > 1)
        {
            NSLog(@"ERROR: Multiple autors for book %@ in database!", book.title);
        }
        else {
            NSLog(@"ERROR: No authors for book %@ in database!", book.title);
        }
    }
}

+ (void)loadCoversFromURL:(NSString *)coverUrlString forShop:(PicturebookShop *)shop {

    //NSArray *books = [Book getAllBooksFromContext:shop.libraryDatabase.managedObjectContext];
    NSArray *books = [Book MR_findAll];
    //Book *book = [books lastObject];
    
    shop.numberOfBooksWhinchNeedCoversDownloaded = books.count;
    NSLog(@"Number of books for cover download = %d", shop.numberOfBooksWhinchNeedCoversDownloaded);
    
    [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext)
     { 
    
         for (Book *book in books) {
             
            //Book *localBook = [book MR_inContext:localContext];
        
            NSURL *coverThumbnailURL = [[NSURL alloc] initWithString:
                                        [NSString stringWithFormat:@"%@%d%@", 
                                         coverUrlString, [book.bookID intValue], @"_s.jpg"]];
        
            NSURL *coverThumbnailMediumURL = [[NSURL alloc] initWithString:
                                    [NSString stringWithFormat:@"%@%d%@", 
                                     coverUrlString, [book.bookID intValue], @"_m.jpg"]];
        
            NSURL *rateImageUpURL = [[NSURL alloc] initWithString:
                                    [NSString stringWithFormat:@"%@%d%@", 
                                     @"http://www.mashasbookstore.com/tags/rate", [book.rate intValue], @".png"]];
        
            NSURL *tagImageLargeURL = [[NSURL alloc] initWithString:
                                    [NSString stringWithFormat:@"%@%d%@", 
                                     @"http://www.mashasbookstore.com/tags/tag", [book.tag intValue], @".png"]];
        
            NSURL *tagImageSmallURL = [[NSURL alloc] initWithString:
                                   [NSString stringWithFormat:@"%@%d%@", 
                                    @"http://www.mashasbookstore.com/tags/tag", [book.tag intValue], @"s.png"]];

        
            NSLog(@"Downloading cover images for book %@ at %@", book.title, coverThumbnailURL);

             
            
            // Get an image from the URL below
            NSData *coverThumbnailImage = [NSData dataWithContentsOfURL:coverThumbnailURL];
            NSData *coverThumbnailUImageMedium = [NSData dataWithContentsOfURL:coverThumbnailMediumURL];
            NSData *rateImageUp = [NSData dataWithContentsOfURL:rateImageUpURL];
            NSData *tagImageLarge = [NSData dataWithContentsOfURL:tagImageLargeURL];
            NSData *tagImageSmall = [NSData dataWithContentsOfURL:tagImageSmallURL];
            
            if (coverThumbnailImage && coverThumbnailUImageMedium) {                                    
                                      
                book.coverThumbnailImage = coverThumbnailImage;
                book.coverThumbnailImageMedium = coverThumbnailUImageMedium;
                book.rateImageUp = rateImageUp;
                book.tagImageLarge = tagImageLarge;
                book.tagImageSmall = tagImageSmall;
                //book.coverImage = coverImage;
                
                //[self shopDataLoaded];
                
            } 
        }
     }
    completion:^{ 
        NSLog(@"Book covers downloaded");
        [shop coversLoaded];

//        if (shop.numberOfBooksWhinchNeedCoversDownloaded > 1) {
//            shop.numberOfBooksWhinchNeedCoversDownloaded = shop.numberOfBooksWhinchNeedCoversDownloaded - 1;
//            NSLog(@"Number of books left = %d", shop.numberOfBooksWhinchNeedCoversDownloaded);
//        }
//        else {
//            shop.numberOfBooksWhinchNeedCoversDownloaded = 0;
//            [[NSManagedObjectContext MR_defaultContext] save:nil];
//            NSLog(@"Book covers downloaded");
//            [shop coversLoaded];
//        }
    }
    errorHandler:nil]; 
     
}

+ (void)loadCoversFromURL:(NSString *)coverUrlString forDatabase:(MBDatabase *)database {
    
    NSArray *books = [Book MR_findAll];
    
    [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext)
    { 
         
        for (Book *book in books) {
             
            NSURL *coverThumbnailURL = [[NSURL alloc] initWithString:
                                         [NSString stringWithFormat:@"%@%d%@", 
                                          coverUrlString, [book.bookID intValue], @"_s.jpg"]];
             
            NSURL *coverThumbnailMediumURL = [[NSURL alloc] initWithString:
                                               [NSString stringWithFormat:@"%@%d%@", 
                                                coverUrlString, [book.bookID intValue], @"_m.jpg"]];
             
            NSURL *rateImageUpURL = [[NSURL alloc] initWithString:
                                      [NSString stringWithFormat:@"%@%d%@", 
                                       @"http://www.mashasbookstore.com/tags/rate", [book.rate intValue], @".png"]];
             
            NSURL *tagImageLargeURL = [[NSURL alloc] initWithString:
                                        [NSString stringWithFormat:@"%@%d%@", 
                                         @"http://www.mashasbookstore.com/tags/tag", [book.tag intValue], @".png"]];
             
            NSURL *tagImageSmallURL = [[NSURL alloc] initWithString:
                                        [NSString stringWithFormat:@"%@%d%@", 
                                         @"http://www.mashasbookstore.com/tags/tag", [book.tag intValue], @"s.png"]];
             
             
            NSLog(@"Downloading cover images for book %@ at %@", book.title, coverThumbnailURL);
             
             
            // Get an image from the URL below
            NSData *coverThumbnailImage = [NSData dataWithContentsOfURL:coverThumbnailURL];
            NSData *coverThumbnailUImageMedium = [NSData dataWithContentsOfURL:coverThumbnailMediumURL];
            NSData *rateImageUp = [NSData dataWithContentsOfURL:rateImageUpURL];
            NSData *tagImageLarge = [NSData dataWithContentsOfURL:tagImageLargeURL];
            NSData *tagImageSmall = [NSData dataWithContentsOfURL:tagImageSmallURL];
             
            if (coverThumbnailImage && coverThumbnailUImageMedium) {                                    
                 
                book.coverThumbnailImage = coverThumbnailImage;
                book.coverThumbnailImageMedium = coverThumbnailUImageMedium;
                book.rateImageUp = rateImageUp;
                book.tagImageLarge = tagImageLarge;
                book.tagImageSmall = tagImageSmall;
                 
            } 
        }
    }
    completion:^{ 
        NSLog(@"Book covers downloaded");
        [database coversLoaded];
    }
    errorHandler:nil]; 
}



+ (void)updateBook:(Book *)book withAttributes:(NSDictionary *)attributes {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.mm.yyyy"];
    
    if (![book.type isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"Type"] integerValue]]]) {
        book.type = [NSNumber numberWithInt:[[attributes objectForKey:@"Type"] integerValue]];
        NSLog(@"New value for book %@ attribute book.type", book.title);
    }
    
    if (![book.price isEqualToNumber:[NSNumber numberWithFloat:[[attributes objectForKey:@"Price"] floatValue]]]) {
        book.price = [NSNumber numberWithFloat:[[attributes objectForKey:@"Price"] floatValue]];
        NSLog(@"New value for book %@ attribute book.price", book.title);
    }
    
    if (![book.rate isEqualToNumber:[NSNumber numberWithFloat:[[attributes objectForKey:@"Rate"] floatValue]]]) {
        book.rate = [NSNumber numberWithFloat:[[attributes objectForKey:@"Rate"] floatValue]];
        NSLog(@"New value for book %@ attribute book.rate", book.title);
    }
    
    if (![book.tag isEqualToNumber:[NSNumber numberWithFloat:[[attributes objectForKey:@"Tag"] floatValue]]]) {
        book.tag = [NSNumber numberWithFloat:[[attributes objectForKey:@"Tag"] floatValue]];
        NSLog(@"New value for book %@ attribute book.tag", book.title);
    }
    
    if (![book.title isEqualToString:[attributes objectForKey:@"Title"]]) {
        book.title = [attributes objectForKey:@"Title"];
        NSLog(@"New value for book %@ attribute book.title", book.title);
    }
    
    if (![book.appStoreID isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"AppleStoreID"] integerValue]]]) {
        book.appStoreID = [NSNumber numberWithInt:[[attributes objectForKey:@"AppleStoreID"] integerValue]];
        NSLog(@"New value for book %@ attribute book.appstoreID", book.title);
    }
    
    if (![book.authorID isEqualToNumber:[NSNumber numberWithInt:[[attributes objectForKey:@"AuthorID"] integerValue]]]) {
        book.authorID = [NSNumber numberWithInt:[[attributes objectForKey:@"AuthorID"] integerValue]];
        NSLog(@"New value for book %@ attribute book.authorID", book.title);
    }  
    
    if (![book.publishDate isEqualToDate:[df dateFromString:[attributes objectForKey:@"PublishDate"]]]) {
        book.publishDate = [df dateFromString:[attributes objectForKey:@"PublishDate"]];
        NSLog(@"New value for book %@ attribute book.publishDate", book.title);
    } 
    
    if (![book.downloadURL isEqualToString:[attributes objectForKey:@"DownloadURL"]]) {
        book.downloadURL = [attributes objectForKey:@"DownloadURL"];
        NSLog(@"New value for book %@ attribute book.downloadURL", book.title);
    } 
    
    if (![book.facebookLikeURL isEqualToString:[attributes objectForKey:@"FacebookLikeURL"]]) {
        book.facebookLikeURL = [attributes objectForKey:@"FacebookLikeURL"];
        NSLog(@"New value for book %@ attribute book.facebookLikeURL", book.title);
    }
    
    if (![book.youTubeVideoURL isEqualToString:[attributes objectForKey:@"YouTubeVideoURL"]]) {
        book.youTubeVideoURL = [attributes objectForKey:@"YouTubeVideoURL"];
        NSLog(@"New value for book %@ attribute book.youTubeVideoURL", book.title);
    }
    
    if (![book.active isEqualToString:[attributes objectForKey:@"Active"]]) {
        book.active = [attributes objectForKey:@"Active"];
        NSLog(@"New value for book %@ attribute book.active", book.title);
    }    
}

+ (NSArray *)getAllBooks {
    
    return [Book MR_findAll];
}

+ (NSOrderedSet *)getBooksForCategory:(Category *)category {
    
    NSArray *books = [Book MR_findAllSortedBy:@"bookID" ascending:YES];
    
    NSMutableOrderedSet *booksInCategory = [[NSMutableOrderedSet alloc] init];
    
    for (Book *book in books) {
        for (Category *cat in book.categories) {
            if (category.categoryID == cat.categoryID ) {
                [booksInCategory addObject:book];
            }
        }
    }
    
    return [booksInCategory copy];
}

+ (Book *)getBookWithId:(NSNumber *)bookID withErrorHandler:(NSError *)error {
    
    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID = %d", [bookID integerValue]];
    NSArray *booksWithID = [Book findAllWithPredicate:predicate];
    
    if ([booksWithID count] == 0) {
        //ako knjige nema u bazi onda ovo
        NSLog(@"ERROR: Requested book not gound in database!");        
        return nil;
    }
    else if ([booksWithID count] == 1)       
    {
        return (Book *)([booksWithID lastObject]);
    }
    else {
        NSLog(@"ERROR: More than one book with ID $d exists in database!");
        [errorDetails setValue:@"ERROR: More than one book with ID $d exists in database!" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"database" code:200 userInfo:errorDetails];
        return nil;
    }
}

- (void)fillBookElement:(NSString *)element withDescription:(NSString *)description {
    if ([element isEqualToString:@"Description"]) 
        self.descriptionString = description;
}

- (void)pickYourCategoriesFromLinker:(CategoryToBookMap *)categoryToBookMap {
    
    NSArray *categoriesForBook = [categoryToBookMap getCategoryIdentifiersForBookIdentifier:[self.bookID intValue]];
    
    for (NSNumber *catID in categoriesForBook) {        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID = %d", [catID intValue]];
        NSArray *categoriesWithID = [Category findAllWithPredicate:predicate];
        if (categoriesWithID.count == 1) {
            [self addCategoriesObject:(Category *)[categoriesWithID lastObject]];
            //NSLog(@"Dodajem kategoriju %@ u knjigu %@", ((Category *)[categoriesWithID lastObject]).name, self.title);
        }
        else if (categoriesWithID.count > 1) {
            NSLog(@"ERROR: Multiple entries for category ID = %d in database!", [catID intValue]);
        }
        else {
            NSLog(@"ERROR: No entries for category ID = %d in database! Linker error.", [catID intValue]);
        }                  
    }
}





@end
