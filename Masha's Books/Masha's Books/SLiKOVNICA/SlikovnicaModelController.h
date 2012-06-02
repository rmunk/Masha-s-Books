//
//  SlikovnicaModelController.h
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlikovnicaDataViewController;

@interface SlikovnicaModelController : NSObject <UIPageViewControllerDataSource>

- (SlikovnicaDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(SlikovnicaDataViewController *)viewController;
- (NSUInteger)numberOfPages;
- (NSArray *)getPageThumbnails;

@end

@interface SlikovnicaPage : NSObject
@property (nonatomic) NSString *pageNumber;
@property (nonatomic) NSString *image;
@property (nonatomic) NSString *sound;
@end

