//
//  PicturebookCoverView.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface PicturebookCover : UIButton

@property (nonatomic, strong) Book *bookForCover;
@property (nonatomic, strong) UIProgressView *taskProgress;
@property (nonatomic, strong) UIImageView *bookStatus;
//@property (nonatomic, strong) UIActivityIndicatorView *bookExtractionActivityIndicator;

- (id)initWithFrame:(CGRect)frame andBook:(Book *)book;


@end
