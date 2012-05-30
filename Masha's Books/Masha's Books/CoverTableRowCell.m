    //
//  CoverTableRowCell.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoverTableRowCell.h"

@implementation CoverTableRowCell

@synthesize cellHeight = _cellHeight;

- (id)initWithFrame:(CGRect)frame withNumberOfCoversInRow:(NSInteger)numOfCovers withWidthOf:(NSInteger)width desiredDistanceBetweenCovers:(NSInteger)distance 
andPictureBookCovers:(NSArray *)pbCovers withTarget:(id)target withAction:(SEL)action;     
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //ld - cover image width and height
        CGFloat ld = 0.;
        
        ld = (width - (numOfCovers + 1.0) * distance) / numOfCovers; 
        int numOfExistingCovers = pbCovers.count;
        
        _cellHeight = ld + distance;
        
        for (int i = 0; i < numOfExistingCovers; i++) {
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
