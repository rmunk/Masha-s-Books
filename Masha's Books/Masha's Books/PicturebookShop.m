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
@property (nonatomic, strong) NSOrderedSet *booksInSelectedCategory;
@property (nonatomic, strong) BookExtractor *extractor;


@property (nonatomic, strong) Book *bookWithLastReportedPercentage;



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
@synthesize bookWithLastReportedPercentage = _bookWithLastReportedPercentage;
@synthesize lastPercentage = _lastPercentage;
@synthesize extractor = _extractor;

@synthesize isShopLoaded = _isShopLoaded;
@synthesize libraryLoaded = _libraryLoaded;
@synthesize booksInSelectedCategory = _booksInSelectedCategory;


- (PicturebookShop *)initShop {
    self = [super init];
    self.shopURL = [[NSURL alloc] initWithString:@"http://www.mashasbookstore.com/storeops/bookstore-xml.aspx"];
    //_shopURL = [[NSURL alloc] initWithString:@"http://dl.dropbox.com/u/286270/PicturebookShop.xml"];
    
    
    
    // Init library database UIManagedDocument
    if (!self.libraryDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Library"];
        self.libraryDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    self.currentElementValue = [[NSString alloc] init];
    self.categoryToBookMap = [[CategoryToBookMap alloc] init];
    self.selectedBook = nil;
    self.numberOfBooksWhinchNeedCoversDownloaded = 0;
    
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"dd.mm.yyyy"]; 
    
    self.isShopLoaded = NO;
    self.libraryLoaded = NO;
    
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:self.libraryDatabase.managedObjectContext];
    
    return self;
}

//- (void)contextSaved:(NSNotification *) notification {
//    NSLog(@"SaveThread reports context saved");
//    [self.libraryDatabase.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
//}

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
        //[self loadShopFromDatabase];
        //self.isShopLoaded = YES;
        self.libraryLoaded = YES;
        self.extractor = [[BookExtractor alloc] initExtractorWithShop:self andContext:self.libraryDatabase.managedObjectContext];
        [self refreshShop];
        //[self shopDataLoaded];
    }
}

- (void)setLibraryDatabase:(UIManagedDocument *)libraryDatabase
{
    if (_libraryDatabase != libraryDatabase) {
        _libraryDatabase = libraryDatabase;
        [self useDocument];
    }
}

- (void)userBuysBook:(Book *)book {
    [self.extractor addBookToQue:book];
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
    if (self.libraryLoaded == YES) {    
        PBDLOG_ARG(@"Picturebook shop: Refreshing shop from URL %@", [self.shopURL description]);
    
        //PicturebookCategory *all = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];   

        //[self.categories addObject:all];    // Add "All" category to categories sets
     
        self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.shopURL];
        if (self.xmlParser) {
            PBDLOG_ARG(@"Picturebook shop found at %@", self.shopURL.description);
        }
        [self.xmlParser setDelegate:self];
    
        BOOL parsingSuccesfull = [self.xmlParser parse];
    
        if (parsingSuccesfull == YES) {
            //self.isShopLoaded = YES;
            //[self shopDataLoaded];
        }
        else {
            [self shopErrorLoading];
        }
    }
    else {
        NSLog(@"Library not loaded. Refresh will be called from useDocument funcion");
    }

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
        self.booksInSelectedCategory = [Book getBooksForCategory:self.selectedCategory inContext:self.libraryDatabase.managedObjectContext];
        NSLog(@"User selects category %@", self.selectedCategory.name);
    } 
    else {
        NSLog(@"ERROR: Index %d out of bounds for user selected category!", index);
    }
}

- (void)userSelectsCategory:(Category *)category {
    self.selectedCategory = category;
    self.booksInSelectedCategory = [Book getBooksForCategory:self.selectedCategory inContext:self.libraryDatabase.managedObjectContext];
    NSLog(@"User selects category %@", self.selectedCategory.name);
   
}

- (void)userSelectsBook:(Book *)book {
    self.selectedBook = book;
}

- (Book *)getSelectedBook {
    return self.selectedBook;
}

- (Category *)getSelectedCategory {
    return  self.selectedCategory;
}
 

- (NSOrderedSet *)getBooksForSelectedCategory {
    return self.booksInSelectedCategory;
    //return [Book getBooksForCategory:self.selectedCategory inContext:self.libraryDatabase.managedObjectContext];
}

- (NSOrderedSet *)getCategoriesInShop {
    return [Category getAllCategoriesFromContext:self.libraryDatabase.managedObjectContext];
    
}

- (void)coversLoaded {
    // save database
    
    [self.libraryDatabase saveToURL:self.libraryDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Library database saved!");  
            [self shopDataLoaded];
        }
    }];
    
}

