//
//  Page.h
//  Masha's Books
//
//  Created by Luka Miljak on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSData * sound;
@property (nonatomic, retain) NSNumber * soundLoop;
@property (nonatomic, retain) NSData * text;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSData * voiceOver;
@property (nonatomic, retain) Book *book;

@end
