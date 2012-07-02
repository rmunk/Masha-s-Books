//
//  BookExtractor.h
//  Masha's Books
//
//  Created by Ranko Munk on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"
#import "Book.h"
#import "Page.h"
#import "Image.h"
#import <CoreData/CoreData.h>

@class BookExtractor;

@protocol BookExtractorDelegate
- (void)bookExtractor:(BookExtractor *)extractor didFinishExtractinWithgSuccess:(BOOL)success;
@end

@interface BookExtractor : NSObject

@property Book *book;
@property id<BookExtractorDelegate> delegate;

- (void)extractBook:(Book *)book FromFile:(NSString *)zipFile;

@end
