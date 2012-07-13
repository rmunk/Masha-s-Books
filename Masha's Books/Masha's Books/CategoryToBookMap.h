//
//  CategoryToBookMap.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryToBookMap : NSObject


- (void)pairCategory:(NSInteger)catID withBook:(NSInteger)bookID;
- (NSArray *)getCategoryBookPairsArray;
- (NSArray *)getCategoryBookPairAtIndex:(NSUInteger)index;
- (NSArray *)getBookIdentifiersForCategoryIdentifier:(NSInteger)catID;
- (NSArray *)getCategoryIdentifiersForBookIdentifier:(NSInteger)bookID;

@end
