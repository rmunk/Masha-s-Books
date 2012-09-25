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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(nextPageLoaded:)
                                                     name:@"NextPageLoaded" object:nil];
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
    dataViewController.textVisible = self.textVisible;
    dataViewController.voiceOverPlay = self.voiceOverPlay;
//    if (index == [self.nextPage.pageNumber integerValue]) dataViewController.page = self.nextPage;
//    else if (index == [self.previousPage.pageNumber integerValue]) dataViewController.page = self.previousPage;
//    else dataViewController.page = [self.book.pages objectAtIndex:index];
    
    dataViewController.page = [self.book.pages objectAtIndex:index];

    [self.book.managedObjectContext refreshObject:self.book mergeChanges:NO];
    
//    NSLog(@"Start");
//    [self.book preloadPageNumber:[NSNumber numberWithInt:index + 1]];
//    [self.book preloadPageNumber:[NSNumber numberWithInt:index - 1]];
    
    return dataViewController;
}

- (void)preloadPreviousAndNexPageFromCurrentPage:(Page *)currentPage
{
    NSInteger current = currentPage.pageNumber.integerValue;
    NSInteger previous = self.previousPage.pageNumber.integerValue;
    NSInteger next = self.nextPage.pageNumber.integerValue;
    if (previous != current - 1) [self.book preloadPageNumber:[NSNumber numberWithInteger:previous]];
    if (next != current + 1) [self.book preloadPageNumber:[NSNumber numberWithInteger:next]];
}

- (void)nextPageLoaded:(NSNotification *)notification
{
    NSLog(@"Stop");
    self.nextPage = [notification.userInfo objectForKey:@"nextPage"];
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

//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController

- (SlikovnicaDataViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(SlikovnicaDataViewController *)viewController
{
//    self.nextPage = viewController.page;
//    [self.book preloadPageNumber:[NSNumber numberWithInt:viewController.view.tag - 2]];
    return [self viewControllerAtIndex:viewController.view.tag - 1 storyboard:viewController.storyboard];
}

//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
- (SlikovnicaDataViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(SlikovnicaDataViewController *)viewController
{
//    self.previousPage = viewController.page;
//    [self.book preloadPageNumber:[NSNumber numberWithInt:viewController.view.tag + 2]];
    return [self viewControllerAtIndex:viewController.view.tag + 1 storyboard:viewController.storyboard];
}

@end
