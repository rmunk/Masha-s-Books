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
    
    self.currentElementValue = [[NSString alloc] init];
    self.categoryToBookMap = [[CategoryToBookMap alloc] init];
    self.selectedBook = nil;
    self.numberOfBooksWhinchNeedCoversDownloaded = 0;
    
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"dd.mm.yyyy"]; 
    
    self.isShopLoaded = NO;
    self.libraryLoaded = NO;
    
    self.extractor = [[BookExtractor alloc] initExtractorWithShop:self];
    [self refreshShop];
    
    
    
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
    PBDLOG_ARG(@"Picturebook shop: Refreshing shop from URL %@", [self.shopURL description]);
    
    //PicturebookCategory *all = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];   

    //[self.categories addObject:all];    // Add "All" category to categories sets
    
    self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.shopURL];
    if (self.xmlParser) 
        PBDLOG_ARG(@"Picturebook shop found at %@", self.shopURL.description);

    [self.xmlParser setDelegate:self];
    
    /*
    BOOL parsingSuccesfull = [self.xmlParser parse];
    
    if (parsingSuccesfull == YES) {
        //self.isShopLoaded = YES;
        //[self shopDataLoaded];
    }
    else {
        [self shopErrorLoading];
    }*/
}

- (void)userSelectsCategoryAtIndex:(NSUInteger)index {

    NSArray *categories = [Category MR_findAllSortedBy:@"name" ascending:YES];
    
    if (categories.count && index < categories.count) {
        self.selectedCategory = [categories objectAtIndex:index];
        self.booksInSelectedCategory = [Book getBooksForCategory:self.selectedCategory];
    } 
    else {
        NSLog(@"ERROR: Index %d out of bounds for user selected category!", index);
    }
}

- (void)userSelectsCategory:(Category *)category {
    self.selectedCategory = category;
    self.booksInSelectedCategory = [Book getBooksForCategory:self.selectedCategory];
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
}

- (NSOrderedSet *)getCategoriesInShop {
    return [Category getAllCategories];
}

- (void)coversLoaded {
    [self shopDataLoaded];
}

- (void)shopDataLoaded {
    self.isShopLoaded = YES;
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
        
        Info *info = [Info MR_findFirst];
        if (!info) info = [Info MR_createEntity];
        
        info.appVer = [attributeDict objectForKey:@"appVer"];

        info.appStoreURL = [attributeDict objectForKey:@"appStoreURL"];

        info.websiteURL = [attributeDict objectForKey:@"websiteURL"];
    
        info.facebookURL = [attributeDict objectForKey:@"facebookURL"];
 
        info.twitterURL = [attributeDict objectForKey:@"twitterURL"];

        info.contactURL = [attributeDict objectForKey:@"contactURL"];
       
    }
    else if([elementName isEqualToString:@"myBooks"]) {
        
        Design *design = [Design MR_findFirst];
        if (!design) design = [Design MR_createEntity];
        
        //NSLog(@"Setting BGImage %@", [attributeDict objectForKey:@"BGImage"]);
        design.bgImageURL = [attributeDict objectForKey:@"BGImage"];
        //NSLog(@"Setting BGMasha %@", [attributeDict objectForKey:@"BGMasha"]);
        design.bgMashaURL = [attributeDict objectForKey:@"BGMasha"];
             
        
        //NSLog(@"Downloading background images at %@ and %@", bacgroundURL, mashaURL);
             
        //designLocal.bgImage = [NSData dataWithContentsOfURL:bacgroundURL];
        //designLocal.bgMasha = [NSData dataWithContentsOfURL:mashaURL];
       
    }
    else if([elementName isEqualToString:@"categories"]) {

        //Initialize new category
        [Category categoryWithAttributes:attributeDict];

    }
    else if([elementName isEqualToString:@"categorybooks"]) {
        
        NSInteger catID, bookID;
        
        catID = [[attributeDict objectForKey:@"catID"] integerValue];

        bookID = [[attributeDict objectForKey:@"bookID"] integerValue];

        [self.categoryToBookMap pairCategory:catID withBook:bookID];
               
    }
	else if([elementName isEqualToString:@"book"]) {       
        
        //Initialize new picture book
        self.currentBook = [Book bookWithAttributes:attributeDict];
        
	}
    else if([elementName isEqualToString:@"author"]) {
        
        //Initialize new author
        //self.currentAuthor = [Author authorWithAttributes:attributeDict forContext:self.libraryDatabase.managedObjectContext];
        self.currentAuthor = [Author authorWithAttributes:attributeDict];
        
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
        PBDLOG(@"Book info storred!");
        
        self.currentBook = nil;
    }
    else if ([elementName isEqualToString:@"info"]) {
        PBDLOG(@"Info storred!");
    }
    else if ([elementName isEqualToString:@"categorybooks"]) {
        PBDLOG(@"Category-book mapping storred!");
    }
    else if ([elementName isEqualToString:@"myBooks"]) {
        PBDLOG(@"Design info storred!");
    }
    else if ([elementName isEqualToString:@"categories"]) {
        PBDLOG(@"Category info storred!");
    }
    else if ([elementName isEqualToString:@"author"]) {        
        self.currentAuthor = nil;
    }
    else if ([elementName isEqualToString:@"bookstore"]) {
       
        NSLog(@"PARSING FINISHED");
        
        
        [Design loadDesignImages];
        
        [Category loadBackgrounds];

        [Book linkBooksToCategoriesWithLinker:self.categoryToBookMap];

        //[Book linkBooksToAuthors];

        [Book loadCoversFromURL:@"http://www.mashasbookstore.com/covers/" forShop:self];
        
    }
}

- (void)pagesAdded
{
    NSLog(@"Extracted book pages saved to database.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookReady" object:self];
    
}

- (void)extractorBook:(Book *)book receivedNewPercentage:(float)percentage {
    self.bookWithLastReportedPercentage = book;
    self.lastPercentage = percentage;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookExtractingError" object:nil];
        
    }
}


@end

