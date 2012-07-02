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

- (void)extractBook:(Book *)book FromFile:(NSString *)zipFile
{
    self.book = book;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *newDir = [tmpFolder stringByAppendingPathComponent:[zipFile.lastPathComponent stringByDeletingPathExtension]];
    
    if ([fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
    {
        NSLog(@"Failed to create directory");
        self.success = FALSE;
        return;
    }


    dispatch_queue_t zipQueue = dispatch_queue_create("zipQueue", NULL);
    dispatch_async(zipQueue, ^{
        NSLog(@"Extracting %@ Started...", zipFile.lastPathComponent);
        NSError *error;
        self.success = [SSZipArchive unzipFileAtPath:zipFile toDestination:newDir error:&error delegate:self];
        if (error) {
            NSLog(@"Error extracting %@ (%@)!", zipFile.lastPathComponent, error.description);
            self.success = FALSE;
            return;
        }
        NSLog(@"Extracting %@ Done!", zipFile.lastPathComponent);
        
        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:newDir error:&error];       
        if (error) {
            NSLog(@"Error reading %@ (%@)!", newDir.lastPathComponent, error.description);
            self.success = FALSE;
            return;
        }
        
        NSPredicate *flter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'page'"];        
        NSArray *pageFiles = [[dirContents filteredArrayUsingPredicate:flter] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//        NSMutableArray *pages = [[NSMutableArray alloc] initWithCapacity:pageFiles.count];
//        NSMutableOrderedSet *pages = [[NSMutableOrderedSet alloc] initWithCapacity:pageFiles.count];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            book.coverImage.image = [UIImage imageWithContentsOfFile:[newDir stringByAppendingString:@"/title.jpg"]];
            int pageNumber = 1;
            for (NSString *pageFile in pageFiles) {
                NSManagedObjectContext *context = [book managedObjectContext];
                Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                page.pageNumber = [NSNumber numberWithInt:pageNumber];
                page.image = [UIImage imageWithContentsOfFile:[newDir stringByAppendingPathComponent:pageFile]];
                page.text = [UIImage imageWithContentsOfFile:[newDir stringByAppendingFormat:@"/text%03d.png",pageNumber]];
                page.voiceOver = [NSData dataWithContentsOfFile:[newDir stringByAppendingFormat:@"/voice%03d.m4a",pageNumber]];
                page.sound = [NSData dataWithContentsOfFile:[newDir stringByAppendingFormat:@"/sound%03d.m4a",pageNumber]];
                pageNumber++;
                [book addPagesObject:page];
//                [pages addObject:page];
            }
//            [book addPages:[NSOrderedSet orderedSetWithOrderedSet:pages]];            
        });        
        [self.delegate bookExtractor:self didFinishExtractinWithgSuccess:self.success];
    });
    dispatch_release(zipQueue);
    
    NSLog(@"Bla");
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{

}

@end
