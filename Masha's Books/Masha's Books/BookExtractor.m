//
//  BookExtractor.m
//  Masha's Books
//
//  Created by Ranko Munk on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BookExtractor.h"

@interface BookExtractor()<SSZipArchiveDelegate>
@property BOOL success;
@property (nonatomic, strong) NSURLRequest *downloadRequest;
@property (nonatomic, strong) NSURLConnection *downloadConnection;
@property (nonatomic, strong) NSMutableOrderedSet *bookQue;
@property (nonatomic, strong) Book *activeBook;
@property (nonatomic, strong) NSString *file;

//- (void)saveDataToBook:(Book *)book FromPath:(NSString *)unzippedPath;
@end

@implementation BookExtractor
@synthesize delegate = _delegate;
@synthesize book = _book;
@synthesize success = _success;
@synthesize downloadRequest = _downloadRequest;
@synthesize downloadConnection = _downloadConnection;
@synthesize bookQue = _bookQue;
@synthesize activeBook = _activeBook;
@synthesize file = _file;

@synthesize downloading = _downloading;

@synthesize expectedZipSize = _expectedZipSize;
@synthesize downloadedZipData = _downloadedZipData;

- (BookExtractor *)initExtractorWithShop:(id)shop {
    self = [super init];
    if (self) {
        self.bookQue = [[NSMutableOrderedSet alloc] init];
        self.delegate = shop;
        self.downloading = NO;
        self.activeBook = nil;
    }
    return self;
}

- (BookExtractor *)initExtractorWithDatabase:(id)database {
    self = [super init];
    if (self) {
        self.bookQue = [[NSMutableOrderedSet alloc] init];
        self.delegate = database;
        self.downloading = NO;
        self.activeBook = nil;
    }
    return self;
}

- (void)extractBookFromFile:(NSString *)zipFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *newDir = [tmpFolder stringByAppendingPathComponent:[zipFile.lastPathComponent stringByDeletingPathExtension]];
    
    if ([fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
    {
        NSLog(@"Failed to create directory");
        //self.success = NO;
        [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:NO];
        return;
    }
    
    self.activeBook.status = @"extracting";
    
    dispatch_queue_t zipQueue = dispatch_queue_create("zipQueue", NULL);
    dispatch_async(zipQueue, ^{
        
        // Extract zip file to tmp folder
        NSLog(@"Extracting %@ Started...", zipFile.lastPathComponent);
        NSError *error;
        self.success = [SSZipArchive unzipFileAtPath:zipFile toDestination:newDir error:&error delegate:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ((self.success == NO) && [self.delegate respondsToSelector:@selector(extractorForBook:didFinishExtractingWithSuccess:)]) {
                [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:self.success];
                [self.downloadedZipData setLength:0];
                self.activeBook.status = @"failed";
                [self processQue];
                return;
            }
            else {                
                NSLog(@"Extracting %@ Done!", zipFile.lastPathComponent);
                [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:YES];
    
                [self saveDataToBook:self.activeBook FromPath:newDir];
            }
        });
    });
    dispatch_release(zipQueue);
}

- (void)saveDataToBook:(Book *)bookFromMainThread FromPath:(NSString *)unzippedPath {
    
    [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSError *error;
        
        Book *book = [bookFromMainThread MR_inContext:localContext];
        NSLog(@"Fetched book %@ with objectID", book.title);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:unzippedPath error:&error];
        if (error) {
            NSLog(@"Error reading %@ (%@)!", unzippedPath.lastPathComponent, error.description);
            //self.success = NO;
        }
        else
        {
            for (Page *pageToDelete in book.pages) {
                [localContext deleteObject:pageToDelete];
            }
            
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];
            NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:filter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            if (!book.coverImage){
                Image *coverImage = [Image MR_createInContext:localContext];
                coverImage.image = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                book.coverImage = coverImage;
            }
            else
                book.coverImage.image = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
            
            book.backgroundMusic = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:@"music.m4a"]];
            
            float size = 0;
            for (NSString *file in dirContents)
                size += [[fileManager attributesOfItemAtPath:[unzippedPath stringByAppendingFormat:@"/%@", file] error:nil] fileSize];
            book.size = [NSNumber numberWithFloat:size / 1048576];
            
            // Insert title page first
            Page *page = [Page createInContext:localContext];
            page.pageNumber = [NSNumber numberWithInt:0];
            page.image = book.coverImage.image;
            [book insertObject:page inPagesAtIndex:0];
            
            int pageNumber = 1;
            for (NSString *pageFile in pageFiles) {
                Page *page = [Page createInContext:localContext];
                page.pageNumber = [NSNumber numberWithInt:pageNumber];
                page.image = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:pageFile]];
                //page.thumbnail = [page.image resizedImage:CGSizeMake(138, 103) interpolationQuality:kCGInterpolationHigh];
                page.text = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/text%03d.png",pageNumber]];
                page.voiceOver = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/voice%03d.m4a",pageNumber]];
                page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d.m4a",pageNumber]];
                if(!page.sound){
                    page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d_L.m4a",pageNumber]];
                    if(page.sound) page.soundLoop = [NSNumber numberWithBool:TRUE];
                }
                [book insertObject:page inPagesAtIndex:pageNumber];
                pageNumber++;
            }
            
            NSLog(@"book.title %@", book.title);
            NSLog(@"book.downloadDate old:%@ new:%@", book.downloadDate.description, [[NSDate date] description]);
            book.downloadDate = [NSDate date];
            NSLog(@"book.downloaded old:%@ new:%@", [book.downloaded stringValue], [[NSNumber numberWithInt:1] stringValue]);
            book.downloaded = [NSNumber numberWithInt:1];
            NSLog(@"book.status old:%@ new:%@", book.status, @"ready");
            book.status = @"ready";
        }
    }
    completion:^{
        [[NSManagedObjectContext MR_defaultContext] save:nil];
        [self.delegate performSelector:@selector(pagesAdded)];
        [self processQue];
    }
    errorHandler:nil];
}


