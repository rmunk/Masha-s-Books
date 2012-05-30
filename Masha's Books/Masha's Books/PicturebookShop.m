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
@synthesize isShopLoaded = _isShopLoaded;


- (PicturebookShop *)initShop {
    self = [super init];
    _shopURL = [[NSURL alloc] initWithString:@"http://www.mashasbooks.com/storeops/bookstore-xml.aspx"];
    //_shopURL = [[NSURL alloc] initWithString:@"http://dl.dropbox.com/u/286270/PicturebookShop.xml"];
    
    _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.shopURL];
    if (_xmlParser) {
        NSLog(@"Picturebook shop found at %@", _shopURL.description);
    }
    [_xmlParser setDelegate:self];
    
    _categories = [[NSMutableOrderedSet alloc] init];
    _books = [[NSMutableOrderedSet alloc] init];
    _authors = [[NSMutableOrderedSet alloc] init];
    
    _df = [[NSDateFormatter alloc] init];
    [_df setDateFormat:@"dd.mm.yyyy"]; 
    
    _isShopLoaded = NO;
    
    return self;
}

- (void)refreshShop {
    NSLog(@"Picturebook shop: Refreshing shop from URL %@", [self.shopURL description]);
    
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
            //NSLog([NSString stringWithFormat:@"%@%d%@", 
            //       @"http://www.mashasbooks.com/covers/", pbInfo.iD, @".jpg"]);
            
            NSURL *coverURL = [[NSURL alloc] initWithString:
                               [NSString stringWithFormat:@"%@%d%@", 
                                @"http://www.mashasbooks.com/covers/", pbInfo.iD, @"_t.jpg"]]; 
            NSLog(@"Downloading cover image for book %@", pbInfo.title);
            // Get an image from the URL below
            UIImage *coverImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:coverURL]];
            if (coverImage) {
                NSLog(@"Image downloaded!");
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
    //NSLog(@"Parser has found element %@", elementName);
    
    if([elementName isEqualToString:@"bookstore"]) {
		//Initialize the array.
		
	}
    else if([elementName isEqualToString:@"categories"]) {
        
        //Initialize new book category
        self.pbookCategory = [[PicturebookCategory alloc] init];
        NSLog(@"New book category found!");
        
        //Extract category attributes from XML
        self.pbookCategory.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        NSLog(@"Category ID: %i", self.pbookCategory.iD);
        
        self.pbookCategory.name = [attributeDict objectForKey:@"Name"];
        NSLog(@"Category name: %@", self.pbookCategory.name);
        
        
    }
	else if([elementName isEqualToString:@"book"]) {
        
        //Initialize new picture book
        self.pbookInfo = [[PicturebookInfo alloc] init];
        NSLog(@"New book found!");
		
		//Extract the picture book attributes from XML
        self.pbookInfo.catID = [[attributeDict objectForKey:@"catID"] integerValue];
        NSLog(@"Category ID: %i", self.pbookInfo.catID);
        
        self.pbookInfo.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        NSLog(@"Book ID: %i", self.pbookInfo.iD);
        
        self.pbookInfo.title = [attributeDict objectForKey:@"Title"];
        NSLog(@"Book title: %@", self.pbookInfo.title);
        
        self.pbookInfo.authorID = [[attributeDict objectForKey:@"AppleStoreID"] integerValue];
        NSLog(@"Applestore ID:%i", self.pbookInfo.appStoreID);
        
        self.pbookInfo.authorID = [[attributeDict objectForKey:@"AuthorID"] integerValue];
        NSLog(@"Author ID:%i", self.pbookInfo.authorID);
        
        self.pbookInfo.publishDate = [self.df dateFromString:[attributeDict objectForKey:@"PublishDate"]];
        NSLog(@"Publish date:%@", self.pbookInfo.publishDate.description);
        
        self.pbookInfo.downloadUrl = [NSURL URLWithString:[attributeDict objectForKey:@"DownloadURL"]];
        NSLog(@"Download URL:%@", self.pbookInfo.downloadUrl.description);
        
        self.pbookInfo.facebookLikeUrl = [NSURL URLWithString:[attributeDict objectForKey:@"FacebookLikeURL"]];
        NSLog(@"Facebook URL:%@", self.pbookInfo.facebookLikeUrl.description);
        
        self.pbookInfo.youTubeVideoUrl = [NSURL URLWithString:[attributeDict objectForKey:@"YouTubeVideoURL"]];
        NSLog(@"YouTube video URL:%@", self.pbookInfo.youTubeVideoUrl.description);
	}
    else if([elementName isEqualToString:@"author"]) {
        
        //Initialize new author
        self.pbookAuthor = [[PicturebookAuthor alloc] init];
        NSLog(@"New author found!");
        
        //Extract the author attributes from XML
        self.pbookAuthor.iD = [[attributeDict objectForKey:@"ID"] integerValue];
        NSLog(@"Author ID: %i", self.pbookInfo.iD);
        
        self.pbookAuthor.name = [attributeDict objectForKey:@"Name"];
        NSLog(@"Author name: %@", self.pbookAuthor.name);
                
        self.pbookAuthor.websiteUrl = [NSURL URLWithString:[attributeDict objectForKey:@"AuthorWebsiteURL"]];
        NSLog(@"Author website:%@", self.pbookAuthor.websiteUrl.description);
    }    
    else if([elementName isEqualToString:@"DescriptionHTML"]) {
        return;
    }
    else if([elementName isEqualToString:@"DescriptionLongHTML"]) {
        return;
    }
    else {
        return;
    }
        
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
    //NSLog(@"Parser has found string %@", string);
    
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"book"] && ![self.books containsObject:self.pbookInfo]) {
        [self.books addObject:self.pbookInfo];
        NSLog(@"Book info storred!");
    }
    else if ([elementName isEqualToString:@"categories"] && ![self.categories containsObject:self.pbookCategory]) {
        [self.categories addObject:self.pbookCategory];
        NSLog(@"Category info storred!");
    }
    else if ([elementName isEqualToString:@"author"]) {
        [self.authors addObject:self.pbookAuthor];
        NSLog(@"Author info storred!");
    }
    //NSLog(@"Parser has found element %@", elementName);
	
}


@end

