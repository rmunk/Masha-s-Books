//
//  PicturebookShop.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicturebookShop.h"


@interface PicturebookShop()
@property (nonatomic, strong) NSURL *shopURL;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) PicturebookInfo *pbookInfo; //buffer book handle for xml parsing
@property (nonatomic, strong) PicturebookCategory *pbookCategory;
@property (nonatomic, strong) PicturebookAuthor *pbookAuthor;
@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong) NSString *currentElementValue;
@property (nonatomic, weak) Book *currentBook;
@property (nonatomic, weak) Author *currentAuthor;

@end

@implementation PicturebookShop

@synthesize urlBase = _urlBase;
@synthesize books = _books;
@synthesize categories = _categories;
@synthesize authors = _authors;

@synthesize libraryDatabase = _libraryDatabase;

@synthesize shopURL = _shopURL;
@synthesize xmlParser = _xmlParser;
@synthesize pbookInfo = _pbookInfo;
@synthesize pbookCategory = _pbookCategory;
@synthesize pbookAuthor = _pbookAuthor;
@synthesize df = _df;
@synthesize currentElementValue = _currentElementValue;
@synthesize currentBook = _currentBook;
@synthesize currentAuthor = _currentAuthor;

@synthesize isShopLoaded = _isShopLoaded;


- (PicturebookShop *)initShop {
    self = [super init];
    self.shopURL = [[NSURL alloc] initWithString:@"http://www.mashasbooks.com/storeops/bookstore-xml.aspx"];
    //_shopURL = [[NSURL alloc] initWithString:@"http://dl.dropbox.com/u/286270/PicturebookShop.xml"];
    
    self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.shopURL];
    if (self.xmlParser) {
        PBDLOG_ARG(@"Picturebook shop found at %@", self.shopURL.description);
    }
    [self.xmlParser setDelegate:self];
    
    // Init library database UIManagedDocument
    if (!self.libraryDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Library"];
        self.libraryDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    self.categories = [[NSMutableOrderedSet alloc] init];
    self.books = [[NSMutableOrderedSet alloc] init];
    self.authors = [[NSMutableOrderedSet alloc] init];
    
    self.currentElementValue = [[NSString alloc] init];
    //self.currentBookElement = [[NSString alloc] init];
    //self.currentAuthorElement = [[NSString alloc] init];
    
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"dd.mm.yyyy"]; 
    
    self.isShopLoaded = NO;
    
    return self;
}

// useDocument method   - if picture-book database does not exist, it creates it
//                      - if picture-book database exists but it's not open, it opens it
//                      - if picture-book database is open, use database
- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.libraryDatabase.fileURL path]]) {
        [self.libraryDatabase saveToURL:self.libraryDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            NSLog(@"Database at %@ does not exist. Creating...", self.libraryDatabase.fileURL);
            [self useDocument];
        }];
    } else if (self.libraryDatabase.documentState == UIDocumentStateClosed) {
        [self.libraryDatabase openWithCompletionHandler:^(BOOL success){
            NSLog(@"Database at %@ exist. Opening...", self.libraryDatabase.fileURL);
            [self useDocument];
        }];
    } else if (self.libraryDatabase.documentState == UIDocumentStateNormal) {
        NSLog(@"Database at %@ is opened and ready for use.", self.libraryDatabase.fileURL);
    }
}

- (void)setLibraryDatabase:(UIManagedDocument *)libraryDatabase
{
    if (_libraryDatabase != libraryDatabase) {
        _libraryDatabase = libraryDatabase;
        [self useDocument];
    }
}

//Method for calculation of directory size. No recursion so for now works correctly only if directory does not have any sub directories.
- (unsigned long long int)directorySizeAtPath:(NSString *)directoryPath {
    NSError *error = nil;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directoryPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[directoryPath stringByAppendingPathComponent:fileName] error:&error];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

