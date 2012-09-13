//
//  Design.h
//  Masha's Books
//
//  Created by Ranko Munk on 9/13/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Design : NSManagedObject

@property (nonatomic, retain) NSData * bgImage;
@property (nonatomic, retain) NSString * bgImageURL;
@property (nonatomic, retain) NSData * bgMasha;
@property (nonatomic, retain) NSString * bgMashaURL;

@end
