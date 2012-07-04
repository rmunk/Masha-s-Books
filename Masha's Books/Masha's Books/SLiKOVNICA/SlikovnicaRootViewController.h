//
//  SlikovnicaRootViewController.h
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlikovnicaDataViewController.h"

@interface SlikovnicaRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (readonly, strong, nonatomic) SlikovnicaModelController *modelController;

@end
