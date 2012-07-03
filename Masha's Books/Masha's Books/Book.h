//
//  Book.h
//  Masha's Books
//
//  Created by Luka Miljak on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Category, Image, Page;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSNumber * appStoreID;
@property (nonatomic, retain) NSData * backgroundMusic;
@property (nonatomic, retain) UIImage * coverThumbnailImage;
@property (nonatomic, retain) NSDate * downloadDate;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSString * facebookLikeURL;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * youTubeVideoURL;
@property (nonatomic, retain) NSString * active;
@property (nonatomic, retain) NSNumber * authorID;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * descriptionHTML;
@property (nonatomic, retain) NSString * descriptionLongHTML;
@property (nonatomic, retain) NSNumber * bookID;
@property (nonatomic, retain) Author *author;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) Image *coverImage;
@property (nonatomic, retain) NSOrderedSet *pages;
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
