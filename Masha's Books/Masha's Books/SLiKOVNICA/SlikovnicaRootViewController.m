//
//  SlikovnicaRootViewController.m
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlikovnicaRootViewController.h"
#import "SlikovnicaModelController.h"
#import "SlikovnicaNavigationViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SlikovnicaRootViewController ()<AVAudioPlayerDelegate, SlikovnicaNavigationViewControllerDelegate>
@property (strong, nonatomic) SlikovnicaNavigationViewController *slikovnicaNavigationViewController;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UIView *navigationRequestView;
@end

@implementation SlikovnicaRootViewController

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;
@synthesize audioPlayer = _audioPlayer;
@synthesize navigationRequestView = _navigationRequestView;
@synthesize slikovnicaNavigationViewController = _slikovnicaNavigationViewController;

- (AVAudioPlayer *)audioPlayer{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    SlikovnicaDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageViewController.dataSource = self.modelController;
    //self.pageViewController.delegate = self.modelController;
    
    [self addChildViewController:self.pageViewController];
    [self.view insertSubview:self.pageViewController.view belowSubview:self.navigationRequestView];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    
    // Start sound on first page
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:startingViewController.page.sound error:&error];
    if(error) self.audioPlayer = nil;
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.slikovnicaNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
    self.slikovnicaNavigationViewController.view.frame = self.view.bounds;
    self.slikovnicaNavigationViewController.pageImages = [self.modelController getPageThumbnails];
    self.slikovnicaNavigationViewController.delegate = self;
    self.slikovnicaNavigationViewController.bookNameLabel.title = self.modelController.book.title;
    
    [self addChildViewController:self.slikovnicaNavigationViewController];
    [self.view insertSubview:self.slikovnicaNavigationViewController.view atIndex:0];
    [self.slikovnicaNavigationViewController didMoveToParentViewController:self];

    [self.audioPlayer play];
}

- (void)NavigationController:(SlikovnicaNavigationViewController *)sender DidChoosePage:(NSInteger)page
{
    if (page >= 0) {
        SlikovnicaDataViewController *nextViewController = [self.modelController viewControllerAtIndex:(page) storyboard:self.storyboard];
        NSArray *viewControllers = [NSArray arrayWithObject:nextViewController];
        
        NSError *error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:nextViewController.page.sound error:&error];
        if(error) self.audioPlayer = nil;
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        
        void(^playSoundWhenPageIsTurned)(BOOL);
        
        playSoundWhenPageIsTurned = ^(BOOL finished)
        {
            if (finished)
            {
                [self.audioPlayer play];
            }
        };
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:playSoundWhenPageIsTurned];        
    }
    else [self.audioPlayer play];

    [self.view sendSubviewToBack:self.slikovnicaNavigationViewController.view];
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (IBAction)userTappedForNavigation:(UITapGestureRecognizer *)sender 
{
    [self.audioPlayer pause];
    SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    self.slikovnicaNavigationViewController.currentPage = [currentViewController.page.pageNumber intValue];
    [self.view bringSubviewToFront:self.slikovnicaNavigationViewController.view];
    self.view.gestureRecognizers = NULL;
}

- (void)viewDidUnload
{
    [self setNavigationRequestView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (SlikovnicaModelController *)modelController
{
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[SlikovnicaModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) 
    {
        SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        NSLog(@"Flip: %@", currentViewController.description);
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:currentViewController.page.sound error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
    else 
    {
//        SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
//        int *numPages = (int)self.modelController.book.pages.count;
//        
//        if (currentViewController.page.pageNumber < self.modelController.book.pages.count - 1) {
//            SlikovnicaDataViewController *nextViewController = [self.modelController viewControllerAtIndex:(currentViewController.page.pageNumber + 1) storyboard:self.storyboard];
//            NSArray *viewControllers = [NSArray arrayWithObject:nextViewController];
//            
//            NSURL *soundURL = [[NSURL alloc] initFileURLWithPath:nextViewController.page.sound];
//            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
//            self.audioPlayer.delegate = self;
//            [self.audioPlayer prepareToPlay];
//            
//            void(^playSoundWhenPageIsTurned)(BOOL);
//            
//            playSoundWhenPageIsTurned = ^(BOOL finished)
//            {
//                if (finished)
//                {
//                    [self.audioPlayer play];
//                }
//            };
//            
//            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:playSoundWhenPageIsTurned];
//        }
//        else [self.audioPlayer play];
    }
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

@end
