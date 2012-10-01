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
#import "AVAudioPlayer+PGFade.h"

@interface SlikovnicaRootViewController ()<AVAudioPlayerDelegate, SlikovnicaNavigationViewControllerDelegate>
@property (retain, nonatomic) SlikovnicaNavigationViewController *slikovnicaNavigationViewController;
@property (strong, nonatomic) IBOutlet UIView *navigationRequestView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *navigationTapGestureRecognizer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerMusic;
@property (strong, nonatomic) SlikovnicaDataViewController *currentPage;
@end

@implementation SlikovnicaRootViewController

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;
@synthesize navigationRequestView = _navigationRequestView;
@synthesize slikovnicaNavigationViewController = _slikovnicaNavigationViewController;
@synthesize audioPlayerMusic = _audioPlayerMusic;
@synthesize navigationTapGestureRecognizer = _navigationTapGestureRecognizer;
@synthesize currentPage = _currentPage;
@synthesize delegate = _delegate;

#ifdef HACKINTOSH
- (AVAudioPlayer *)audioPlayerMusic{return nil;}
#endif

#pragma mark - Data Model

- (SlikovnicaModelController *)modelController
{
    if (!_modelController) {
        _modelController = [[SlikovnicaModelController alloc] init];
    }
    return _modelController;
}

- (void)setCurrentPage:(SlikovnicaDataViewController *)currentPage
{
    self.modelController.currentPage = currentPage;
    if (currentPage != [self.pageViewController.viewControllers objectAtIndex:0])
    {
        _currentPage = currentPage;
        NSArray *viewControllers = [NSArray arrayWithObject:currentPage];
        [self.pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:^(BOOL finished){
                                             [currentPage playAudio];
                                             if (currentPage.description == @"Last Page") self.navigationRequestView.hidden = YES;
                                             else self.navigationRequestView.hidden = NO;
                                             [self.modelController preloadPreviousAndNexPage];
                                         }];
    }
    else
    {
        _currentPage = currentPage;
        [currentPage playAudio];
        if (currentPage.description == @"Last Page") self.navigationRequestView.hidden = YES;
        else self.navigationRequestView.hidden = NO;
        [self.modelController preloadPreviousAndNexPage];
    }
    NSLog(@"%@", self.currentPage.description);
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
                                             selector:@selector(readAgain:)
                                                 name:@"readAgain" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goBackToLibrary:)
                                                 name:@"goBackToLibrary" object:nil];
    
    self.slikovnicaNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
    self.slikovnicaNavigationViewController.view.frame = self.view.bounds;
    self.slikovnicaNavigationViewController.pageImages = [self.modelController getPageThumbnails];
    self.slikovnicaNavigationViewController.delegate = self;
    self.slikovnicaNavigationViewController.bookNameLabel.title = self.modelController.book.title;
    self.slikovnicaNavigationViewController.currentPage = 1;
    
    [self addChildViewController:self.slikovnicaNavigationViewController];
    [self.slikovnicaNavigationViewController didMoveToParentViewController:self];
    NSLog(@"Book loaded");
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.audioPlayerMusic play];
    self.currentPage = (SlikovnicaDataViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
}

- (void)viewDidUnload
{
    [self setNavigationRequestView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setNavigationTapGestureRecognizer:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - NavigationViewController delegate methods

- (IBAction)userTappedForNavigation:(UITapGestureRecognizer *)sender
{
    [self.currentPage pauseAudio];
    [self.audioPlayerMusic pauseWithFadeDuration:0.5];
    
    [self.view addSubview:self.slikovnicaNavigationViewController.view];
    
    self.slikovnicaNavigationViewController.currentPage = self.currentPage.view.tag;
    self.slikovnicaNavigationViewController.textVisible = self.modelController.textVisible;
    self.slikovnicaNavigationViewController.voiceOverPlay = self.modelController.voiceOverPlay;
    self.view.gestureRecognizers = NULL;
}

- (void)navigationController:(SlikovnicaNavigationViewController *)sender didChoosePage:(NSInteger)page
{
    if (page >= 0) {
        SlikovnicaDataViewController *nextViewController = [self.modelController viewControllerAtIndex:(page) storyboard:self.storyboard];
        self.currentPage = nextViewController;
    }
    else {
        [self.currentPage playAudio];
    }
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    [self.audioPlayerMusic play];
}

- (void)navigationController:(SlikovnicaNavigationViewController *)sender settextVisible:(BOOL)textVisible
{
    self.modelController.textVisible = textVisible;
    //    self.currentPage.textVisible = textVisible;
}

- (void)navigationController:(SlikovnicaNavigationViewController *)sender setVoiceoverPlay:(BOOL)voiceOverPlay
{
    self.modelController.voiceOverPlay = voiceOverPlay;
    //    self.currentPage.voiceOverPlay = voiceOverPlay;
}

- (void)navigationControllerClosedBook:(SlikovnicaNavigationViewController *)sender
{
    [self.modelController.book.managedObjectContext refreshObject:self.modelController.book mergeChanges:NO];
    [self.delegate slikovnicaRootViewController:self closedPictureBook:self.modelController.book];
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        self.currentPage = (SlikovnicaDataViewController *)[pageViewController.viewControllers objectAtIndex:0];
    }
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    NSArray *viewControllers = [NSArray arrayWithObject:self.currentPage];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}


#pragma mark - DataVievController notifications

- (void)pageVoiceOverDidFinishPlaying:(NSNotification *) notification
{
    self.currentPage = (SlikovnicaDataViewController *)[self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:self.currentPage];    
}

#pragma mark - Last page notifications

- (void)goBackToLibrary:(NSNotification *)notification
{
    [self.modelController.book.managedObjectContext refreshObject:self.modelController.book mergeChanges:NO];
    [self.delegate slikovnicaRootViewController:self closedPictureBook:self.modelController.book];
}

- (void)readAgain:(NSNotification *)notification
{
    self.currentPage = [self.modelController viewControllerAtIndex:1 storyboard:self.storyboard];
}

#pragma mark - AVAudioPlayer delegate methods

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error);
}

@end