- (void)shopDataLoaded {
    NSLog(@"Persistent store size: %llu bytes", [self directorySizeAtPath:[self.libraryDatabase.fileURL path]]);
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
    else if([elementName isEqualToString:@"info"]) {
       // 
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Info"]; 
        NSError *error;
        Info *info;
        
        NSArray *infoArray = [self.libraryDatabase.managedObjectContext executeFetchRequest:request error:&error];
        if (infoArray.count == 0) {
            info = [NSEntityDescription insertNewObjectForEntityForName:@"Info" inManagedObjectContext:self.libraryDatabase.managedObjectContext];
        }
        else if (infoArray.count == 1) {
            info = [infoArray lastObject];
        }
        else {
            NSLog(@"ERROR: More than one Info managed object in database");
            return;
        }
        
        NSLog(@"Storing info");
        NSLog(@"%@", [attributeDict objectForKey:@"appVer"]);
        info.appVer = [attributeDict objectForKey:@"appVer"];
        NSLog(@"%@", [attributeDict objectForKey:@"appStoreURL"]);
        info.appStoreURL = [attributeDict objectForKey:@"appStoreURL"];
        NSLog(@"%@", [attributeDict objectForKey:@"websiteURL"]);
        info.websiteURL = [attributeDict objectForKey:@"websiteURL"];
        NSLog(@"%@", [attributeDict objectForKey:@"facebookURL"]);
        info.facebookURL = [attributeDict objectForKey:@"facebookURL"];
        NSLog(@"%@", [attributeDict objectForKey:@"twitterURL"]);
        info.twitterURL = [attributeDict objectForKey:@"twitterURL"];
        NSLog(@"%@", [attributeDict objectForKey:@"contactURL"]);
        info.contactURL = [attributeDict objectForKey:@"contactURL"];
       
        
    }
    else if([elementName isEqualToString:@"myBooks"]) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Design"]; 
        NSError *error;
        Design *design;
        
        NSArray *infoArray = [self.libraryDatabase.managedObjectContext executeFetchRequest:request error:&error];
        if (infoArray.count == 0) {
            design = [NSEntityDescription insertNewObjectForEntityForName:@"Design" inManagedObjectContext:self.libraryDatabase.managedObjectContext];
        }
        else if (infoArray.count == 1) {
            design = [infoArray lastObject];
        }
        else {
            NSLog(@"ERROR: More than one Info managed object in database");
            return;
        }
        
        NSLog(@"Setting BGImage %@", [attributeDict objectForKey:@"BGImage"]);
        design.bgImageURL = [attributeDict objectForKey:@"BGImage"];
        NSLog(@"Setting BGMasha %@", [attributeDict objectForKey:@"BGMasha"]);
        design.bgMashaURL = [attributeDict objectForKey:@"BGMasha"];
        
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
    else if([elementName isEqualToString:@"Description"]) {
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
        [Design loadImages:self.libraryDatabase.managedObjectContext];
        [Category loadBackgroundsForContext:self.libraryDatabase.managedObjectContext];
        [Book linkBooksToCategoriesWithLinker:self.categoryToBookMap inContext:self.libraryDatabase.managedObjectContext];
        [Book linkBooksToAuthorsInContext:self.libraryDatabase.managedObjectContext];
        // fillBookWithCovers
        [Book loadCoversFromURL:@"http://www.mashasbookstore.com/covers/" forShop:self];
        NSLog(@"Books covers downloaded!");
        self.isShopLoaded = YES;

        
        
        
        
        //NSLog(@"Persistent store size: %llu bytes", [self directorySizeAtPath:[self.libraryDatabase.fileURL path]]);
        
        
        
        
        
    }
}

- (void)pagesAdded
{
	//[self.libraryDatabase.managedObjectContext mergeChangesFromContextDidSaveNotification:pagesAddedNotification];
    NSLog(@"Extracted book pages saved to database.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookReady" object:self];
     
    
}



- (void)extractorBook:(Book *)book receivedNewPercentage:(float)percentage {
    self.bookWithLastReportedPercentage = book;
    self.lastPercentage = percentage;
//    NSLog(@"Shop: Book %f", percentage);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopReceivedZipData" object:self];
    if (book == self.selectedBook) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewShopReceivedZipData" object:self];
    }
    
}

- (void)extractorForBook:(Book *)book didFinishExtractingWithSuccess:(BOOL)success {
    if (success == YES) {
        NSLog(@"Shop: Book %@ extracted", book.title);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookExtracted" object:nil];
    } else {
        NSLog(@"Shop: Book %@ extracting error", book.title);
        [[[UIAlertView alloc] initWithTitle:@"Download Error" message:@"There was an error downloading book. Please try again." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] show];
    }
}

- (void)refreshCovers:(NSArray *)covers {
    for (PicturebookCover *cover in covers) {
        if (cover.bookForCover.bookID != nil && self.bookWithLastReportedPercentage.bookID != nil) {
            if ([cover.bookForCover.bookID isEqualToNumber:self.bookWithLastReportedPercentage.bookID]) {
                
                cover.taskProgress.alpha = 1;
                cover.taskProgress.progress = self.lastPercentage;
                //NSLog(@"Shop: Book %f", lastPercentage);
                if (cover.taskProgress.progress == 0) {
                    cover.taskProgress.alpha = 1;
                    cover.bookStatus.alpha = 0;
                
                }
                else if (cover.taskProgress.progress == 1) {
                    cover.taskProgress.alpha = 0;
                    cover.bookStatus.alpha = 1;
                }
            }
        }
    }
}

@end

