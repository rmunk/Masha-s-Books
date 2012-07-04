//
//  Image.h
//  Masha's Books
//
//  Created by Ranko Munk on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Image : NSManagedObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) Book *book;

@end
