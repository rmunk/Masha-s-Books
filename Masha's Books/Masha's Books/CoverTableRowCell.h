//
//  CoverTableRowCell.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicturebookCover.h"

@interface CoverTableRowCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withWidthOf:(NSInteger)width
    desiredDistanceBetweenCovers:(NSInteger)distance andPictureBookCovers:(NSOrderedSet *)pbCovers;

- (id)initWithFrame:(CGRect)frame withWidthOf:(NSInteger)width desiredDistanceBetweenCovers:(NSInteger)distance 
andPictureBookCovers:(NSOrderedSet *)pbCovers withTarget:(id)target withAction:(SEL)action;

@end
