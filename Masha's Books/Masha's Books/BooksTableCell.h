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

- (id)initWithFrame:(CGRect)frame forBook:(Book *)book;

@end
