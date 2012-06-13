//
//  Image.h
//  Masha's Books
//
//  Created by Ranko Munk on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface ImageToDataTransformer : NSValueTransformer 
@end

@interface Image : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) Book *book;

@end
