//
//  Design.h
//  Masha's Books
//
//  Created by Luka Miljak on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Design : NSManagedObject

@property (nonatomic, retain) NSData * bgImage;
@property (nonatomic, retain) NSString * bgImageURL;
@property (nonatomic, retain) NSData * bgMasha;
@property (nonatomic, retain) NSString * bgMashaURL;

@end
