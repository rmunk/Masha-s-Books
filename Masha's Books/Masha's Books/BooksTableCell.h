//
//  BooksTableCell.h
//  Masha's Books
//
//  Created by Luka Miljak on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BooksTableCell : UITableViewCell

@property (readonly) CGFloat cellHeight;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIImageView *tagImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateImage;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UITextView *shortDescription;
@property (weak, nonatomic) IBOutlet UIView *transparencyView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (id)initWithFrame:(CGRect)frame forBook:(Book *)book;

@end
