//
//  Design.h
//  Masha's Books
//
//  Created by Luka Miljak on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Design : NSManagedObject

@property (nonatomic, retain) UIImage * bgImage;
@property (nonatomic, retain) NSString * bgImageURL;
@property (nonatomic, retain) UIImage * bgMasha;
@property (nonatomic, retain) NSString * bgMashaURL;

@end
