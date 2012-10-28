//
//  MBDatabase.m
//  Masha's Books
//
//  Created by Luka Miljak on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBDatabase.h"
#import "Reachability.h"

@interface MBDatabase()

@property (nonatomic, strong) NSURL *urlBase;
@property (nonatomic, strong) NSXMLParser *xmlParser;

@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong) NSString *currentElementValue;
@property (nonatomic, strong) CategoryToBookMap *categoryToBookMap;
@property (nonatomic, strong) BookExtractor *extractor;
@property (nonatomic, strong) Book *bookWithLastReportedPercentage;
@property (nonatomic, strong) Book *currentBook;
 
@end

@implementation MBDatabase

@synthesize urlBase = _urlBase;
@synthesize xmlParser = _xmlParser;
@synthesize df = _df;
@synthesize currentElementValue = _currentElementValue;
@synthesize categoryToBookMap = _categoryToBookMap;
@synthesize extractor = _extractor;
@synthesize bookWithLastReportedPercentage = _bookWithLastReportedPercentage;
@synthesize currentBook = _currentBook;


#pragma mark - Initialization methods

- (MBDatabase *)initMBD {
    self = [super init];
    self.urlBase = [[NSURL alloc] initWithString:URL_BookstoreXML];
    
    self.currentElementValue = [[NSString alloc] init];
    self.categoryToBookMap = [[CategoryToBookMap alloc] init];
    
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"dd.mm.yyyy"]; 
    
    self.extractor = [[BookExtractor alloc] initExtractorWithShop:self];
    //[self loadMBD];
    
    return self;
}

- (void)loadMBD {
    MBDLOG(@"Picturebook shop: Refreshing shop from URL %@", [self.urlBase description]);
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.mashasbookstore.com"];
    
    if (reachability.currentReachabilityStatus == 0) {
        NSLog(@"Site not available! Network status: %@", reachability.currentReachabilityString);
        [self databaseLoaded];
    }
    else {
        NSLog(@"Site available! Network status: %@", reachability.currentReachabilityString);

        self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.urlBase];
        if (!self.xmlParser) {
            MBDLOG(@"Database not found at %@", self.urlBase.description);
        }
        else {
            MBDLOG(@"Database found at %@", self.urlBase.description);
            [self.xmlParser setDelegate:self];
            
            BOOL parsingSuccesfull = [self.xmlParser parse];
    
            if (parsingSuccesfull == YES) {
                [Design loadDesignImages];
        
                [Category loadBackgrounds];
        
                [Book linkBooksToCategoriesWithLinker:self.categoryToBookMap];
        
                [Book loadCoversFromURL:URL_BookCovers forDatabase:self];
        
            }
            else {
                MBDLOG(@"Error parsing XML from %@", self.urlBase);
            }
        }
    }
}

#pragma mark - Query methods

- (NSOrderedSet *)getCategoriesInDatabase {
    return [Category getAllCategories];
}

- (NSArray *)getBooksInDatabase {
    return [Book getAllBooks];
}

- (NSOrderedSet *)getBooksForCategory:(Category *)category {
    return [Book getBooksForCategory:category];
}

- (NSOrderedSet *)getMyBooks
{
    return [Book getMyBooks];
}

- (NSOrderedSet *)getBoughtBooks
{
    return [Book getBoughtBooks];
}

- (NSOrderedSet *)getDownloadedBooks
{
    NSMutableOrderedSet *downloadedBooks = [[NSMutableOrderedSet alloc] init];
    for (Book *book in [Book getBoughtBooks]) {
        if (book.downloaded != 0) {
            [downloadedBooks addObject:book];
        }
    }
    return [downloadedBooks copy];
}

#pragma mark - Action methods

- (void)userBuysBook:(Book *)book {
    [self.extractor addBookToQue:book];
}

- (void)userDeletesBook:(Book *)book {
    book.status = @"deleting";
    [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext) {
         
         Book *localBook = [book MR_inContext:localContext];
         Image *coverImage = [book.coverImage MR_inContext:localContext];
         NSLog(@"Fetched book %@ to delete", localBook.title);
         for (Page *pageToDelete in localBook.pages) [pageToDelete MR_deleteEntity];
         [coverImage MR_deleteEntity];
         localBook.backgroundMusic = nil;
         localBook.downloaded = 0;
         localBook.status = @"bought";
     }
     completion:^{
//         [[NSManagedObjectContext MR_defaultContext] save:nil];
         [self bookDeleted];
     }
     errorHandler:nil];
}

- (void)cleanup {
    for (Book *book in [Book getAllBooks]) {
        if ([book.status isEqualToString:@"qued"] || [book.status isEqualToString:@"downloading"]) {
            [self.extractor addBookToQue:book];
        }
        else if ([book.status isEqualToString:@"failed"]) {
            book.status = @"ready";
        }
    }
    [self.extractor processQue];
}

#pragma mark - Parser methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
    
    self.currentElementValue = elementName;
    
    if([elementName isEqualToString:@"bookstore"]) {
        
        MBDLOG(@"PARSING STARTED");	
        
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
        
        design.bgImageURL = [attributeDict objectForKey:@"BGImage"];
        design.bgMashaURL = [attributeDict objectForKey:@"BGMasha"];
        
    }
    else if([elementName isEqualToString:@"categories"]) {
        
        // Initialize new category
        [Category categoryWithAttributes:attributeDict];
        
    }
    else if([elementName isEqualToString:@"categorybooks"]) {
        
        // Initialize category-book map
        [self.categoryToBookMap pairCategory:[[attributeDict objectForKey:@"catID"] integerValue] 
                                    withBook:[[attributeDict objectForKey:@"bookID"] integerValue]];
        
    }
	else if([elementName isEqualToString:@"book"]) {       
        
        // Initialize new picture book
        self.currentBook = [Book bookWithAttributes:attributeDict];
        
	} 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
    
    // For current XML format, only elements with character body are DescriptionHTML and DescriptionLongHTML
    [self.currentBook fillBookElement:self.currentElementValue withDescription:string];
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"book"]) {     
        MBDLOG(@"Book info storred!");
        self.currentBook = nil;
    }
    else if ([elementName isEqualToString:@"info"]) {
        MBDLOG(@"Info storred!");
    }
    else if ([elementName isEqualToString:@"categorybooks"]) {
        MBDLOG(@"Category-book mapping storred!");
    }
    else if ([elementName isEqualToString:@"myBooks"]) {
        MBDLOG(@"Design info storred!");
    }
    else if ([elementName isEqualToString:@"categories"]) {
        MBDLOG(@"Category info storred!");
    }
    else if ([elementName isEqualToString:@"bookstore"]) {
        MBDLOG(@"PARSING FINISHED");
    }
}

#pragma mark - Notification methods

- (void)coversLoaded {
    [self databaseLoaded];
}

- (void)databaseLoaded {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DatabaseLoaded" object:self];
}

- (void)pagesAdded {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookReady" object:self];
}

- (void)bookDeleted {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookDeleted" object:self];
}

- (void)extractorBook:(Book *)book receivedNewPercentage:(float)percentage {
    NSNumber *percent = [NSNumber numberWithFloat:percentage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookDataReceived" object:percent];
}

- (void)extractorForBook:(Book *)book didFinishExtractingWithSuccess:(BOOL)success {
    if (success == YES) 
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookExtracted" object:nil];
    else 
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookExtractingError" object:nil];
}

- (void)extractorForBook:(Book *)book didFinishDownloadingWithSuccess:(BOOL)success {
    
    if (success == YES)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookDownloaded" object:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookDownloadError" object:nil];
}


@end
