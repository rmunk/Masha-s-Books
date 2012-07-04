//
//  BookExtractor.h
//  Masha's Books
//
//  Created by Ranko Munk on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"
#import "Book+XcodeBugFix.h"
#import "Page.h"
#import "Image.h"
#import <CoreData/CoreData.h>

@class BookExtractor;

@protocol BookExtractorDelegate
- (void)bookExtractor:(BookExtractor *)extractor didFinishExtractinWithgSuccess:(BOOL)success;
@end

@interface BookExtractor : NSObject

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) id<BookExtractorDelegate> delegate;

- (void)extractBookFromFile:(NSString *)zipFile;

@end
