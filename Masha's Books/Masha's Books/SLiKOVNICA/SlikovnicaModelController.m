//
//  SlikovnicaModelController.m
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlikovnicaModelController.h"
#import "SlikovnicaDataViewController.h"

/* 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@implementation SlikovnicaPage

@synthesize pageNumber = _pageNumber;
@synthesize image = _image;
@synthesize sound = _sound;

@end

@interface SlikovnicaModelController()
@property (readonly, strong, nonatomic) NSMutableArray *pageData;
@end

@implementation SlikovnicaModelController

@synthesize pageData = _pageData;

-(NSMutableArray *)pageData
{
    if(!_pageData) _pageData = [[NSMutableArray alloc] init];
    return _pageData;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        // Create the data model.
        NSArray *images = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
        int pageNumber = 0;
        for (int i=0; i<images.count; i++) {
            NSString *imageName = [[[images objectAtIndex:i] lastPathComponent] stringByDeletingPathExtension];
            if (![imageName hasSuffix:@"@2x"] && ![imageName hasSuffix:@"c"])
            {
                SlikovnicaPage *page = [[SlikovnicaPage alloc] init];
                page.pageNumber = [NSString stringWithFormat:@"%d", pageNumber++];
                page.image = [images objectAtIndex:i];
                page.sound = [[NSBundle mainBundle] pathForResource:imageName ofType:@"m4a"];
                [self.pageData addObject:page];
            }
        }
    }
    return self;
}

- (SlikovnicaDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    SlikovnicaDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"SlikovnicaDataViewController"];
    dataViewController.dataObject = [self.pageData objectAtIndex:index];
    dataViewController.pageNumber = index;
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(SlikovnicaDataViewController *)viewController
{   
     // Return the index of the given data view controller.
     // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}

- (NSUInteger)numberOfPages
{
    return self.pageData.count;
}

- (NSArray *)getPageThumbnails
{
    NSMutableArray *thumbnails = [[NSMutableArray alloc] init];
    
    for (SlikovnicaPage *page in self.pageData) {
        UIImage *thumbnail = [UIImage imageWithContentsOfFile:page.image];
  //      CGImageRef image = CGImageRetain(thumbnail.CGImage);
        
        [thumbnails addObject:thumbnail];

    }
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
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
