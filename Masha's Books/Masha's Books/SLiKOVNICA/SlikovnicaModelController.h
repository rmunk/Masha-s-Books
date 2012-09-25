//
//  SlikovnicaModelController.h
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book+Addon.h"

@class SlikovnicaDataViewController;

@interface SlikovnicaModelController : NSObject <UIPageViewControllerDataSource>

@property (strong, nonatomic) Book *book;
@property (nonatomic) BOOL textVisible;
@property (nonatomic) BOOL voiceOverPlay;
@property (nonatomic) NSUInteger numberOfPages;

- (SlikovnicaDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(SlikovnicaDataViewController *)viewController;
- (NSArray *)getPageThumbnails;

@end

