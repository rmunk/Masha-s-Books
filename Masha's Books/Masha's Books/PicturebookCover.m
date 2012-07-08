//
//  PicturebookCoverView.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicturebookCover.h"



@implementation PicturebookCover

@synthesize bookForCover;

- (id)initWithFrame:(CGRect)frame andBook:(Book *)book {
    self = [super initWithFrame:frame];
    if (self) {
        bookForCover = book;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
