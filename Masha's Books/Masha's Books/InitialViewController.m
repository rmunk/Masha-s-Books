//
//  InitialViewController.m
//  Masha's Books
//
//  Created by Ranko Munk on 9/14/12.
//
//

#import "InitialViewController.h"

@interface InitialViewController ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"Initial view controller: Registering for DatabaseLoaded notification");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMashasBookstore:) name:@"DatabaseLoaded" object:nil];
    
    self.reachability = [Reachability reachabilityWithHostname:@"www.mashasbookstore.com"];
    
    if (self.reachability.currentReachabilityStatus == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet to use Mashas's Shop"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkReachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [self.reachability startNotifier];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DatabaseLoaded" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)networkReachabilityDidChange:(NSNotification *)notification {
    Reachability *reachability = ( Reachability * )[notification object];
    if ( reachability.currentReachabilityStatus != NotReachable ) {
        NSLog(@"Network status: %@", reachability.currentReachabilityString);
    } else {
        NSLog(@"Network status: %@", reachability.currentReachabilityString);
    }
}

- (void)startMashasBookstore:(NSNotification *)notification {
    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [tabBarController setDelegate:self];
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
    
    NSLog(@"Bought books number: %d   Network reachability: %@", [database getMyBooks].count, self.reachability.currentReachabilityString);
    if ([database getMyBooks].count == 0 && self.reachability.currentReachabilityStatus != 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No books in library"
                                                        message:@"Your library contain no books. You can use Masha's Shop to fill your library with books."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        for (int i = 0; i < tabBarController.viewControllers.count; i++) {
            if ([((UIViewController *)[tabBarController.viewControllers objectAtIndex:i]).title isEqualToString:@"Shop View Controller"]) {
                NSLog(@"Redirecting to Masha's shop");
                [tabBarController setSelectedIndex:i];
            }
        }
    }
    
    [self performSelector:@selector(presentTabViewController:) withObject:tabBarController afterDelay:0.5];
    
}

- (void)presentTabViewController:(UITabBarController *)tabBarController  {
    [self presentViewController:tabBarController animated:YES completion:nil];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if ([viewController.title isEqualToString:@"My Books View Controller"]) {
        return YES;
    }
    
    else if ([viewController.title isEqualToString:@"Shop View Controller"]) {
        if (self.reachability.currentReachabilityStatus == 0) {
            NSLog(@"Network status: %@", self.reachability.currentReachabilityString);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                            message:@"You must be connected to the internet to use Mashas's Shop"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else {
            return YES;
        }
    }
    
    else if ([viewController.title isEqualToString:@"Settings View Controller"]) {
        return YES;
    }
    
    return YES;

}

@end
