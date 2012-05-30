//
//  MyBooksViewController.h
//  Masha's Books
//
//  Created by Ranko Munk on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyBooksViewControllerDataSource <NSObject>

@property (readonly) NSUInteger numberOfBooksInMyLibrary;

- (UIImage *)BookCoverImageAtIndex:(NSUInteger)index;

@end

@interface MyBooksViewController : UIViewController
@property (nonatomic, weak) id <MyBooksViewControllerDataSource> dataSource;
@end
