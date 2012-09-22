//
//  SlikovnicaModelController.m
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlikovnicaModelController.h"
#import "SlikovnicaDataViewController.h"
#import "SlikovnicaLastPageViewController.h"
#import "Image.h"
#import "UIImage+Resize.h"

/*
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface SlikovnicaModelController()
@property Page *nextPage;
@property Page *previousPage;
@end

@implementation SlikovnicaModelController

@synthesize book = _book;
@synthesize textVisible = _textVisible;
@synthesize voiceOverPlay = _voiceOverPlay;
@synthesize numberOfPages = _numberOfPages;
@synthesize nextPage = _nextPage;
@synthesize previousPage = _previousPage;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.textVisible = TRUE;
        self.voiceOverPlay = TRUE;
    }
    return self;
}

- (SlikovnicaDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (([self.book.pages count] == 0) || (index > [self.book.pages count])) {
        return nil;
    }
    
    if (index == self.numberOfPages)
    {
        SlikovnicaLastPageViewController *lastPage = [storyboard instantiateViewControllerWithIdentifier:@"LastPage"];
        lastPage.view.tag = index;
        return lastPage;
    }
    
    // Create a new view controller and pass suitable data.
    SlikovnicaDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"SlikovnicaDataViewController"];
    dataViewController.view.tag = index;
    dataViewController.page = [self.book.pages objectAtIndex:index];
    dataViewController.textVisible = self.textVisible;
    dataViewController.voiceOverPlay = self.voiceOverPlay;
    
    //    Page *preloadNextPage = [self.book.pages objectAtIndex:index + 1];
    [self.book.managedObjectContext refreshObject:self.book mergeChanges:NO];
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(UIViewController *)viewController
{
    // Return the index of the given data view controller.
    return viewController.view.tag;
}

- (NSUInteger)numberOfPages
{
    return self.book.pages.count;
}

- (NSArray *)getPageThumbnails
{
    NSLog(@"Creating filmstrip thumbnails...");
    NSMutableArray *thumbnails = [[NSMutableArray alloc] init];
    
    for (Page *page in self.book.pages) {
        UIImage *image = [UIImage imageWithData:page.image];
        UIImage *thumbnail = [image resizedImage:CGSizeMake(138, 103) interpolationQuality:kCGInterpolationHigh];
        [thumbnails addObject:thumbnail];
    }
    [self.book.managedObjectContext refreshObject:self.book mergeChanges:NO];
    
    NSLog(@"Creating filmstrip thumbnails done.");
    return thumbnails;
}

#pragma mark - Page View Controller Data Source

- (SlikovnicaDataViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [self viewControllerAtIndex:viewController.view.tag - 1 storyboard:viewController.storyboard];
}

- (SlikovnicaDataViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return [self viewControllerAtIndex:viewController.view.tag + 1 storyboard:viewController.storyboard];
}

@end
