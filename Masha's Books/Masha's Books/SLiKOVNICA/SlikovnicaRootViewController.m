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
#define HACKINTOSH

@interface SlikovnicaRootViewController ()<AVAudioPlayerDelegate, SlikovnicaNavigationViewControllerDelegate>
@property (retain, nonatomic) SlikovnicaNavigationViewController *slikovnicaNavigationViewController;
@property (strong, nonatomic) IBOutlet UIView *navigationRequestView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerMusic;
@end

@implementation SlikovnicaRootViewController

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;
@synthesize navigationRequestView = _navigationRequestView;
@synthesize slikovnicaNavigationViewController = _slikovnicaNavigationViewController;
@synthesize audioPlayerMusic = _audioPlayerMusic;
@synthesize delegate = _delegate;

#ifdef HACKINTOSH
- (AVAudioPlayer *)audioPlayerMusic{return nil;}
#endif

- (SlikovnicaModelController *)modelController
{
    if (!_modelController) {
        _modelController = [[SlikovnicaModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
        
    SlikovnicaDataViewController *startingViewController = [self.modelController viewControllerAtIndex:1 storyboard:self.storyboard];
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
    
    // Start background music
    NSError *error;
    self.audioPlayerMusic = [[AVAudioPlayer alloc] initWithData:self.modelController.book.backgroundMusic error:&error];
    if(error) self.audioPlayerMusic = nil;
    self.audioPlayerMusic.delegate = self;
    self.audioPlayerMusic.volume = 0.5;
    self.audioPlayerMusic.numberOfLoops = -1;
    [self.audioPlayerMusic prepareToPlay];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pageVoiceOverDidFinishPlaying:)
                                                 name:@"pageVoiceOverDidFinishPlaying" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFinishedBook:)
                                                 name:@"userFinishedBook" object:nil];
    
    self.slikovnicaNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
    self.slikovnicaNavigationViewController.view.frame = self.view.bounds;
    self.slikovnicaNavigationViewController.pageImages = [self.modelController getPageThumbnails];
    self.slikovnicaNavigationViewController.delegate = self;
    self.slikovnicaNavigationViewController.bookNameLabel.title = self.modelController.book.title;
    self.slikovnicaNavigationViewController.currentPage = 1;
    
    [self addChildViewController:self.slikovnicaNavigationViewController];
    //    [self.view addSubview:self.slikovnicaNavigationViewController.view];// insertSubview:self.slikovnicaNavigationViewController.view atIndex:0];
    [self.slikovnicaNavigationViewController didMoveToParentViewController:self];
    NSLog(@"Book loaded");
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.audioPlayerMusic play];
    SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [currentViewController playAudio];
}

- (void)viewDidUnload
{
    [self setNavigationRequestView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - NavigationViewController delegate methods
- (IBAction)userTappedForNavigation:(UITapGestureRecognizer *)sender 
{
    SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];

    [currentViewController pauseAudio];
    [self.audioPlayerMusic pause];

    [self.view addSubview:self.slikovnicaNavigationViewController.view];
    
    self.slikovnicaNavigationViewController.currentPage = [currentViewController.page.pageNumber intValue];
    self.slikovnicaNavigationViewController.bookNameLabel.title = self.modelController.book.title;
    self.slikovnicaNavigationViewController.textVisibility = self.modelController.textVisibility;
    self.slikovnicaNavigationViewController.voiceOverPlay = self.modelController.voiceOverPlay;
    self.view.gestureRecognizers = NULL;
    
    //    self.slikovnicaNavigationViewController.view.hidden = FALSE;
    //    [self.view bringSubviewToFront:self.slikovnicaNavigationViewController.view];
}

- (void)navigationController:(SlikovnicaNavigationViewController *)sender didChoosePage:(NSInteger)page
{
    if (page >= 0) {
        SlikovnicaDataViewController *nextViewController = [self.modelController viewControllerAtIndex:(page) storyboard:self.storyboard];
        NSArray *viewControllers = [NSArray arrayWithObject:nextViewController];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){if (finished) [nextViewController playAudio];}];        
    }
    else {
        SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        [currentViewController playAudio];
    }

    //    self.slikovnicaNavigationViewController.view.hidden = TRUE;
    //    [self.view sendSubviewToBack:self.slikovnicaNavigationViewController.view];
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    [self.audioPlayerMusic play];
}

- (void)navigationController:(SlikovnicaNavigationViewController *)sender setTextVisibility:(BOOL)textVisibility
{
    self.modelController.textVisibility = textVisibility;
    SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.modelController viewControllerAtIndex:[self.modelController indexOfViewController:currentViewController] storyboard:currentViewController.storyboard]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)navigationController:(SlikovnicaNavigationViewController *)sender setVoiceoverPlay:(BOOL)voiceOverPlay
{
    self.modelController.voiceOverPlay = voiceOverPlay;
    SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.modelController viewControllerAtIndex:[self.modelController indexOfViewController:currentViewController] storyboard:currentViewController.storyboard]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)navigationControllerClosedBook:(SlikovnicaNavigationViewController *)sender
{
    [self.delegate slikovnicaRootViewController:self closedPictureBook:self.modelController.book];
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) 
    {
        SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        if ([self.modelController indexOfViewController:currentViewController] == self.modelController.book.pages.count) {
            
        }
        else {
            [currentViewController playAudio];
            NSLog(@"Flip: %@", currentViewController.description);
        }
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


#pragma mark - DataVievController notifications

- (void)pageVoiceOverDidFinishPlaying:(NSNotification *) notification
{
    SlikovnicaDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    int currentPage = [self.modelController indexOfViewController:currentViewController];
    int numPages = (int)self.modelController.book.pages.count;
    
    if (currentPage < numPages - 1) {
        SlikovnicaDataViewController *nextViewController = [self.modelController viewControllerAtIndex:(currentPage + 1) storyboard:self.storyboard];
        NSArray *viewControllers = [NSArray arrayWithObject:nextViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){if (finished) [nextViewController playAudio];}];        
    }
}

- (void)userFinishedBook:(NSNotification *)notification
{
    //    self.pageViewController.view.hidden = TRUE;
    [self.delegate slikovnicaRootViewController:self closedPictureBook:self.modelController.book];
}

#pragma mark - AVAudioPlayer delegate methods

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

@end
