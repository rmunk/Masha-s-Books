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

- (BookExtractor *)initExtractorWithUrl:(NSURL *)zipURL {
    self = [super init];
    if (self) {
        self.downloadedZipData = [[NSMutableData alloc] init];
        self.downloadRequest = [[NSURLRequest alloc] initWithURL:zipURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];
        self.downloading = NO;
        self.activeBook = nil;
    }
    return self;
}

- (BookExtractor *)initExtractorWithShop:(id)shop andContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        self.downloadedZipData = [[NSMutableData alloc] init];
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


- (void)populateBookWithPages
{
}

- (void)downloadBookZipFile {
    self.downloading = YES;
    [self.downloadConnection start];
    while (self.downloading == YES);
   // NSLog(@"Expected size %lld", self.downloadConnection.);
}

- (void)extractBookFromFile:(NSString *)zipFile
{
    NSLog(@"Extracting from: %@", zipFile);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *newDir = [tmpFolder stringByAppendingPathComponent:[zipFile.lastPathComponent stringByDeletingPathExtension]];
    
    if ([fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
    {
        NSLog(@"Failed to create directory");
        self.success = FALSE;
        [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:self.success];
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
             dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Extracting %@ Done!", zipFile.lastPathComponent);
            
      //      NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
      //      [addingContext setPersistentStoreCoordinator:self.activeBook.managedObjectContext.persistentStoreCoordinator];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
            request.predicate = [NSPredicate predicateWithFormat:@"title = %@", self.activeBook.title];
            
            NSError *error;
            self.activeBook = [[self.context executeFetchRequest:request error:&error] lastObject];
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
                for (Page *pageToDelete in self.activeBook.pages)
                    [self.context deleteObject:pageToDelete];
                
                NSPredicate *flter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];        
                NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:flter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                
                if (!self.activeBook.coverImage){
                    Image *coverImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.context];
                    coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                    self.activeBook.coverImage = coverImage;
                }
                else 
                    self.activeBook.coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                self.activeBook.downloadDate = [NSDate date];
                self.activeBook.downloaded = [NSNumber numberWithInt:1];
                self.activeBook.backgroundMusic = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:@"music.m4a"]];

                // Insert title page first
                NSManagedObjectContext *context = [self.activeBook managedObjectContext];
                Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                page.pageNumber = [NSNumber numberWithInt:0];
                page.image = self.activeBook.coverImage.image;
                [self.activeBook insertObject:page inPagesAtIndex:0];
                
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
                    [self.activeBook insertObject:page inPagesAtIndex:pageNumber];
                    pageNumber++;
                }      
            }

            NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
            [dnc addObserver:self.delegate selector:@selector(bookExtractorDidAddPagesToBook:) name:NSManagedObjectContextDidSaveNotification object:self.context];

            [self.context save:&error];
            if (error) {
                NSLog(@"Error saving context (%@)!", error.description);
                self.success = FALSE;
                return;
            }
            [dnc removeObserver:self.delegate name:NSManagedObjectContextDidSaveNotification object:self.context];

           
                if ([self.delegate respondsToSelector:@selector(extractorForBook:didFinishExtractingWithSuccess:)]) {
                    [self.delegate extractorForBook:self.activeBook didFinishExtractingWithSuccess:self.success];
                    [self processQue];
                }
                
            });
        }     
    });
    dispatch_release(zipQueue);
}

- (void)downloadZipFileForBook:(Book *)book
{
    self.downloadRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.mashasbooks.com%@",book.downloadURL]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    self.downloadConnection = [[NSURLConnection alloc] initWithRequest:self.downloadRequest delegate:self];
//    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",book.downloadURL.lastPathComponent]];
    
    NSLog(@"Downloading zip file for book %@.", book.title);
    
    dispatch_queue_t downloadZipQueue = dispatch_queue_create("zip download", NULL);
    dispatch_async(downloadZipQueue, ^{
        
        
        //while ([bookExtractor isDownloading] == YES);
        
        
       // NSData *zipFile = [NSData dataWithData:self.downloadedZipData];
        //NSData *zipFile = [NSData dataWithContentsOfURL:zipURL];
     //   [zipFile writeToFile:file atomically:YES];       
        
        dispatch_async(dispatch_get_main_queue(), ^{   
             
        });   
        
    });
    dispatch_release(downloadZipQueue);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedZipData appendData:data];
    if (self.expectedZipSize != 0) {
        float percentage = (float)[self.downloadedZipData length]/(float)self.expectedZipSize;
        //NSLog(@"Downloading %@", self.book.title);
       // NSLog(@"Downloaded data size = %u, Expected data size = %llu, Download percentage = %f", [self.downloadedZipData length], self.expectedZipSize, percentage);
        //[self.delegate extractorBook:self.book receivedNewPercentage:percentage];
   //     NSLog(@"Date received: %f %% ", percentage * 100);
        [self.delegate extractorBook:self.activeBook receivedNewPercentage:percentage];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedZipSize = [response expectedContentLength];
 //   NSLog(@"Expected size %lld", self.expectedZipSize);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   // [self.delegate extractorBook:self.book receivedNewPercentage:1];
    [self.delegate extractorBook:self.activeBook receivedNewPercentage:1];
    
    NSLog(@"Data download finished for book %@", self.activeBook.title);
    self.downloading = NO;
    self.file = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",self.activeBook.downloadURL.lastPathComponent]];
    NSLog(@"Saving zip file...");
    NSData *zipFile = [NSData dataWithData:self.downloadedZipData];
    [zipFile writeToFile:self.file atomically:YES];
    [self extractBookFromFile:self.file];
}

- (BOOL)isDownloading {
    return self.downloading;
}

- (NSData *)getDownloadedData {
    return [self.downloadedZipData copy];
}

- (void)processBook:(Book *)book {
    [self downloadZipFileForBook:book];
    
}

- (void)processQue {
    NSLog(@"Processing que...");
    // remove processed books
    Book *bookToDelete;
    int flag = 1;
    while (1) {
        NSLog(@"While...");
        if (!flag)
            break;
        
        flag = 0;
        
        for (Book *book in self.bookQue) {
            NSLog(@"Book %@ is downloaded %d", book.title, [book.downloaded intValue]);
            if ([book.downloaded intValue] == 1) {
                NSLog(@"Naslo knjigu");
                bookToDelete = book;
                flag = 1;
            }     
        }
        if(flag) {
            NSLog(@"Removing %@ from que.", bookToDelete.title);
            [self.bookQue removeObject:bookToDelete];  
            self.activeBook = nil;
        }
    }
    
    // if there is more books in que, process the first one
    if ([self.bookQue count] > 0) {
        for (Book *book in self.bookQue) {
            NSLog(@"Bk %@ is downloaded %d", book.title, [book.downloaded intValue]);
            if (self.activeBook == nil) {
                NSLog(@"Processing book %@.", book.title);
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
    [self processQue];  
}

@end
