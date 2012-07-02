//
//  Author.h
//  Masha's Books
//
//  Created by Ranko Munk on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * bioHtml;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * websiteURL;
@property (nonatomic, retain) NSOrderedSet *books;
@end

@interface Author (CoreDataGeneratedAccessors)

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
