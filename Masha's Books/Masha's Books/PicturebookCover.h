//
//  PicturebookCoverView.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicturebookInfo.h"
#import "Book.h"

@interface PicturebookCover : UIButton

@property (nonatomic, weak) Book *bookForCover;

- (id)initWithFrame:(CGRect)frame andBook:(Book *)book;


@end
