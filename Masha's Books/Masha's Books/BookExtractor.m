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
@end

@implementation BookExtractor
@synthesize delegate = _delegate;
@synthesize book = _book;
@synthesize success = _success;

- (void)populateBookWithPages
{
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
        [self.delegate bookExtractor:self didFinishExtractingWithgSuccess:self.success];
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
        NSMutableArray *pages = [[NSMutableArray alloc] init];
        NSMutableIndexSet *pagesIndexSet = [[NSMutableIndexSet alloc] init];
            NSString *unzippedPath = newDir;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
//        NSError *error;
            NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:unzippedPath error:&error];       
            if (error) {
                NSLog(@"Error reading %@ (%@)!", unzippedPath.lastPathComponent, error.description);
                self.success = FALSE;
            }
            else
            {
                NSPredicate *flter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];        
                NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:flter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                
                Image *coverImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:addingContext];
                coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
                self.book.coverImage = coverImage;
                self.book.downloadDate = [NSDate date]; 
                int pageNumber = 1;
                for (NSString *pageFile in pageFiles) {
                    NSManagedObjectContext *context = [self.book managedObjectContext];
                    Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                    page.pageNumber = [NSNumber numberWithInt:pageNumber];
                    page.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:pageFile]];
                    page.text = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/text%03d.png",pageNumber]];
                    page.voiceOver = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/voice%03d.m4a",pageNumber]];
                    page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d.m4a",pageNumber]];
                    
                    [pages addObject:page];
                    [pagesIndexSet addIndex:pageNumber-1];
                    [self.book insertObject:page inPagesAtIndex:pageNumber-1];
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

//            if (self.success)
//                [self.book insertPages:pages atIndexes:pagesIndexSet];

        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate bookExtractor:self didFinishExtractingWithgSuccess:self.success];
        });
        }
     
    });
    dispatch_release(zipQueue);
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
//    NSLog(@"Zip delegate");
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:unzippedPath error:&error];       
//    if (error) {
//        NSLog(@"Error reading %@ (%@)!", unzippedPath.lastPathComponent, error.description);
//        self.success = FALSE;
//        return;
//    }
//    
//    NSPredicate *flter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];        
//    NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:flter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    
//    self.book.coverImage.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingString:@"/title.jpg"]];
//
//    int pageNumber = 1;
//    for (NSString *pageFile in pageFiles) {
//        NSManagedObjectContext *context = [self.book managedObjectContext];
//        Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
//        page.pageNumber = [NSNumber numberWithInt:pageNumber];
//        page.image = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingPathComponent:pageFile]];
//        page.text = [UIImage imageWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/text%03d.png",pageNumber]];
//        page.voiceOver = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/voice%03d.m4a",pageNumber]];
//        page.sound = [NSData dataWithContentsOfFile:[unzippedPath stringByAppendingFormat:@"/sound%03d.m4a",pageNumber]];
//        [self.book insertObject:page inPagesAtIndex:pageNumber-1];
//        pageNumber++;
//    }
//    NSOrderedSet *bla = self.book.pages;
//    ;
}

@end
