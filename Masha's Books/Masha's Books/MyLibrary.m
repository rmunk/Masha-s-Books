//
//  MyLibrary.m
//  Masha's Books
//
//  Created by Ranko Munk on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyLibrary.h"

@interface MyLibrary ()
@property NSArray *bookCovers;

@end

@implementation MyLibrary
@synthesize bookCovers = _bookCovers;
@synthesize numberOfBooksInMyLibrary;

- (NSUInteger)numberOfBooksInMyLibrary
{
    return self.bookCovers.count;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        // Set up the image we want to scroll & zoom and add it to the scroll view
        self.bookCovers = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"01.jpg"],
                           [UIImage imageNamed:@"02.jpg"],
                           [UIImage imageNamed:@"03.jpg"],
                           [UIImage imageNamed:@"04.jpg"],
                           [UIImage imageNamed:@"05.jpg"],
                           [UIImage imageNamed:@"06.jpg"],
                           [UIImage imageNamed:@"07.jpg"],
                           [UIImage imageNamed:@"08.jpg"],
                           [UIImage imageNamed:@"09.jpg"],
                           [UIImage imageNamed:@"10.jpg"],
                           nil];
        
        
    }
    return self;
}

- (UIImage *)BookCoverImageAtIndex:(NSUInteger)index
{
    UIImage *bookCoverImage = [self.bookCovers objectAtIndex:index];
    return bookCoverImage;
}

@end
