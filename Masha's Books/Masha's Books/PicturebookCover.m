//
//  PicturebookCoverView.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicturebookCover.h"

@implementation PicturebookCover

@synthesize bookForCover = _bookForCover;
@synthesize taskProgress = _taskProgress;
@synthesize bookStatus = _bookStatus;

- (id)initWithFrame:(CGRect)frame andBook:(Book *)book {
    self = [super initWithFrame:frame];
    if (self) {
        _bookForCover = book;
        
        CGRect progFrame = CGRectMake(0, frame.size.height * 0.9, frame.size.width, 10);
        CGRect statusImageFrame = CGRectMake(frame.size.height * 0.9, frame.size.height * 0.1, 20, 20);
        NSString *imageName = [[NSBundle mainBundle] pathForResource:@"green_check" ofType:@"png"];
        UIImage *imageObj = [[UIImage alloc] initWithContentsOfFile:imageName];
        _taskProgress = [[UIProgressView alloc] initWithFrame:progFrame];
        _bookStatus = [[UIImageView alloc] initWithFrame:statusImageFrame];
        _bookStatus.image = imageObj;
        _bookStatus.alpha = 0;
        _taskProgress.alpha = 0;
        [self addSubview:_taskProgress];
        [self addSubview:_bookStatus];
        NSLog(@"Cover for book %@ initialized", book.title);
        
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
