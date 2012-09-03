//
//  Design+Design_Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Design+Addon.h"

@implementation Design (Design_Addon)

+ (void)loadImages:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Design"];
    NSError *error;
    NSArray *designArray = [context executeFetchRequest:request error:&error];
    
    if (designArray.count > 1) {
        NSLog(@"ERROR: More than one design object in database");
        return;
    }
    
    for (Design *design in designArray) {
        
        NSURL *bacgroundURL = [[NSURL alloc] initWithString:
                                [NSString stringWithFormat:@"%@%@", 
                                 @"http://www.mashasbookstore.com", design.bgImageURL]];
        NSURL *mashaURL = [[NSURL alloc] initWithString:
                               [NSString stringWithFormat:@"%@%@", 
                                @"http://www.mashasbookstore.com", design.bgMashaURL]];
        
        
        NSLog(@"Downloading background images at %@ and %@", bacgroundURL, mashaURL);
        
        // Get an image from the URL below
        dispatch_queue_t backgroundsDownloadQueue = dispatch_queue_create("category download", NULL);
        dispatch_async(backgroundsDownloadQueue, ^{
            
            UIImage *background = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:bacgroundURL]];
            UIImage *masha = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:mashaURL]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{                    
                if (background && masha) {                                    
                    
                    design.bgImage = background;
                    design.bgMasha = masha;
                    
                    NSLog(@"Downloaded background images for design");
                    
                    
                }
            });   
        });
        dispatch_release(backgroundsDownloadQueue);
    } 
    
    
}

@end
