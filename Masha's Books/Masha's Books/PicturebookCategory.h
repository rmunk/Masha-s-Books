//
//  PicturebookCategory.h
//  PicturebookShop
//
//  Created by Luka Miljak on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicturebookCategory : NSObject

@property (readwrite) NSInteger iD;
@property (nonatomic, strong) NSString *name;

- (PicturebookCategory *)initWithName:(NSString *)name AndID:(NSInteger)tag;
    

@end
