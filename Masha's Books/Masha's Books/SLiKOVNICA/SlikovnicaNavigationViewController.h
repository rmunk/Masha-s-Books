//
//  SlikovnicaNavigationViewController.h
//  My Way
//
//  Created by Ranko Munk on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlikovnicaNavigationViewController;
@class SlikovnicaModelController;

@protocol SlikovnicaNavigationViewControllerDelegate <NSObject>

- (void)navigationController:(SlikovnicaNavigationViewController *)sender DidChoosePage:(NSInteger)page;

@optional
- (void)navigationController:(SlikovnicaNavigationViewController *)sender SetTextVisibility:(BOOL)textVisibility;
- (void)navigationController:(SlikovnicaNavigationViewController *)sender SetVoiceoverPlay:(BOOL)voiceOverPlay;

@end

@interface SlikovnicaNavigationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookNameLabel;
@property (nonatomic, copy) NSArray *pageImages;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL textVisibility;
@property (nonatomic) BOOL voiceOverPlay;
@property id<SlikovnicaNavigationViewControllerDelegate> delegate;

@end
