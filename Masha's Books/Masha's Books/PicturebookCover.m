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
//@synthesize bookExtractionActivityIndicator = _bookExtractionActivityIndicator;

- (id)initWithFrame:(CGRect)frame andBook:(Book *)book {
    self = [super initWithFrame:frame];
    if (self) {
        _bookForCover = book;
        
        CGRect progFrame = CGRectMake(0, frame.size.height * 0.9, frame.size.width, 10);
        
        NSString *imageName = [[NSBundle mainBundle] pathForResource:@"green_check" ofType:@"png"];
        UIImage *imageObj = [[UIImage alloc] initWithContentsOfFile:imageName];
        
        CGRect statusImageFrame = CGRectMake(frame.size.height * 0.9, frame.size.height * 0.1, 20, 20);
        _bookStatus = [[UIImageView alloc] initWithFrame:statusImageFrame];
        
        _taskProgress = [[UIProgressView alloc] initWithFrame:progFrame];
     //   _bookExtractionActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        _taskProgress.progress = 0;
        _taskProgress.alpha = 0;        
        [self addSubview:_taskProgress];
        
        
        _bookStatus.image = imageObj;        
        _bookStatus.alpha = 0;
        [self addSubview:_bookStatus];
      //  [self addSubview:_bookExtractionActivityIndicator];
        //[_bookExtractionActivityIndicator startAnimating];
        
        
        NSLog(@"Book %@.downloaded = %d", book.title, [book.downloaded intValue]);
        if ([book.downloaded isEqualToNumber:[NSNumber numberWithInt:1]]) {
            _bookStatus.alpha = 1;            
        }
       
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
