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

@property (readonly) CGFloat cellHeight;

- (id)initWithFrame:(CGRect)frame withNumberOfCoversInRow:(NSInteger)numOfCovers withWidthOf:(NSInteger)width desiredDistanceBetweenCovers:(NSInteger)distance 
andPictureBookCovers:(NSOrderedSet *)pbCovers withTarget:(id)target withAction:(SEL)action;

@end
