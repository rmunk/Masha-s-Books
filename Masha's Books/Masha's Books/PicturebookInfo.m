//
//  Picturebook.m
//  PicturebookShop
//
//  Created by Luka Miljak on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicturebookInfo.h"

@interface PicturebookInfo()

@property (nonatomic, strong) NSMutableOrderedSet *bookCats; // private set of book categories, mutable

@end

@implementation PicturebookInfo

@synthesize catID = _catID; 
@synthesize iD = _iD;
@synthesize title = _title; 
@synthesize appStoreID = _appStoreID;
@synthesize authorID = _authorID;
@synthesize publishDate = _publishDate;
@synthesize downloadUrl = _downloadUrl;
@synthesize facebookLikeUrl = _facebookLikeUrl;
@synthesize youTubeVideoUrl = _youTubeVideoUrl;
@synthesize descriptionHTML = _descriptionHTML;
@synthesize descriptionLongHTML = _descriptionLongHTML;

@synthesize coverImage = _coverImage;
@synthesize coverThumbnailImage = _coverThumbnailImage;
@synthesize bookCategories = _bookCategories;
@synthesize bookCats = _bookCats;

- (NSOrderedSet *)bookCategories {
    return [self.bookCats copy];
}

- (void)pickYourCategories:(NSOrderedSet *)allCategories {
    if (!self.bookCats) {
        self.bookCats = [[NSMutableOrderedSet alloc] init];
    }
    
    NSLog(@"Book %@ categories are:", self.title);
    
    for (PicturebookCategory *cat in allCategories) {
        for (NSNumber *iD in cat.booksInCategory) {
            if (iD.intValue == self.iD) {
                [self.bookCats addObject:cat];
                NSLog(@"    %@", cat.name);
            }
        }
    }
}

@end
