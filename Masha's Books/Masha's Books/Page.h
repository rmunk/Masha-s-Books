//
//  Page.h
//  Masha's Books
//
//  Created by Ranko Munk on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Page : NSManagedObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSData * sound;
@property (nonatomic, retain) UIImage *text;
@property (nonatomic, retain) NSData * voiceOver;
@property (nonatomic, retain) Book *book;

@end
