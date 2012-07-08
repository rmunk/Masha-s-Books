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

@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong) NSString *currentElementValue;
@property (nonatomic, weak) Book *currentBook;
@property (nonatomic, weak) Author *currentAuthor;
@property (nonatomic, strong) CategoryToBookMap *categoryToBookMap;
@property (nonatomic, strong) Category *selectedCategory; //currently browsed book category in shop
@property (nonatomic, strong) Book *selectedBook;


@end

@implementation PicturebookShop

@synthesize urlBase = _urlBase;


@synthesize libraryDatabase = _libraryDatabase;

@synthesize shopURL = _shopURL;
@synthesize xmlParser = _xmlParser;

@synthesize df = _df;
@synthesize currentElementValue = _currentElementValue;
@synthesize currentBook = _currentBook;
@synthesize currentAuthor = _currentAuthor;
@synthesize categoryToBookMap = _categoryToBookMap;
@synthesize selectedCategory = _selectedCategory;
@synthesize selectedBook = _selectedBook;
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
    
    self.currentElementValue = [[NSString alloc] init];
    self.categoryToBookMap = [[CategoryToBookMap alloc] init];
    self.numberOfBooksWhinchNeedCoversDownloaded = 0;
    
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"dd.mm.yyyy"]; 
    
    self.isShopLoaded = NO;
    
    return self;
}

- (void)loadShopFromDatabase {
    self.isShopLoaded = YES;
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
        [self loadShopFromDatabase];
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
    
    //PicturebookCategory *all = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];   

    //[self.categories addObject:all];    // Add "All" category to categories sets
     
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
    
    dispatch_async(refreshQ, ^{
        [self.libraryDatabase.managedObjectContext performBlock:^{
   
        }];
    });
    dispatch_release(refreshQ);
    
    [self.libraryDatabase saveToURL:self.libraryDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success) {

        }
    }];
}

- (void)putObject:(id)obj inContext:(NSManagedObjectContext *)context {
  
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

- (void)userSelectsBook:(Book *)book {
    self.selectedBook = book;
}

- (Book *)getSelectedBook {
    return self.selectedBook;
    
}
 

- (NSOrderedSet *)getBooksForSelectedCategory {
    return [Book getBooksForCategory:self.selectedCategory inContext:self.libraryDatabase.managedObjectContext];
}

- (NSOrderedSet *)getCategoriesInShop {
    return [Category getAllCategoriesFromContext:self.libraryDatabase.managedObjectContext];
    
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
        
    }
    else if([elementName isEqualToString:@"categorybooks"]) {
        
        NSInteger catID, bookID;
        
        catID = [[attributeDict objectForKey:@"catID"] integerValue];

        bookID = [[attributeDict objectForKey:@"bookID"] integerValue];

        [self.categoryToBookMap pairCategory:catID withBook:bookID];
               
    }
	else if([elementName isEqualToString:@"book"]) {       
        
        //Initialize new picture book
        self.currentBook = [Book bookWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        
	}
    else if([elementName isEqualToString:@"author"]) {
        
        //Initialize new author
        self.currentAuthor = [Author authorWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        
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
    
    if ([elementName isEqualToString:@"book"]) {
        //[self.books addObject:self.pbookInfo];        
        PBDLOG(@"Book info storred!");
        
        self.currentBook = nil;
    }
    else if ([elementName isEqualToString:@"categories"]) {

    }
    else if ([elementName isEqualToString:@"author"]) {        
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

- (void)bookExtractorDidAddPagesToBook:(NSNotification*)pagesAddedNotification 
{
	[self.libraryDatabase.managedObjectContext mergeChangesFromContextDidSaveNotification:pagesAddedNotification];	
}


@end

