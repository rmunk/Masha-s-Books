//
//  SlikovnicaNavigationViewController.h
//  My Way
//
//  Created by Ranko Munk on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlikovnicaNavigationViewController;

@protocol SlikovnicaNavigationViewControllerDelegate <NSObject>

- (void)NavigationController:(SlikovnicaNavigationViewController *)sender DidChoosePage:(NSInteger)page;

@end

@interface SlikovnicaNavigationViewController : UIViewController

@property (nonatomic, copy) NSArray *pageImages;
@property (nonatomic) NSInteger currentPage;
@property id<SlikovnicaNavigationViewControllerDelegate> delegate;

@end
