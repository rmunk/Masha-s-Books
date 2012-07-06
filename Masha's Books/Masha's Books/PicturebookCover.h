//
//  PicturebookCoverView.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicturebookInfo.h"

@interface PicturebookCover : UIButton

@property (nonatomic, strong) PicturebookInfo *pbInfo;
@property (nonatomic, strong) NSNumber *bookID;
@property (nonatomic, strong) UIImage *bookCoverThumbnail;

- (id)initWithFrame:(CGRect)frame AndPicturebookInfo:(PicturebookInfo *)info;
- (id)initWithFrame:(CGRect)frame bookID:(NSNumber *)pbID andBookCoverThumbnail:(UIImage *)pbCoverThumbnail;

@end
