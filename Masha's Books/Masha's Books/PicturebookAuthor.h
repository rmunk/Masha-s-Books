//
//  PicturebookAuthors.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicturebookAuthor : NSObject

@property (readwrite) NSInteger iD;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *websiteUrl;
@property (nonatomic, strong) NSString *bioHtml;

@end
