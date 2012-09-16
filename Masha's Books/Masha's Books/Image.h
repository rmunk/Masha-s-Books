//
//  Image.h
//  Masha's Books
//
//  Created by Luka Miljak on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Book *book;

@end
