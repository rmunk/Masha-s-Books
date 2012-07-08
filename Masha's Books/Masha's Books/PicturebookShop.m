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
@property (nonatomic, strong) CategoryToBookMap *categoryToBookMap;
@property (nonatomic, strong) Category *selectedCategory; //currently browsed book category in shop


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
@synthesize categoryToBookMap = _categoryToBookMap;
@synthesize selectedCategory = _selectedCategory;
@synthesize numberOfBooksWhinchNeedCoversDownloaded = _numberOfBooksWhinchNeedCoversDownloaded;

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
    self.categoryToBookMap = [[CategoryToBookMap alloc] init];
    self.numberOfBooksWhinchNeedCoversDownloaded = 0;
    
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
        self.isShopLoaded = YES;
    else 
        [self shopErrorLoading];

}

- (void)refreshDatabase {
    
    dispatch_queue_t refreshQ = dispatch_queue_create("Database refreshener", NULL);
    
    NSLog(@"Category to book pairs:");
    
    NSArray *array = [self.categoryToBookMap getCategoryBookPairsArray];
    
    for (NSArray *catToBookPair in array) {
        NSLog(@"    [%d, %d]", [[catToBookPair objectAtIndex:0] intValue], [[catToBookPair objectAtIndex:1] intValue]);
    }
    
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

- (void)userSelectsCategoryAtIndex:(NSUInteger)index {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"]; 
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]; 
    request.sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSError *error;
    NSArray *categories = [self.libraryDatabase.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"Number of categories is %d", categories.count);
    if (categories.count && index < categories.count) {
        self.selectedCategory = [categories objectAtIndex:index];
        NSLog(@"User selects category %@", self.selectedCategory.name);
    } 
    else {
        NSLog(@"ERROR: Index %d out of bounds for user selected category!", index);
    }
}

- (NSOrderedSet *)getBooksForSelectedCategory {
    return [Book getBooksForCategory:self.selectedCategory inContext:self.libraryDatabase.managedObjectContext];
}

- (void)coversLoaded {
    [self shopDataLoaded];
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
        NSLog(@"PARSING STARTED");
		return;		
	}
    else if([elementName isEqualToString:@"categories"]) {
                    
        [Category categoryWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
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
        
        [self.categoryToBookMap pairCategory:catID withBook:bookID];
        

               
    }
	else if([elementName isEqualToString:@"book"]) {       
        
        //Initialize new picture book
        self.currentBook = [Book bookWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        
        

        
	}
    else if([elementName isEqualToString:@"author"]) {
        
        self.currentAuthor = [Author authorWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        
        //Initialize new author
        self.pbookAuthor = [[PicturebookAuthor alloc] init];
        PBDLOG(@"\n");
        PBDLOG(@"New author found!");
        
        //Extract the author attributes from XML
        self.pbookAuthor.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        PBDLOG_ARG(@"Author ID: %d", [[attributeDict objectForKey:@"ID"] integerValue]);
        
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
    
    [self.currentBook fillBookElement:self.currentElementValue withDescription:string];
    [self.currentAuthor fillAuthorElement:self.currentElementValue withDescription:string];
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"book"] && ![self.books containsObject:self.pbookInfo]) {
        //[self.books addObject:self.pbookInfo];        
        PBDLOG(@"Book info storred!");
        
        self.currentBook = nil;
    }
    else if ([elementName isEqualToString:@"categories"] && ![self.categories containsObject:self.pbookCategory]) {
        [self.categories addObject:self.pbookCategory];
        [self putObject:self.pbookCategory inContext:self.libraryDatabase.managedObjectContext];
        PBDLOG(@"Category info storred!");
    }
    else if ([elementName isEqualToString:@"author"]) {
        [self.authors addObject:self.pbookAuthor];
        [self putObject:self.pbookAuthor inContext:self.libraryDatabase.managedObjectContext];
        PBDLOG(@"Author info storred!");
        
        self.currentAuthor = nil;
    }
    else if ([elementName isEqualToString:@"bookstore"]) {
       
        NSLog(@"PARSING FINISHED");
        // ovdi pozvat funkcije za likanje knjiga i kategorija, knjiga i autora
        [Book linkBooksToCategoriesWithLinker:self.categoryToBookMap inContext:self.libraryDatabase.managedObjectContext];
        [Book linkBooksToAuthorsInContext:self.libraryDatabase.managedObjectContext];
        // fillBookWithCovers
        [Book loadCoversFromURL:@"http://www.mashasbooks.com/covers/" forShop:self];
        NSLog(@"Books covers downloaded!");
        
        // save database
        
        [self.libraryDatabase saveToURL:self.libraryDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success) 
                NSLog(@"Library database saved!");                
        }];
        
        NSLog(@"Persistent store size: %llu bytes", [self directorySizeAtPath:[self.libraryDatabase.fileURL path]]);
        
        
        
        
        
    }
}


@end

