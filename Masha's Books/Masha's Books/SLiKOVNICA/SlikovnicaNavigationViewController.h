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

- (void)navigationController:(SlikovnicaNavigationViewController *)sender didChoosePage:(NSInteger)page;
- (void)navigationControllerClosedBook:(SlikovnicaNavigationViewController *)sender;

@optional
- (void)navigationController:(SlikovnicaNavigationViewController *)sender settextVisible:(BOOL)textVisible;
- (void)navigationController:(SlikovnicaNavigationViewController *)sender setVoiceoverPlay:(BOOL)voiceOverPlay;

@end

@interface SlikovnicaNavigationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookNameLabel;
@property (nonatomic, copy) NSArray *pageImages;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL textVisible;
@property (nonatomic) BOOL voiceOverPlay;
@property (nonatomic, assign) id<SlikovnicaNavigationViewControllerDelegate> delegate;

@end
