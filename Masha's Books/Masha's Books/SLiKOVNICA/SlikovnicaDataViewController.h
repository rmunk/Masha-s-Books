//
//  SlikovnicaDataViewController.h
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlikovnicaModelController.h"
#import "Page.h"

@interface SlikovnicaDataViewController : UIViewController
@property (nonatomic, strong) Page *page;
@property (nonatomic, assign, getter=isTextVisible) BOOL textVisible;
@property (nonatomic, assign) BOOL voiceOverPlay;

- (void)playAudio;
- (void)pauseAudio;
- (void)stopAudio;

@end
