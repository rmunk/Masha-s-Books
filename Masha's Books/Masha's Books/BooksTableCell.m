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
@synthesize coverImage = _slikica;
@synthesize bookTitle = _bookTitle;
@synthesize shortDescription = _shortDescription;
@synthesize bookCover = _bookCover;
@synthesize bookDescription = _bookDescription;
@synthesize rateImage = _rateImage;
@synthesize tagImage = _tagImage;
@synthesize activityView = _activityView;
@synthesize transparencyView = _transparencyView;
@synthesize statusLabel = _statusLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Adding background image
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
        self.backgroundView.contentMode = UIViewContentModeTopLeft;
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_sel"]];
        self.selectedBackgroundView.contentMode = UIViewContentModeTopLeft;        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Adding background image
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
        self.backgroundView.contentMode = UIViewContentModeTopLeft;
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_sel"]];
        self.selectedBackgroundView.contentMode = UIViewContentModeTopLeft;        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame forBook:(Book *)book {
    
    self = [super initWithFrame:frame];

    if (self) {
        
//        // Adding background image
//        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
//        self.backgroundView.contentMode = UIViewContentModeTopLeft;
//        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_sel"]];
//        self.selectedBackgroundView.contentMode = UIViewContentModeTopLeft;
//
//        
//        // Adding book thumbnail
//        CGRect bookCoverImageFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width * 0.55, frame.size.height * 0.5);
//    
//        self.bookCover = [[UIImageView alloc] initWithFrame:bookCoverImageFrame];
//        self.bookCover.image = [book.coverThumbnailImage copy];
//        
//        [self addSubview:self.bookCover];
//        
//        // Adding book description
//        CGRect bookDescriptionFrame = CGRectMake(frame.size.width * 0.6, frame.size.height * 0.05, frame.size.width * 0.35, frame.size.height * 0.9);
//        
//        self.bookDescription = [[UIWebView alloc] initWithFrame:bookDescriptionFrame];
//        [self.bookDescription setBackgroundColor:[UIColor clearColor]];
//        [self.bookDescription setOpaque:NO];
//        [self.bookDescription loadHTMLString:book.descriptionHTML baseURL:nil];
//        
//        //[self.contentView setBackgroundColor:[UIColor darkGrayColor]];
//        //[self.contentView setAlpha:0.3];
//        //[self.contentView setOpaque:NO];
//        
//        [self addSubview:self.bookDescription];
//
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        
//        
//        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