- (void)refreshShop {
    
    PBDLOG_ARG(@"Picturebook shop: Refreshing shop from URL %@", [self.shopURL description]);
    
    [self.categories removeAllObjects];
    //PicturebookCategory *all = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];   

    //[self.categories addObject:all];    // Add "All" category to categories sets
 
    [self.books removeAllObjects];
    
    [self.authors removeAllObjects];
     
    self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.shopURL];
    if (self.xmlParser) {
        PBDLOG_ARG(@"Picturebook shop found at %@", self.shopURL.description);
    }
    [self.xmlParser setDelegate:self];
    
    BOOL parsingSuccesfulll = [self.xmlParser parse];
    
    if (parsingSuccesfulll == YES) 
    {
        [self populateShopWithImages];
        self.isShopLoaded = YES;
        //[self shopDataLoaded];
        //samo za testiranje!!!!!!!
        //[self refreshDatabase];
    }
    else {
        [self shopErrorLoading];
    }
    
    /*
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"]; 
    request.predicate = [NSPredicate predicateWithFormat:@"book.title=%@", @"dummy book"];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]; 
    request.sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSManagedObjectContext *moc = self.libraryDatabase.managedObjectContext;
    NSError *error;
    NSArray *books = [moc executeFetchRequest:request error:&error];
    for (Book *book in books) {
        NSLog(@"Book found");
    }
    */
}

- (void)refreshDatabase {
    
    dispatch_queue_t refreshQ = dispatch_queue_create("Database refreshener", NULL);
    
    dispatch_async(refreshQ, ^{
        [self.libraryDatabase.managedObjectContext performBlock:^{
            for (PicturebookInfo *pbInfo in self.books) {
               
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"]; 
                NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]; 
                request.sortDescriptors = [NSArray arrayWithObject:sortByName];
                NSManagedObjectContext *moc = self.libraryDatabase.managedObjectContext;
                NSError *error;
                NSArray *books = [moc executeFetchRequest:request error:&error];
                NSLog(@"Number of books : %d", books.count);
                for (Book *book in books) {
                    NSLog(@"Book found : %@", book.title);
                }
                
                
                //kreiraj predikat tako da dohvaca knjige s naslovom "title"
                request.predicate = [NSPredicate predicateWithFormat:@"title = %@", pbInfo.title];
                NSArray *booksWithTitle = [moc executeFetchRequest:request error:&error];
                
                if (booksWithTitle != NULL) {
                    for (Book *pbk in booksWithTitle) {
                        NSLog(@"Book %@ already exists, deleting old entry...", pbk.title);
                        [self.libraryDatabase.managedObjectContext deleteObject:pbk]; 
                    }
                }
                
            
                Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.libraryDatabase.managedObjectContext];
                Image *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.libraryDatabase.managedObjectContext];
                Author *author = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:self.libraryDatabase.managedObjectContext];
                
                
                if (book && image && author) {
                    
                    image.image = pbInfo.coverImage;
                    
                    author.name = @"Unknown book author";
                    for (PicturebookAuthor *pbAuth in self.authors) {
                        if (pbAuth.iD == pbInfo.authorID) {
                            author.name = pbAuth.name;
                        }
                    }
                    NSLog(@"Book author: %@", author.name);
                    
                    //category.name = @"Unknown book category";
                    for (PicturebookCategory *pbCat in pbInfo.bookCategories) {
                        Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.libraryDatabase.managedObjectContext];
                        category.name = pbCat.name;
                        [book addCategoriesObject:category];
                        NSLog(@"Book category: %@", category.name);                        
                    }
                    
                    
                    
                    book.title = pbInfo.title;
                    book.author = author;
                    book.appStoreID = [[NSNumber alloc] initWithInt:pbInfo.appStoreID];
                    book.coverImage = image;
                    book.downloaded = [NSNumber numberWithInt:1] ;
                    
                    NSLog(@"Storing book %@", pbInfo.title);
                    
                    NSLog(@"Persistent store size: %llu bytes", [self directorySizeAtPath:[self.libraryDatabase.fileURL path]]);
                }
                else {
                    NSLog(@"Error creating library entities.");
                }               
            
            }
        }];
    });
    dispatch_release(refreshQ);
    
    [self.libraryDatabase saveToURL:self.libraryDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Library database saved!");
            /*
            NSLog(@"Reading database books:");
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"]; 
            //request.predicate = [NSPredicate predicateWithFormat:@"book.title=%@", @"*"];
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]; 
            request.sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSManagedObjectContext *moc = self.libraryDatabase.managedObjectContext;
            NSError *error;
            NSArray *books = [moc executeFetchRequest:request error:&error];
            NSLog(@"Number of books : %d", books.count);
            for (Book *book in books) {
                //NSLog(@"Book found : %@", book.title);
            }
            */

        }
    }];
}

