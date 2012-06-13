//
//  Book.h
//  Masha's Books
//
//  Created by Ranko Munk on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Category, Image, Page;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSNumber * appStoreID;
@property (nonatomic, retain) id backgroundMusic;
@property (nonatomic, retain) id coverThumbnailImage;
@property (nonatomic, retain) NSDate * downloadDate;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSString * facebookLikeURL;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * youTubeVideoURL;
@property (nonatomic, retain) Author *author;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSOrderedSet *pages;
@property (nonatomic, retain) Image *coverImage;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)insertObject:(Page *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(Page *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray *)values;
- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSOrderedSet *)values;
- (void)removePages:(NSOrderedSet *)values;
@end
