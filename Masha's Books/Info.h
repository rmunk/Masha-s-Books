//
//  Info.h
//  Masha's Books
//
//  Created by Luka Miljak on 8/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Info : NSManagedObject

@property (nonatomic, retain) NSString * appVer;
@property (nonatomic, retain) NSString * appStoreURL;
@property (nonatomic, retain) NSString * websiteURL;
@property (nonatomic, retain) NSString * facebookURL;
@property (nonatomic, retain) NSString * twitterURL;
@property (nonatomic, retain) NSString * contactURL;

@end
