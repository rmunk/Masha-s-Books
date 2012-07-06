//
//  PicturebookCoverView.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicturebookCover.h"

@implementation PicturebookCover

@synthesize pbInfo = _pbInfo;
@synthesize bookID = _bookID;
@synthesize bookCoverThumbnail = _bookCoverThumbnail;

- (id)initWithFrame:(CGRect)frame AndPicturebookInfo:(PicturebookInfo *)info
{
    _pbInfo = [[PicturebookInfo alloc] init];
    self = [super initWithFrame:frame];
    if (self) {

        _pbInfo = info;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame bookID:(NSNumber *)pbID andBookCoverThumbnail:(UIImage *)pbCoverThumbnail {

    self = [super initWithFrame:frame];
    if (self) {
        _bookID = [NSNumber numberWithInt:[pbID intValue]];
        _bookCoverThumbnail = [pbCoverThumbnail copy];
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
