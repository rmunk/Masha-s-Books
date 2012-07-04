//
//  SlikovnicaModelController.h
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@class SlikovnicaDataViewController;

@interface SlikovnicaModelController : NSObject <UIPageViewControllerDataSource>

@property Book *book;

- (SlikovnicaDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(SlikovnicaDataViewController *)viewController;
- (NSNumber *)numberOfPages;
- (NSArray *)getPageThumbnails;

@end

