    //
//  CoverTableRowCell.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoverTableRowCell.h"

@implementation CoverTableRowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withWidthOf:(NSInteger)width desiredDistanceBetweenCovers:(NSInteger)distance andPictureBookCovers:(NSArray *)pbCovers     
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat ld = 0.;
        int numOfCovers = pbCovers.count;
        
        ld = (width - (numOfCovers + 1.0) * distance) / numOfCovers; 
        
        for (int i = 0; i < numOfCovers; i++) {
            CGRect frame = CGRectMake(((distance + ld) * i + distance), distance, ld, ld);
            PicturebookInfo *pbInfo = [[PicturebookInfo alloc] init];
            pbInfo = [pbCovers objectAtIndex:i];
            PicturebookCover *pbCover = [[PicturebookCover alloc] initWithFrame:frame AndPicturebookInfo:pbInfo];
            [pbCover setImage:pbInfo.coverImage forState:UIControlStateNormal];
            [pbCover addTarget:self action:@selector(shopItemTapped:) forControlEvents:UIControlEventTouchUpInside];
            //iView1.titleLabel.text = pbInfo.title;
            [self.contentView addSubview:pbCover];
            pbCover.contentMode = UIViewContentModeScaleAspectFit;
            
        }
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withWidthOf:(NSInteger)width desiredDistanceBetweenCovers:(NSInteger)distance 
    andPictureBookCovers:(NSArray *)pbCovers withTarget:(id)target withAction:(SEL)action;     
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat ld = 0.;
        int numOfCovers = pbCovers.count;
        
        ld = (width - (numOfCovers + 1.0) * distance) / numOfCovers; 
        
        for (int i = 0; i < numOfCovers; i++) {
            CGRect frame = CGRectMake(((distance + ld) * i + distance), distance, ld, ld);
            PicturebookInfo *pbInfo = [[PicturebookInfo alloc] init];
            pbInfo = [pbCovers objectAtIndex:i];
            PicturebookCover *pbCover = [[PicturebookCover alloc] initWithFrame:frame AndPicturebookInfo:pbInfo];
            [pbCover setImage:pbInfo.coverImage forState:UIControlStateNormal];
            [pbCover addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            //iView1.titleLabel.text = pbInfo.title;
            [self.contentView addSubview:pbCover];
            pbCover.contentMode = UIViewContentModeScaleAspectFit;
            
        }
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