// Populating PicturebookInfo instances with cover images
- (void)populateShopWithImages {
    //NSInteger numOfImageDownloadingThreads = 0;
    for (PicturebookInfo *pbInfo in self.books) {
        
        if ([pbInfo isKindOfClass:[PicturebookInfo class]]) { 
            
            NSURL *coverURL = [[NSURL alloc] initWithString:
                               [NSString stringWithFormat:@"%@%d%@", 
                                @"http://www.mashasbooks.com/covers/", pbInfo.iD, @".jpg"]]; 
            PBDLOG_ARG(@"Downloading cover image for book %@", pbInfo.title);
            
            // Get an image from the URL below
            dispatch_queue_t downloadQueue = dispatch_queue_create("image download", NULL);
            dispatch_async(downloadQueue, ^{
                
                UIImage *coverImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:coverURL]];
                dispatch_async(dispatch_get_main_queue(), ^{                    
                    if (coverImage) {                                    
                        PBDLOG(@"Image downloaded!");
                        pbInfo.coverImage = coverImage;
                        [self shopDataLoaded];
                    }
                });                                                 
                
            });
            dispatch_release(downloadQueue);
            
        }
    }    
}

- (void)putObject:(id)obj inContext:(NSManagedObjectContext *)context {
    if ([obj isKindOfClass:[PicturebookAuthor class]]) {
        NSLog(@"Putting author %@ in context", ((PicturebookAuthor *)obj).name);
    }
    else if ([obj isKindOfClass:[PicturebookCategory class]]) {
        NSLog(@"Putting author %@ in context", ((PicturebookCategory *)obj).name);
    }
    else if ([obj isKindOfClass:[PicturebookAuthor class]]) {
        NSLog(@"Putting book %@ in context", ((PicturebookInfo *)obj).title);
    }    
}

- (NSOrderedSet *)getBooksForCategory:(PicturebookCategory *)pbCategory {
    
    NSMutableOrderedSet *booksForCategory = [[NSMutableOrderedSet alloc] init];
    
    NSLog(@"Books in category:");
    for (NSNumber *num in pbCategory.booksInCategory) {
        NSLog(@"bookID = %d", [num intValue]);
    }
    
    if (pbCategory.name == @"All") {    
        return [self.books copy];   // Adding new category "All"
    }/*
    else {  // Populate c
        for (PicturebookInfo *pbInfo in self.books) {
            if (pbInfo.catID == pbCategory.iD) {
                [booksForCategory addObject:pbInfo];    
            }
        }
        return [booksForCategory copy];
    }*/
    else {  // Populate categories other version
        for (NSNumber *pbID in pbCategory.booksInCategory) {
            for (PicturebookInfo *pbInfo in self.books) {
                if (pbInfo.iD == [pbID intValue]) {
                    [booksForCategory addObject:pbInfo];    
                }
            }            
        }
        return [booksForCategory copy];
    }
}

- (void)shopDataLoaded {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PicturebookShopFinishedLoading" object:nil];
}

