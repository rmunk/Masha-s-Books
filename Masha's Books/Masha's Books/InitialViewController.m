//
//  InitialViewController.m
//  Masha's Books
//
//  Created by Ranko Munk on 9/14/12.
//
//

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMashasBookstore:) name:@"DatabaseLoaded" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
  //  [self startMashasBookstore];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DatabaseLoaded" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)startMashasBookstore:(NSNotification *)notification {
    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    MBDatabase *database = (MBDatabase *)notification.object;
    
    NSLog(@"Number of tabbarcontroller subviews is %d", tabBarController.viewControllers.count);
    for (UIViewController *controller in tabBarController.viewControllers) {
        if ([controller respondsToSelector:@selector(setMBD:)]) {
            [controller performSelector:@selector(setMBD:) withObject:database];
        }
        else {
            NSLog(@"Controller %@ does not respond to setMBD", controller.title);
        }
    }
    
    [self presentViewController:tabBarController animated:YES completion:nil];
}

@end