- (void)downloadZipFileForBook:(Book *)book
{
    NSLog(@"Download request for book %@ at %@", book.title, [NSString stringWithFormat:@"http://www.mashasbookstore.com%@",book.downloadURL]);
    self.downloadRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.mashasbookstore.com%@",book.downloadURL]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSLog(@"Download request %@", self.downloadRequest.description);
    
    if ([self.downloadRequest.description isEqualToString:@"<NSURLRequest (null)>"]) {
        self.activeBook.status = @"failed";
        [self processQue];
        return;
    }
    
    self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];
    if (self.downloadConnection) {
        NSLog(@"Downloading zip file for book %@ through connection %@.", book.title, self.downloadConnection.description);
        self.downloading = YES;
        
    }
    else {
        NSLog(@"Could not start download of %@.", book.title);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedZipData appendData:data];
    if (self.expectedZipSize != 0) {
        float percentage = (float)[self.downloadedZipData length]/(float)self.expectedZipSize;
        [self.delegate extractorBook:self.activeBook receivedNewPercentage:percentage];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedZipSize = [response expectedContentLength];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self.delegate extractorBook:self.activeBook receivedNewPercentage:1];
    
    NSLog(@"Data download finished for book %@", self.activeBook.title);
    self.downloading = NO;
    self.file = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",self.activeBook.downloadURL.lastPathComponent]];
    NSLog(@"Saving zip file...");
    NSData *zipFile = [NSData dataWithData:self.downloadedZipData];
    [zipFile writeToFile:self.file atomically:YES];
    NSLog(@"Zip file saved.");
    
    [self extractBookFromFile:self.file];
}

- (BOOL)isDownloading {
    return self.downloading;
}

- (NSData *)getDownloadedData {
    return [self.downloadedZipData copy];
}

- (void)processBook:(Book *)book {
    book.status = @"downloading";
    [self downloadZipFileForBook:book];
    
}

// State machine processQue
- (void)processQue {
    NSLog(@"Processing que");
    // NSLog(@"Active book info: %@", self.activeBook);
    // remove processed books
    Book *bookToDelete;
    int flag = 1;
    while (1) {
        if (!flag)
            break;
        
        flag = 0;
        
        for (Book *book in self.bookQue) {
            if (book.status == @"ready") {
                NSLog(@"Book %@ is ready", book.title);
                bookToDelete = book;
                flag = 1;
            }
            else if (book.status == @"failed") {
                NSLog(@"Book %@ failed", book.title);
                //book.status = [NSString stringWithString:@"available"];
                bookToDelete = book;
                flag = 1;
            }
        }
        if(flag) {
            NSLog(@"Removing book %@ with status %@ from que", bookToDelete.title, bookToDelete.status);
            [self.bookQue removeObject:bookToDelete];
            self.activeBook = nil;
        }
    }
    
    // if there is more books in que, process the first one
    if ([self.bookQue count] > 0) {
        for (Book *book in self.bookQue) {
            if (self.activeBook == nil) {
                NSLog(@"Setting new active book %@", book.title);
                self.activeBook = book;
                self.downloadedZipData = [[NSMutableData alloc] init];
                [self processBook:self.activeBook];
                break;
            }
        }
    } else {
        NSLog(@"Que empty.");
        self.activeBook = nil;
    }
}

- (void)addBookToQue:(Book *)book {
    if ([book.status isEqualToString:@"ready"]) {
        NSLog(@"Book %@ alredy downloaded", book.title);
    }
    else if ([book.status isEqualToString:@"downloading"]) {
        NSLog(@"Book %@ id beeing downloaded", book.title);
    }
    else if ([book.status isEqualToString:@"deleting"]) {
        NSLog(@"Book %@ id beeing deleted", book.title);
    }
    else {
        NSLog(@"Book %@ added to que", book.title);
        [self.bookQue addObject:book];
        book.status = @"qued";
        if (self.activeBook == nil) {
            [self processQue];
        }
    }
    
}

@end
