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
@property (nonatomic, strong) NSManagedObjectContext *context;

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
@synthesize context = _context;



@synthesize downloading = _downloading;

@synthesize expectedZipSize = _expectedZipSize;
@synthesize downloadedZipData = _downloadedZipData;


/*
- (BookExtractor *)initExtractorWithUrl:(NSURL *)zipURL {
    self = [super init];
    if (self) {
        self.downloadedZipData = [[NSMutableData alloc] init];
       self.downloadRequest = [[NSURLRequest alloc] initWithURL:zipURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];        self.downloading = NO;
        self.activeBook = nil;
        
    }
    return self;
}
 */

- (BookExtractor *)initExtractorWithShop:(id)shop andContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        //self.downloadedZipData = [[NSMutableData alloc] init];
        //    self.downloadRequest = [[NSURLRequest alloc] initWithURL:zipURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        //   self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];
        self.bookQue = [[NSMutableOrderedSet alloc] init];
        self.delegate = shop;
        self.downloading = NO;
        self.activeBook = nil;
        self.context = context;
        
        
    }
    return self;
}

- (void)contextSaved:(NSNotification *)notification
{
    NSLog(@"SaveThread reports context saved");
    [self performSelectorOnMainThread:@selector(mergeContexts:) withObject:notification waitUntilDone:NO];  
}

- (void)mergeContexts:(NSNotification *)notification {
    NSLog(@"Merge contexts on main thread called");
    NSError *error;
    self.activeBook.status = @"ready";
    //self.activeBook.downloaded = [NSNumber numberWithInt:1];
    [self.context mergeChangesFromContextDidSaveNotification:notification];
    if ([self.context save:&error]) {
        self.activeBook = [Book getBookWithId:self.activeBook.bookID inContext:self.context withErrorHandler:error];
        NSLog(@"activeBook info: %@", self.activeBook);
        [self.delegate performSelector:@selector(pagesAdded)];
    }
    else {
        NSLog(@"error saving book %@", self.activeBook.title);
    }
    
    
    //if (self.success == YES) 
    
    
    [self processQue];
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
    
    dispatch_queue_t zipQueue = dispatch_queue_create("zipQueue", NULL);
    dispatch_async(zipQueue, ^{
        
        // Extract zip file to tmp folder
        NSLog(@"Extracting %@ Started...", zipFile.lastPathComponent);
        NSError *error;
        self.success = [SSZipArchive unzipFileAtPath:zipFile toDestination:newDir error:&error delegate:self];
        
        if ((self.success == NO) && [self.delegate respondsToSelector:@selector(extractorForBook:didFinishExtractingWithSuccess:)]) {
            [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:self.success];
            [self.downloadedZipData setLength:0];
            return;        
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            NSLog(@"Extracting %@ Done!", zipFile.lastPathComponent);
            [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:YES];
            [self saveDataToBook:self.activeBook FromPath:newDir];
                
        });
    });
    dispatch_release(zipQueue);
}

- (void)saveDataToBook:(Book *)bookFromMainThread FromPath:(NSString *)unzippedPath {
    dispatch_queue_t saveQue = dispatch_queue_create("saveQue", NULL);
    dispatch_async(saveQue, ^{
        NSError *error;

        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
        [addingContext setPersistentStoreCoordinator:bookFromMainThread.managedObjectContext.persistentStoreCoordinator];
        
        Book *book = [Book getBookWithId:bookFromMainThread.bookID inContext:addingContext withErrorHandler:error];
            
        // Fill database with extracted data
          
        NSFileManager *fileManager = [NSFileManager defaultManager];
            
        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:unzippedPath error:&error];
        if (error) {
            NSLog(@"Error reading %@ (%@)!", unzippedPath.lastPathComponent, error.description);
            //self.success = NO;
        }
        else
        {
            for (Page *pageToDelete in book.pages)
                [addingContext deleteObject:pageToDelete];
                
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];
            NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:filter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                    
            if (!book.coverImage){
                Image *coverImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:addingContext];
                coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                book.coverImage = coverImage;
            }
            else
                book.coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                
                
            book.backgroundMusic = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:@"music.m4a"]];
                
            // Insert title page first
            // NSManagedObjectContext *context = [book managedObjectContext];
            Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:addingContext];
            page.pageNumber = [NSNumber numberWithInt:0];
            page.image = book.coverImage.image;
            [book insertObject:page inPagesAtIndex:0];
                
            int pageNumber = 1;
            for (NSString *pageFile in pageFiles) {
                Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:addingContext];
                page.pageNumber = [NSNumber numberWithInt:pageNumber];
                page.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:pageFile]];
                page.text = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/text%03d.png",pageNumber]];
                page.voiceOver = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/voice%03d.m4a",pageNumber]];
                page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d.m4a",pageNumber]];
                if(!page.sound){
                    page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d_L.m4a",pageNumber]];
                    if(page.sound) page.soundLoop = [NSNumber numberWithBool:TRUE];
                }
                [book insertObject:page inPagesAtIndex:pageNumber];
                pageNumber++;
            }
                
            book.downloadDate = [NSDate date];
            book.downloaded = [NSNumber numberWithInt:1];
            book.status = @"ready";
            
 
     
            NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
            [dnc addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:addingContext];
            
            
            //[[NSNotificationCenter defaultCenter] addObserver:self.delegate selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:addingContext];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:addingContext];
                
            if([addingContext save:&error]) {
                NSLog(@"Saving addingContext sucessfull");
            }
            else {
                NSLog(@"Error saving context (%@)!", error.description);
               
            }
            
                
            [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingContext];
            
        
        }
        
        

        
       // if (self.success) book.status = @"bought";
      //  else book.status = @"failed";
        
        
       // if ([self.delegate respondsToSelector:@selector(extractorForBook:didFinishExtractingWithSuccess:)]) {
        //    [self.delegate extractorForBook:book didFinishExtractingWithSuccess:self.success];
            //[self.downloadedZipData setLength:0];
           // [self processQue];
        //}
        
        // Cleanup of temp files
        //            [fileManager removeItemAtPath:zipFile error:nil];
        //            [fileManager removeItemAtPath:newDir error:nil];
    });
    dispatch_release(saveQue);

}

