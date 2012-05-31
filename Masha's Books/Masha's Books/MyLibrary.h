//
//  MyLibrary.h
//  Masha's Books
//
//  Created by Ranko Munk on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyBooksViewController.h"

@interface MyLibrary : NSObject <MyBooksViewControllerDataSource>
@property (nonatomic, strong) UIManagedDocument *libraryDatabase;
@end
