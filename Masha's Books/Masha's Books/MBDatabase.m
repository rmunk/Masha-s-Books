//
//  MBDatabase.m
//  Masha's Books
//
//  Created by Luka Miljak on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBDatabase.h"

@interface MBDatabase()
@property (nonatomic, strong) NSURL *urlBase;
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

@implementation MBDatabase

- (MBDatabase *)initMBDatabase {
    self = [super init];
    self.urlBase = [[NSURL alloc] initWithString:@"http://www.mashasbookstore.com/storeops/bookstore-xml.aspx"];
    
    self.currentElementValue = [[NSString alloc] init];
    self.categoryToBookMap = [[CategoryToBookMap alloc] init];
    self.selectedBook = nil;
    
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"dd.mm.yyyy"]; 
    
    self.isShopLoaded = NO;
    self.libraryLoaded = NO;
    
    self.extractor = [[BookExtractor alloc] initExtractorWithShop:self];
    [self refreshShop];
    
    return self;
}

@end
