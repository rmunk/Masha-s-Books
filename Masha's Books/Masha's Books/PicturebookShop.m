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
@property (nonatomic, strong) NSString *currentBookElement;
@property (nonatomic, strong) NSString *currentAuthorElement;

@end

@implementation PicturebookShop

@synthesize urlBase = _urlBase;
@synthesize books = _books;
@synthesize categories = _categories;
@synthesize authors = _authors;

@synthesize shopURL = _shopURL;
@synthesize xmlParser = _xmlParser;
@synthesize pbookInfo = _pbookInfo;
@synthesize pbookCategory = _pbookCategory;
@synthesize pbookAuthor = _pbookAuthor;
@synthesize df = _df;
@synthesize currentElementValue = _currentElementValue;
@synthesize currentBookElement = _currentBookElement;
@synthesize currentAuthorElement = _currentAuthorElement;

@synthesize isShopLoaded = _isShopLoaded;


- (PicturebookShop *)initShop {
    self = [super init];
    _shopURL = [[NSURL alloc] initWithString:@"http://www.mashasbooks.com/storeops/bookstore-xml.aspx"];
    //_shopURL = [[NSURL alloc] initWithString:@"http://dl.dropbox.com/u/286270/PicturebookShop.xml"];
    
    _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.shopURL];
    if (_xmlParser) {
        PBDLOG_ARG(@"Picturebook shop found at %@", _shopURL.description);
    }
    [_xmlParser setDelegate:self];
    
    _categories = [[NSMutableOrderedSet alloc] init];
    _books = [[NSMutableOrderedSet alloc] init];
    _authors = [[NSMutableOrderedSet alloc] init];
    
    _currentElementValue = [[NSString alloc] init];
    _currentBookElement = [[NSString alloc] init];
    _currentAuthorElement = [[NSString alloc] init];
    
    _df = [[NSDateFormatter alloc] init];
    [_df setDateFormat:@"dd.mm.yyyy"]; 
    
    _isShopLoaded = NO;
    
    return self;
}

- (void)refreshShop {
    PBDLOG_ARG(@"Picturebook shop: Refreshing shop from URL %@", [self.shopURL description]);
    
    [self.categories removeAllObjects];
    PicturebookCategory *all = [[PicturebookCategory alloc] initWithName:@"All" AndID:0];

    [self.categories addObject:all];
 
    [self.books removeAllObjects];
    
    [self.authors removeAllObjects];
    
    BOOL parsingSuccesfulll = [self.xmlParser parse];
    
    if (parsingSuccesfulll == YES) 
    {
        [self populateStoreWithImages];
        self.isShopLoaded = YES;
        [self shopDataLoaded];
        
    }
    else {
        [self shopErrorLoading];
    }
}

// Populating PicturebookInfo instances with cover images
- (void)populateStoreWithImages {
    for (PicturebookInfo *pbInfo in self.books) {
        if ([pbInfo isKindOfClass:[PicturebookInfo class]]) {
            /*
             NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:                                                                                 [NSString stringWithFormat:@"%@%d%@",                                                                                   @"http://www.mashasbooks.com/covers/", pbInfo.iD, @"_t.jpg"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            [req setHTTPMethod:@"GET"];
            // Set headers etc. if you need
            NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:req delegate:self];           
            
            self.responseData = [[NSMutableData alloc] init]; 
             */
            
            NSURL *coverURL = [[NSURL alloc] initWithString:
                               [NSString stringWithFormat:@"%@%d%@", 
                                @"http://www.mashasbooks.com/covers/", pbInfo.iD, @"_t.jpg"]]; 
            PBDLOG_ARG(@"Downloading cover image for book %@", pbInfo.title);
            // Get an image from the URL below
            UIImage *coverImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:coverURL]];
            if (coverImage) {
                PBDLOG(@"Image downloaded!");
            }
            pbInfo.coverImage = coverImage;
        }
    }    
}

- (NSOrderedSet *)getBooksForCategory:(PicturebookCategory *)pbCategory {
    NSMutableOrderedSet *booksForCategory = [[NSMutableOrderedSet alloc] init];
    
    if (pbCategory.name == @"All") {
        return [self.books copy];
    }
    else {
        for (PicturebookInfo *pbInfo in self.books) {
            if (pbInfo.catID == pbCategory.iD) {
                [booksForCategory addObject:pbInfo];    
            }
        }
        return [booksForCategory copy];
    }
}

