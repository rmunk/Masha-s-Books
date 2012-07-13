    //
//  CoverTableRowCell.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoverTableRowCell.h"
@interface CoverTableRowCell()
@property (nonatomic, strong) NSMutableArray *coversInRowMutable;
@end


@implementation CoverTableRowCell


@synthesize cellHeight = _cellHeight;
@synthesize coversInRow = _coversInRow;
@synthesize coversInRowMutable = _coversInRowMutable;


- (id)initWithFrame:(CGRect)frame withNumberOfCoversInRow:(NSInteger)numOfCovers withWidthOf:(NSInteger)width desiredDistanceBetweenCovers:(NSInteger)distance 
           forBooks:(NSOrderedSet *)books withTarget:(id)target withAction:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.coversInRowMutable = [[NSMutableArray alloc] init];
        //ld - cover image width and height
        CGFloat ld = 0.;
        
        ld = (width - (numOfCovers + 1.0) * distance) / numOfCovers; 
        int numOfExistingCovers = books.count;
        
        _cellHeight = ld + distance;
        
        for (int i = 0; i < numOfExistingCovers; i++) {
            CGRect frame = CGRectMake(((distance + ld) * i + distance), distance, ld, ld);
            
            UIImage *bookCoverImage = ((Book *)[books objectAtIndex:i]).coverThumbnailImage;
    
            PicturebookCover *pbCover = [[PicturebookCover alloc] initWithFrame:frame 
                                                                        andBook:[books objectAtIndex:i]];
                                         
            [pbCover setImage:bookCoverImage forState:UIControlStateNormal];
            [pbCover addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:pbCover];
            pbCover.contentMode = UIViewContentModeScaleAspectFit;
            
            
            [self.coversInRowMutable addObject:pbCover];
            
        }   
        
        self.coversInRow = [[NSArray alloc] initWithArray:[self.coversInRowMutable copy]];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