- (void)shopErrorLoading {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PicturebookShopLoadingError" object:nil];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
    
    self.currentElementValue = elementName;
    
    if([elementName isEqualToString:@"bookstore"]) {
		return;		
	}
    else if([elementName isEqualToString:@"categories"]) {
                    
//        [Category categoryWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        PBDLOG(@"\n");
        PBDLOG(@"New book category found!");
        
        
        
        //Extract category attributes from XML
        NSInteger pbID = [[attributeDict objectForKey:@"ID"] integerValue];
        PBDLOG_ARG(@"Category ID: %i", pbID);
        
        NSString *pbName = [attributeDict objectForKey:@"Name"];
        PBDLOG_ARG(@"Category name: %@", pbName);        
        
        //Initialize new book category
        self.pbookCategory = [[PicturebookCategory alloc] initWithName:pbName AndID:pbID];
        
    }
    else if([elementName isEqualToString:@"categorybooks"]) {
        
        NSInteger catID, bookID;
        
        PBDLOG(@"\n");
        PBDLOG(@"New category-book link found!");
        
        catID = [[attributeDict objectForKey:@"catID"] integerValue];
        PBDLOG_ARG(@"Category ID: %i", catID);
        
        bookID = [[attributeDict objectForKey:@"bookID"] integerValue];
        PBDLOG_ARG(@"Book ID: %i", bookID);
        
        /*
        for (int i = 0; i < self.categories.count; i++) {
            if (((PicturebookCategory *)[self.categories objectAtIndex:i]).iD == catID) {
                [((PicturebookCategory *)[self.categories objectAtIndex:i]).booksInCategory addObject:[NSNumber numberWithInt:bookID]];
                NSLog(@"Matching category found: catID = %i, bookID = %i", catID, bookID);
            }
        }*/
        
        for (PicturebookCategory *cat in self.categories) {
            if (cat.iD == catID) {
                NSNumber *pbID = [NSNumber numberWithInt:bookID];
                [cat.booksInCategory addObject:pbID];
                NSLog(@"Books in category: %i", cat.booksInCategory.count);
                NSLog(@"Matching category found: catID = %i, bookID = %i", cat.iD, [[cat.booksInCategory lastObject] intValue]);
            }
            else {
                //PBDLOG_ARG(@"No matching category found for bookID: %i", bookID);
            }
        }
               
        //Initialize new category-book link
        /*
        self.pbookCategoryBookLink = [[PicturebookCategorybooks alloc] init];
        PBDLOG(@"\n");
        PBDLOG(@"New category-book link found!");
        
        self.pbookCategoryBookLink.catID = [[attributeDict objectForKey:@"catID"] integerValue];
        PBDLOG_ARG(@"Category ID: %i", self.pbookCategoryBookLink.catID);
        
        self.pbookCategoryBookLink.bookID = [[attributeDict objectForKey:@"bookID"] integerValue];
        PBDLOG_ARG(@"Book ID: %i", self.pbookCategoryBookLink.);*/
    }
	else if([elementName isEqualToString:@"book"]) {       
        
        //Initialize new picture book
        //self.currentBookElement = [[attributeDict objectForKey:@"ID"] integerValue]; // currectBookElement 
        self.pbookInfo = [[PicturebookInfo alloc] init];
//        self.currentBook = [Book bookWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        
        //TU TREBA DODAT ISPITIVANJE JELI VEC POSTOJI U KONTEKSTU BOOK S TIM ID. AKO GA NEMA ZVAT OVU GORE METODU,
        // A AKO GA IMA ZVAT METODU TIPA UPDATE BOOK U KOJOJ SE MOGU SAD PROMJENIT ATRIBUTI BOOKA
        // NA ISTU SHEMU TREBA IC I CATEGORY I AUTHOR
        
        PBDLOG(@"\n");
        PBDLOG(@"New book found!");
		
		//Extract the picture book attributes from XML
        
        self.pbookInfo.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        //book.bookID = [NSNumber numberWithInt:[[attributeDict objectForKey:@"ID"] integerValue]];
        PBDLOG_ARG(@"Book ID: %i", self.pbookInfo.iD);
        
        //book.type = [NSNumber numberWithInt:[[attributeDict objectForKey:@"Type"] integerValue]];
        //PBDLOG_ARG(@"Book type: %i", [book.type intValue]);
        
        self.pbookInfo.title = [attributeDict objectForKey:@"Title"];
        //book.title = [attributeDict objectForKey:@"Title"];
        PBDLOG_ARG(@"Book title: %@", self.pbookInfo.title);
        
        self.pbookInfo.appStoreID = [[attributeDict objectForKey:@"AppleStoreID"] integerValue];
        //book.appStoreID = [NSNumber numberWithInt:[[attributeDict objectForKey:@"AppleStoreID"] integerValue]];
        PBDLOG_ARG(@"Applestore ID:%i", self.pbookInfo.appStoreID);
        
        self.pbookInfo.authorID = [[attributeDict objectForKey:@"AuthorID"] integerValue];
        //book.authorID = [NSNumber numberWithInt:[[attributeDict objectForKey:@"AuthorID"] integerValue]];
        PBDLOG_ARG(@"Author ID:%i", self.pbookInfo.authorID);
        
        self.pbookInfo.publishDate = [self.df dateFromString:[attributeDict objectForKey:@"PublishDate"]];
        //book.publishDate = [self.df dateFromString:[attributeDict objectForKey:@"PublishDate"]];
        PBDLOG_ARG(@"Publish date:%@", self.pbookInfo.publishDate.description);
        
        self.pbookInfo.downloadUrl = [NSURL URLWithString:[attributeDict objectForKey:@"DownloadURL"]];
        //book.downloadURL = [attributeDict objectForKey:@"DownloadURL"];
        PBDLOG_ARG(@"Download URL:%@", self.pbookInfo.downloadUrl.description);
        
        self.pbookInfo.facebookLikeUrl = [NSURL URLWithString:[attributeDict objectForKey:@"FacebookLikeURL"]];
        //book.facebookLikeURL = [attributeDict objectForKey:@"FacebookLikeURL"];
        PBDLOG_ARG(@"Facebook URL:%@", self.pbookInfo.facebookLikeUrl.description);
        
        self.pbookInfo.youTubeVideoUrl = [NSURL URLWithString:[attributeDict objectForKey:@"YouTubeVideoURL"]];
        //book.youTubeVideoURL = [attributeDict objectForKey:@"YouTubeVideoURL"];
        PBDLOG_ARG(@"YouTube video URL:%@", self.pbookInfo.youTubeVideoUrl.description);
        
        //book.active = [attributeDict objectForKey:@"Active"];
        //PBDLOG_ARG(@"Book active: %@", book.active);

        
	}
    else if([elementName isEqualToString:@"author"]) {
        
//        self.currentAuthor = [Author authorWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        
        //Initialize new author
        self.pbookAuthor = [[PicturebookAuthor alloc] init];
        PBDLOG(@"\n");
        PBDLOG(@"New author found!");
        
        //Extract the author attributes from XML
        self.pbookAuthor.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        PBDLOG_ARG(@"Author ID: %i", self.pbookInfo.iD);
        
        self.pbookAuthor.name = [attributeDict objectForKey:@"Name"];
        //self.currentAuthorElement = self.pbookAuthor.name;
        PBDLOG_ARG(@"Author name: %@", self.pbookAuthor.name);
        
        self.pbookAuthor.websiteUrl = [NSURL URLWithString:[attributeDict objectForKey:@"AuthorWebsiteURL"]];
        PBDLOG_ARG(@"Author website: %@", self.pbookAuthor.websiteUrl.description);
    }    
    else if([elementName isEqualToString:@"DescriptionHTML"]) {
        return;
    }
    else if([elementName isEqualToString:@"DescriptionLongHTML"]) {
        return;
    }
    else if([elementName isEqualToString:@"AuthorBioHTML"]) {
        return;
    }
    else {
        return;
    }
        
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
    
    // For current XML format, only elements with character body are DescriptionHTML and DescriptionLongHTML
    // for book parrent and AutorBioHTML for author pattent
    
    [Book fillBookElement:self.currentElementValue withDescription:string forBook:self.currentBook];
    [Author fillAuthorElement:self.currentElementValue withDescription:string forAuthor:self.currentAuthor];
    
    
    if ([self.currentElementValue isEqualToString:@"DescriptionHTML"]) {
        self.pbookInfo.descriptionHTML = string;
        //PBDLOG_ARG(@"For book %@", self.currentBookElement);    
        //PBDLOG_ARG(@"DescriptionHTML %@", string);
    }
    else if ([self.currentElementValue isEqualToString:@"DescriptionLongHTML"]) {
        self.pbookInfo.descriptionLongHTML = string;
        //PBDLOG_ARG(@"For book %@", self.currentBookElement);    
        //PBDLOG_ARG(@"DescriptionLongHTML %@", string);
    }
    else if ([self.currentElementValue isEqualToString:@"AuthorBioHTML"]) {
        self.pbookAuthor.bioHtml = string;
        //PBDLOG_ARG(@"For author %@", self.currentAuthorElement);    
        //PBDLOG_ARG(@"AuthorBioHTML %@", string);
    }
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"book"] && ![self.books containsObject:self.pbookInfo]) {
        [self.books addObject:self.pbookInfo];        
        PBDLOG(@"Book info storred!");
        
        self.currentBook = nil;
    }
    else if ([elementName isEqualToString:@"categories"] && ![self.categories containsObject:self.pbookCategory]) {
        [self.categories addObject:self.pbookCategory];
        [self putObject:self.pbookCategory inContext:self.libraryDatabase.managedObjectContext];
        PBDLOG(@"Category info storred!");
    }/*
      else if ([elementName isEqualToString:@"categorybooks"] && ![self.categoryBookLinks containsObject:self.pbookCategoryBookLink]) {
      [self.categoryBookLinks addObject:self.pbookCategoryBookLink];
      PBDLOG(@"Category info storred!");
      }*/
    else if ([elementName isEqualToString:@"author"]) {
        [self.authors addObject:self.pbookAuthor];
        [self putObject:self.pbookAuthor inContext:self.libraryDatabase.managedObjectContext];
        PBDLOG(@"Author info storred!");
        
        self.currentAuthor = nil;
    }
}


@end

