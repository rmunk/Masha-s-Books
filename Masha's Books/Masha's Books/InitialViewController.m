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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMashasBookstore) name:@"DatabaseLoaded" object:nil];
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

- (void)startMashasBookstore
{
    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:tabBarController animated:YES completion:nil];
}

@end
