//
//  Picturebook.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicturebookInfo : NSObject

@property (readwrite) NSInteger catID;       
@property (readwrite) NSInteger iD;
@property (nonatomic, strong) NSString *title; 
@property (readwrite) NSInteger appStoreID;         
@property (readwrite) NSInteger authorID;      
@property (nonatomic, strong) NSDate *publishDate;  
@property (nonatomic, strong) NSURL *downloadUrl;
@property (nonatomic, strong) NSURL *facebookLikeUrl;
@property (nonatomic, strong) NSURL *youTubeVideoUrl;
@property (nonatomic, strong) NSString *descriptionHTML;
@property (nonatomic, strong) NSString *descriptionLongHTML;


@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) UIImage *coverThumbnailImage;

@end