- (NSOrderedSet *)getBooksForCategoryName:(NSString *)name {
    NSMutableOrderedSet *booksForCategory = [[NSMutableOrderedSet alloc] init];
    PicturebookCategory *pbCategory = [[PicturebookCategory alloc] init];
    
    for (PicturebookCategory *pbCat in self.categories) {
        if (pbCat.name == name) {
            pbCategory = pbCat;    
        }
    }
    
    if (name == @"All") {
        return [self.books copy];
    }
    else {
        for (PicturebookInfo *pbInfo in self.books) {
            if (pbInfo.catID == pbCategory.iD) {
                [booksForCategory addObject:pbInfo];    
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
		//Initialize the array.
		
	}
    else if([elementName isEqualToString:@"categories"]) {
        
        //Initialize new book category
        self.pbookCategory = [[PicturebookCategory alloc] init];
        PBDLOG(@"\n");
        PBDLOG(@"New book category found!");
        
        //Extract category attributes from XML
        self.pbookCategory.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        PBDLOG_ARG(@"Category ID: %i", self.pbookCategory.iD);
        
        self.pbookCategory.name = [attributeDict objectForKey:@"Name"];
        PBDLOG_ARG(@"Category name: %@", self.pbookCategory.name);        
        
    }
	else if([elementName isEqualToString:@"book"]) {
        
        
        
        //Initialize new picture book
        self.pbookInfo = [[PicturebookInfo alloc] init];
        PBDLOG(@"\n");
        PBDLOG(@"New book found!");
		
		//Extract the picture book attributes from XML
        self.pbookInfo.catID = [[attributeDict objectForKey:@"catID"] integerValue];
        PBDLOG_ARG(@"Category ID: %i", self.pbookInfo.catID);
        
        self.pbookInfo.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        PBDLOG_ARG(@"Book ID: %i", self.pbookInfo.iD);
        
        self.pbookInfo.title = [attributeDict objectForKey:@"Title"];
        self.currentBookElement = self.pbookInfo.title;
        PBDLOG_ARG(@"Book title: %@", self.pbookInfo.title);
        
        self.pbookInfo.authorID = [[attributeDict objectForKey:@"AppleStoreID"] integerValue];
        PBDLOG_ARG(@"Applestore ID:%i", self.pbookInfo.appStoreID);
        
        self.pbookInfo.authorID = [[attributeDict objectForKey:@"AuthorID"] integerValue];
        PBDLOG_ARG(@"Author ID:%i", self.pbookInfo.authorID);
        
        self.pbookInfo.publishDate = [self.df dateFromString:[attributeDict objectForKey:@"PublishDate"]];
        PBDLOG_ARG(@"Publish date:%@", self.pbookInfo.publishDate.description);
        
        self.pbookInfo.downloadUrl = [NSURL URLWithString:[attributeDict objectForKey:@"DownloadURL"]];
        PBDLOG_ARG(@"Download URL:%@", self.pbookInfo.downloadUrl.description);
        
        self.pbookInfo.facebookLikeUrl = [NSURL URLWithString:[attributeDict objectForKey:@"FacebookLikeURL"]];
        PBDLOG_ARG(@"Facebook URL:%@", self.pbookInfo.facebookLikeUrl.description);
        
        self.pbookInfo.youTubeVideoUrl = [NSURL URLWithString:[attributeDict objectForKey:@"YouTubeVideoURL"]];
        PBDLOG_ARG(@"YouTube video URL:%@", self.pbookInfo.youTubeVideoUrl.description);
        
	}
    else if([elementName isEqualToString:@"author"]) {
        
        //Initialize new author
        self.pbookAuthor = [[PicturebookAuthor alloc] init];
        PBDLOG(@"\n");
        PBDLOG(@"New author found!");
        
        //Extract the author attributes from XML
        self.pbookAuthor.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        PBDLOG_ARG(@"Author ID: %i", self.pbookInfo.iD);
        
        self.pbookAuthor.name = [attributeDict objectForKey:@"Name"];
        self.currentAuthorElement = self.pbookAuthor.name;
        PBDLOG_ARG(@"Author name: %@", self.pbookAuthor.name);
                
        self.pbookAuthor.websiteUrl = [NSURL URLWithString:[attributeDict objectForKey:@"AuthorWebsiteURL"]];
        PBDLOG_ARG(@"Author website:%@", self.pbookAuthor.websiteUrl.description);
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
    
    if ([self.currentElementValue isEqualToString:@"DescriptionHTML"]) {
        self.pbookInfo.descriptionHTML = string;
        PBDLOG_ARG(@"For book %@", self.currentBookElement);    
        PBDLOG_ARG(@"DescriptionHTML %@", string);
    }
    else if ([self.currentElementValue isEqualToString:@"DescriptionLongHTML"]) {
        self.pbookInfo.descriptionLongHTML = string;
        PBDLOG_ARG(@"For book %@", self.currentBookElement);    
        PBDLOG_ARG(@"DescriptionLongHTML %@", string);
    }
    else if ([self.currentElementValue isEqualToString:@"AuthorBioHTML"]) {
        self.pbookAuthor.bioHtml = string;
        PBDLOG_ARG(@"For author %@", self.currentAuthorElement);    
        PBDLOG_ARG(@"AuthorBioHTML %@", string);
    }
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"book"] && ![self.books containsObject:self.pbookInfo]) {
        [self.books addObject:self.pbookInfo];
        PBDLOG(@"Book info storred!");
    }
    else if ([elementName isEqualToString:@"categories"] && ![self.categories containsObject:self.pbookCategory]) {
        [self.categories addObject:self.pbookCategory];
        PBDLOG(@"Category info storred!");
    }
    else if ([elementName isEqualToString:@"author"]) {
        [self.authors addObject:self.pbookAuthor];
        PBDLOG(@"Author info storred!");
    }
}


@end

