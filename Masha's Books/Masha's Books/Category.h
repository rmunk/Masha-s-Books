//
//  Category.h
//  Masha's Books
//
//  Created by Ranko Munk on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *books;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)insertObject:(Book *)value inBooksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBooksAtIndex:(NSUInteger)idx;
- (void)insertBooks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBooksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBooksAtIndex:(NSUInteger)idx withObject:(Book *)value;
- (void)replaceBooksAtIndexes:(NSIndexSet *)indexes withBooks:(NSArray *)values;
- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSOrderedSet *)values;
- (void)removeBooks:(NSOrderedSet *)values;
@end
