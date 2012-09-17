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
@end

@implementation SlikovnicaModelController

@synthesize book = _book;
@synthesize textVisibility = _textVisibility;
@synthesize voiceOverPlay = _voiceOverPlay;
@synthesize numberOfPages = _numberOfPages;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.textVisibility = TRUE;
        self.voiceOverPlay = TRUE;
    }
    return self;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (([self.book.pages count] == 0) || (index > [self.book.pages count])) {
        return nil;
    }
    
    if (index == self.numberOfPages) return [storyboard instantiateViewControllerWithIdentifier:@"LastPage"];
    
    
    // Create a new view controller and pass suitable data.
    SlikovnicaDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"SlikovnicaDataViewController"];
    dataViewController.page = [self.book.pages objectAtIndex:index];
    dataViewController.textVisibility = self.textVisibility;
    dataViewController.voiceOverPlay = self.voiceOverPlay;
    
    [self.book.managedObjectContext refreshObject:self.book mergeChanges:NO];
    
    //    Page *preloadNextPage = [self.book.pages objectAtIndex:index + 1];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(SlikovnicaDataViewController *)viewController
{
    // Return the index of the given data view controller.
    if([self.book.pages indexOfObject:viewController.page] != NSNotFound)
        return [self.book.pages indexOfObject:viewController.page];
    else
        return self.book.pages.count;
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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SlikovnicaDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SlikovnicaDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
