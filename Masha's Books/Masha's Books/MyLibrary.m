//
//  MyLibrary.m
//  Masha's Books
//
//  Created by Ranko Munk on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyLibrary.h"
#import "Book.h"

@interface MyLibrary ()
@property NSArray *bookCovers;

@end

@implementation MyLibrary
@synthesize bookCovers = _bookCovers;
@synthesize numberOfBooksInMyLibrary;
@synthesize libraryDatabase = _libraryDatabase;

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.libraryDatabase.fileURL path]]) {
        [self.libraryDatabase saveToURL:self.libraryDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            
        }];
    } else if (self.libraryDatabase.documentState == UIDocumentStateClosed) {
        [self.libraryDatabase openWithCompletionHandler:^(BOOL success){
            
        }];
    } else if (self.libraryDatabase.documentState == UIDocumentStateNormal) {

    }
    
}

- (void)setLibraryDatabase:(UIManagedDocument *)libraryDatabase
{
    if (_libraryDatabase != libraryDatabase) {
        _libraryDatabase = libraryDatabase;
        [self useDocument];
    }
}

- (NSUInteger)numberOfBooksInMyLibrary
{
    return self.bookCovers.count;
}

- (id)init
{
    self = [super init];
    if (self) {
        if (!self.libraryDatabase) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            url = [url URLByAppendingPathComponent:@"LibraryDatabase"];
            self.libraryDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        }
        
//        NSManagedObjectContext * context = self.libraryDatabase.managedObjectContext;
//        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
//        request.predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
//        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
//        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//        
//        NSError *error;
//        NSArray *myBooks = [context executeFetchRequest:request error:&error];
//        
       
        // Set up the image we want to scroll & zoom and add it to the scroll view
        self.bookCovers = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"01c.jpeg"],
                           [UIImage imageNamed:@"02c.jpeg"],
                           [UIImage imageNamed:@"03c.jpeg"],
                        //   [UIImage imageNamed:@"04c.jpeg"],
                           [UIImage imageNamed:@"05c.jpeg"],
                           [UIImage imageNamed:@"06c.jpeg"],
                           [UIImage imageNamed:@"07c.jpeg"],
                           [UIImage imageNamed:@"08c.jpeg"],
                           nil];
        
        
    }
    return self;
}

- (NSArray *)MyBooks
{
    NSManagedObjectContext * context = self.libraryDatabase.managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"downloaded > 0"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSDictionary *entityProperties = [[NSEntityDescription entityForName:@"Book" inManagedObjectContext:context] propertiesByName];
        [request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"title"]]];
    
    NSError *error;
    NSArray *myBooks = [context executeFetchRequest:request error:&error];
    
    return myBooks;
}

- (UIImage *)CoverImageForBook:(NSString *)bookTitle
{
    NSManagedObjectContext * context = self.libraryDatabase.managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", bookTitle];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error;
    Book *book = [[context executeFetchRequest:request error:&error] lastObject];
    return book.coverImage;    
}

- (UIImage *)BookCoverImageAtIndex:(NSUInteger)index
{
    UIImage *bookCoverImage = [self.bookCovers objectAtIndex:index];
    return bookCoverImage;
}

@end
