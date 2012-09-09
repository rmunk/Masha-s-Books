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
#import "Book.h"
#import "Book+Addon.h"
#import "UIImage+Resize.h"
//#import "PicturebookShop.h"
#import <CoreData/CoreData.h>



@protocol BookExtractorDelegate <NSObject>
- (void)extractorBook:(Book *)book receivedNewPercentage:(float)percentage;
@optional
- (void)extractorForBook:(Book *)book didFinishExtractingWithSuccess:(BOOL)success;

@end

@class BookExtractor;
@class PicturebookShop;



@interface BookExtractor : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) id<BookExtractorDelegate> delegate;
@property long long expectedZipSize;
@property (nonatomic, strong) NSMutableData *downloadedZipData;
@property BOOL downloading;
//- (BookExtractor *)initExtractorWithUrl:(NSURL *)zipURL;
- (BookExtractor *)initExtractorWithShop:(id)shop andContext:(NSManagedObjectContext *)context;
- (void)extractBookFromFile:(NSString *)zipFile;
- (BOOL)isDownloading;
- (NSData *)getDownloadedData;
- (void)addBookToQue:(Book *)book;
- (void)processQue;

@end
