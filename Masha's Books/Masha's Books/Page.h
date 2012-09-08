//
//  Page.h
//  Masha's Books
//
//  Created by Ranko Munk on 9/8/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Page : NSManagedObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSData * sound;
@property (nonatomic, retain) NSNumber * soundLoop;
@property (nonatomic, retain) UIImage *text;
@property (nonatomic, retain) NSData * voiceOver;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) Book *book;

@end
