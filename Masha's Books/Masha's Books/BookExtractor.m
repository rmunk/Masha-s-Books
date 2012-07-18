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
@end

@implementation BookExtractor
@synthesize delegate = _delegate;
@synthesize book = _book;
@synthesize success = _success;
@synthesize downloadRequest = _downloadRequest;
@synthesize downloadConnection = _downloadConnection;

@synthesize downloading = _downloading;

@synthesize expectedZipSize = _expectedZipSize;
@synthesize downloadedZipData = _downloadedZipData;

- (BookExtractor *)initExtractorWithUrl:(NSURL *)zipURL {
    self = [super init];
    if (self) {
        self.downloadedZipData = [[NSMutableData alloc] init];
        self.downloadRequest = [[NSURLRequest alloc] initWithURL:zipURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];
        self.downloading = NO;
    }
    return self;
}


- (void)populateBookWithPages
{
}

- (void)downloadBookZipFile {
    self.downloading = YES;
    [self.downloadConnection start];
   // NSLog(@"Expected size %lld", self.downloadConnection.);
}

- (void)extractBookFromFile:(NSString *)zipFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *newDir = [tmpFolder stringByAppendingPathComponent:[zipFile.lastPathComponent stringByDeletingPathExtension]];
    
    if ([fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
    {
        NSLog(@"Failed to create directory");
        self.success = FALSE;
        [self.delegate extractorForBook:self.book didFinishExtractingWithSuccess:self.success];
        return;
    }

    dispatch_queue_t zipQueue = dispatch_queue_create("zipQueue", NULL);
    dispatch_async(zipQueue, ^{
        
        // Extract zip file to tmp folder
        NSLog(@"Extracting %@ Started...", zipFile.lastPathComponent);
        NSError *error;
        self.success = [SSZipArchive unzipFileAtPath:zipFile toDestination:newDir error:&error delegate:self];
        if (error) {
            NSLog(@"Error extracting %@ (%@)!", zipFile.lastPathComponent, error.description);
            self.success = FALSE;
        }
        else 
        {
            NSLog(@"Extracting %@ Done!", zipFile.lastPathComponent);
            
            NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
            [addingContext setPersistentStoreCoordinator:self.book.managedObjectContext.persistentStoreCoordinator];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
            request.predicate = [NSPredicate predicateWithFormat:@"title = %@", self.book.title];
            
            NSError *error;
            self.book = [[addingContext executeFetchRequest:request error:&error] lastObject];
            if (error) {
                NSLog(@"Error loading book (%@)!", error.description);
                self.success = FALSE;
            }
            
            
            // Fill database with extracted data
            NSString *unzippedPath = newDir;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:unzippedPath error:&error];       
            if (error) {
                NSLog(@"Error reading %@ (%@)!", unzippedPath.lastPathComponent, error.description);
                self.success = FALSE;
            }
            else
            {
                for (Page *pageToDelete in self.book.pages)
                    [addingContext deleteObject:pageToDelete];
                
                NSPredicate *flter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];        
                NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:flter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                
                if (!self.book.coverImage){
                    Image *coverImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:addingContext];
                    coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                    self.book.coverImage = coverImage;
                }
                else 
                    self.book.coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                self.book.downloadDate = [NSDate date];
                self.book.downloaded = [NSNumber numberWithBool:TRUE];
                self.book.backgroundMusic = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:@"music.m4a"]];

                // Insert title page first
                NSManagedObjectContext *context = [self.book managedObjectContext];
                Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                page.pageNumber = [NSNumber numberWithInt:0];
                page.image = self.book.coverImage.image;
                [self.book insertObject:page inPagesAtIndex:0];
                
                int pageNumber = 1;
                for (NSString *pageFile in pageFiles) {
                    Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                    page.pageNumber = [NSNumber numberWithInt:pageNumber];
                    page.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:pageFile]];
                    page.text = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/text%03d.png",pageNumber]];
                    page.voiceOver = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/voice%03d.m4a",pageNumber]];
                    page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d.m4a",pageNumber]];
                    if(!page.sound){
                        page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d_L.m4a",pageNumber]];
                        if(page.sound) page.soundLoop = [NSNumber numberWithBool:TRUE];
                    }
                    [self.book insertObject:page inPagesAtIndex:pageNumber];
                    pageNumber++;
                }      
            }

            NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
            [dnc addObserver:self.delegate selector:@selector(bookExtractorDidAddPagesToBook:) name:NSManagedObjectContextDidSaveNotification object:addingContext];

            [addingContext save:&error];
            if (error) {
                NSLog(@"Error saving context (%@)!", error.description);
                self.success = FALSE;
                return;
            }
            [dnc removeObserver:self.delegate name:NSManagedObjectContextDidSaveNotification object:addingContext];

            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(extractorForBook:didFinishExtractingWithSuccess:)])
                    [self.delegate extractorForBook:self.book didFinishExtractingWithSuccess:self.success];
            });
        }     
    });
    dispatch_release(zipQueue);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedZipData appendData:data];
    if (self.expectedZipSize != 0) {
        float percentage = (float)[self.downloadedZipData length]/(float)self.expectedZipSize;
        //NSLog(@"Downloading %@", self.book.title);
       // NSLog(@"Downloaded data size = %u, Expected data size = %llu, Download percentage = %f", [self.downloadedZipData length], self.expectedZipSize, percentage);
        [self.delegate extractorBook:self.book receivedNewPercentage:percentage];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedZipSize = [response expectedContentLength];
 //   NSLog(@"Expected size %lld", self.expectedZipSize);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate extractorBook:self.book receivedNewPercentage:1];
    NSLog(@"Data download finished for book %@", self.book.title);
    self.downloading = NO;
}

- (BOOL)isDownloading {
    return self.downloading;
}

- (NSData *)getDownloadedData {
    return [self.downloadedZipData copy];
}

@end
