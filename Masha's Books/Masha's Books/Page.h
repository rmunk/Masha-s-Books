//
//  Page.h
//  Masha's Books
//
//  Created by Ranko Munk on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Page : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) id text;
@property (nonatomic, retain) id voiceOver;
@property (nonatomic, retain) id sound;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) Book *book;

@end
