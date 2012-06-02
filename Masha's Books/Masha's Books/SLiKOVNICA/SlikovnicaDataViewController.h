//
//  SlikovnicaDataViewController.h
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlikovnicaModelController.h"

@interface SlikovnicaDataViewController : UIViewController

@property (strong, nonatomic) id dataObject;
@property (readonly, nonatomic) SlikovnicaPage *page;
@property (nonatomic) NSUInteger pageNumber;


@end
