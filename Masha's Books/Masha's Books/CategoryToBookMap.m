//
//  CategoryToBookMap.m
//  Masha's Books
//
//  Created by Luka Miljak on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryToBookMap.h"

@interface CategoryToBookMap()

@property (nonatomic, strong) NSMutableArray *catToBookPairs;

@end

@implementation CategoryToBookMap

@synthesize catToBookPairs = _catToBookPairs;

- (NSMutableArray *)catToBookPairs {
    if (!_catToBookPairs) {
        _catToBookPairs = [[NSMutableArray alloc] init];
    }
    return _catToBookPairs;
}

- (void)pairCategory:(NSInteger)catID withBook:(NSInteger)bookID {
    NSArray *catBookPair = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:catID],[NSNumber numberWithInt:bookID], nil];
    [self.catToBookPairs addObject:catBookPair];    
    
    NSLog(@"New category-book pair [%d, %d]", [[catBookPair objectAtIndex:0] intValue], [[catBookPair objectAtIndex:1] intValue]);
    NSLog(@"New category-book pair [%d, %d]", [[[self.catToBookPairs lastObject] objectAtIndex:0] intValue], [[[self.catToBookPairs lastObject] objectAtIndex:1] intValue]);
}

- (NSArray *)getCategoryBookPairsArray {
    return [self.catToBookPairs copy];
}

- (NSArray *)getCategoryBookPairAtIndex:(NSUInteger)index {
    return [self.catToBookPairs objectAtIndex:index];
}

- (NSArray *)getBookIdentifiersForCategoryIdentifier:(NSInteger)catID {
    NSMutableArray *bookIDsForCatID = [[NSMutableArray alloc] init];
    for (NSArray *catBookPair in self.catToBookPairs) {
        if ([[catBookPair objectAtIndex:0] intValue] == catID ) {
            NSNumber *newBookIdForCat = [[NSNumber alloc] initWithInt:[[catBookPair objectAtIndex:1] intValue]];
            [bookIDsForCatID addObject:newBookIdForCat];
        }
    }
    
    if ([bookIDsForCatID count]) 
        return [bookIDsForCatID copy];
    else 
        return nil;
}

- (NSArray *)getCategoryIdentifiersForBookIdentifier:(NSInteger)bookID {
    NSMutableArray *catIDsForBookID = [[NSMutableArray alloc] init];
    for (NSArray *catBookPair in self.catToBookPairs) {
        if ([[catBookPair objectAtIndex:1] intValue] == bookID ) {
            NSNumber *newCatIdForBook = [[NSNumber alloc] initWithInt:[[catBookPair objectAtIndex:0] intValue]];
            [catIDsForBookID addObject:newCatIdForBook];
        }
    }
    
    if ([catIDsForBookID count]) 
        return [catIDsForBookID copy];
    else 
        return nil;    
}

@end