- (void)downloadZipFileForBook:(Book *)book
{
    NSLog(@"Download request for book %@ at %@", book.title, [NSString stringWithFormat:@"http://www.mashasbookstore.com%@",book.downloadURL]);
    self.downloadRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.mashasbookstore.com%@",book.downloadURL]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSLog(@"Download request %@", self.downloadRequest.description);
    
    self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];
    if (self.downloadConnection) {
        NSLog(@"Downloading zip file for book %@ through connection %@.", book.title, self.downloadConnection.description);
        self.downloading = YES;
      //  [self.downloadConnection start];
   
   
    }
    else {
        NSLog(@"Could not start download of %@.", book.title);
    }
    
    //    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",book.downloadURL.lastPathComponent]];
    
    
    
    /*
    
    dispatch_queue_t downloadZipQueue = dispatch_queue_create("zip download", NULL);
    dispatch_async(downloadZipQueue, ^{
        
        
        //while ([bookExtractor isDownloading] == YES);
        
        
        // NSData *zipFile = [NSData dataWithData:self.downloadedZipData];
        //NSData *zipFile = [NSData dataWithContentsOfURL:zipURL];
        //   [zipFile writeToFile:file atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    });
    dispatch_release(downloadZipQueue); */
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedZipData appendData:data];
    if (self.expectedZipSize != 0) {
        float percentage = (float)[self.downloadedZipData length]/(float)self.expectedZipSize;
        //NSLog(@"Downloading %@", self.book.title);
        // NSLog(@"Downloaded data size = %u, Expected data size = %llu, Download percentage = %f", [self.downloadedZipData length], self.expectedZipSize, percentage);
        //[self.delegate extractorBook:self.book receivedNewPercentage:percentage];
        //NSLog(@"Data received: %f %% ", percentage * 100);
        [self.delegate extractorBook:self.activeBook receivedNewPercentage:percentage];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedZipSize = [response expectedContentLength];
    //   NSLog(@"Expected size %lld", self.expectedZipSize);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self.delegate extractorBook:self.activeBook receivedNewPercentage:1];
    
    NSLog(@"Data download finished for book %@", self.activeBook.title);
    self.downloading = NO;
    self.file = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",self.activeBook.downloadURL.lastPathComponent]];
    NSLog(@"Saving zip file...");
    NSData *zipFile = [NSData dataWithData:self.downloadedZipData];
    [zipFile writeToFile:self.file atomically:YES];
    self.activeBook.status = @"extracting";
    [self extractBookFromFile:self.file];
}

- (BOOL)isDownloading {
    return self.downloading;
}

- (NSData *)getDownloadedData {
    return [self.downloadedZipData copy];
}

- (void)processBook:(Book *)book {
    book.status = [NSString stringWithString:@"downloading"];
    [self downloadZipFileForBook:book];
    
}

// State machine processQue
- (void)processQue {
    NSLog(@"Processing que");
    // remove processed books
    Book *bookToDelete;
    int flag = 1;
    while (1) {
        if (!flag)
            break;
        
        flag = 0;
        
        for (Book *book in self.bookQue) {
            if (book.status == @"ready") {
                bookToDelete = book;
                flag = 1;
            }
            else if (book.status == @"failed"){
                book.status = [NSString stringWithString:@"available"];
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
    NSLog(@"Book added to que");
    [self.bookQue addObject:book];
    book.status = [NSString stringWithString:@"qued"];
    if (self.activeBook == nil) {
        [self processQue];
    }    
}

@end
