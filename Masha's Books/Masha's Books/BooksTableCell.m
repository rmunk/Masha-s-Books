//
//  BooksTableCell.m
//  Masha's Books
//
//  Created by Luka Miljak on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BooksTableCell.h"

@interface BooksTableCell()
@property (nonatomic, strong) UIImageView *bookCover;
@property (nonatomic, strong) UIWebView *bookDescription;
@end

@implementation BooksTableCell

@synthesize cellHeight = _cellHeight;
@synthesize bookCover = _bookCover;
@synthesize bookDescription = _bookDescription;

- (id)initWithFrame:(CGRect)frame forBook:(Book *)book {
    
    self = [super initWithFrame:frame];

    if (self) {
        
        
        // Adding book thumbnail
        CGRect bookCoverImageFrame = CGRectMake(frame.size.width * 0.03, frame.size.height * 0.05, frame.size.width * 0.55, frame.size.height * 0.9);
    
        self.bookCover = [[UIImageView alloc] initWithFrame:bookCoverImageFrame];
        self.bookCover.image = [book.coverThumbnailImage copy];
        
        [self addSubview:self.bookCover];
        
        // Adding book description
        CGRect bookDescriptionFrame = CGRectMake(frame.size.width * 0.6, frame.size.height * 0.05, frame.size.width * 0.35, frame.size.height * 0.9);
        
        self.bookDescription = [[UIWebView alloc] initWithFrame:bookDescriptionFrame];
        [self.bookDescription setBackgroundColor:[UIColor clearColor]];
        [self.bookDescription setOpaque:NO];
        [self.bookDescription loadHTMLString:book.descriptionHTML baseURL:nil];
        
        //[self.contentView setBackgroundColor:[UIColor darkGrayColor]];
        //[self.contentView setAlpha:0.3];
        //[self.contentView setOpaque:NO];
        
        [self addSubview:self.bookDescription];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
