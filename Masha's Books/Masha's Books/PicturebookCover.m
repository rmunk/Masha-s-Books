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
@synthesize bookQuedIndicator = _bookQuedIndicator;

- (id)initWithFrame:(CGRect)frame andBook:(Book *)book withTarget:(id)target withAction:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        self.bookForCover = book;
        
        // initialize book cover button
        [self setImage:book.coverThumbnailImage forState:UIControlStateNormal];
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        
        // initialize status image
        NSString *imageName = [[NSBundle mainBundle] pathForResource:@"green_check" ofType:@"png"];
        UIImage *imageObj = [[UIImage alloc] initWithContentsOfFile:imageName];        
        CGRect statusImageFrame = CGRectMake(frame.size.height * 0.9, frame.size.height * 0.1, 20, 20);
        
        self.bookStatus = [[UIImageView alloc] initWithFrame:statusImageFrame];
        self.bookStatus.image = imageObj;        
        self.bookStatus.alpha = 0;
        
        [self addSubview:self.bookStatus];
        
        
        // initialize cover progress bar
        CGRect progFrame = CGRectMake(0, frame.size.height * 0.9, frame.size.width, 10);
        
        self.taskProgress = [[UIProgressView alloc] initWithFrame:progFrame];
        self.taskProgress.progress = 0;
        self.taskProgress.alpha = 0;        
        
        [self addSubview:self.taskProgress];
        
        
        // initialize qued activity indicator
        CGRect activityFrame = CGRectMake(frame.size.height * 0.4, frame.size.height * 0.4, frame.size.height * 0.2, frame.size.height * 0.2);
        
        self.bookQuedIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.bookQuedIndicator setFrame:activityFrame];
        [self addSubview:self.bookQuedIndicator];
        
                
        if ([book.downloaded isEqualToNumber:[NSNumber numberWithInt:1]]) {
            self.bookStatus.alpha = 1;            
        }
        else if ([book.status isEqualToString:@"qued"]) {
            self.imageView.alpha = 0.4;
            [self.bookQuedIndicator startAnimating];
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
