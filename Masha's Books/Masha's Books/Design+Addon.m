//
//  Design+Addon.m
//  Masha's Books
//
//  Created by Luka Miljak on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Design+Addon.h"

@implementation Design (Addon)

+ (void)loadDesignImages {
    
    Design *design = [[Design MR_findAll] lastObject];
    
    [MagicalRecord saveInBackgroundUsingCurrentContextWithBlock:^(NSManagedObjectContext *localContext)
    {
             
        NSURL *backgroundURL = [[NSURL alloc] initWithString:
                               [NSString stringWithFormat:@"%@%@",
                                @"http://www.mashasbookstore.com", design.bgImageURL]];
        
        NSURL *mashaURL = [[NSURL alloc] initWithString:
                           [NSString stringWithFormat:@"%@%@",
                            @"http://www.mashasbookstore.com", design.bgMashaURL]];
             
             
        NSLog(@"Downloading design images");
             
             
        NSData *background = [NSData dataWithContentsOfURL:backgroundURL]; 
        NSData *masha = [NSData dataWithContentsOfURL:mashaURL];
        if (background != nil) {                                    
                 
            design.bgImage = background;
            design.bgMasha = masha;
                 
        } 
    }
    completion:^{
        [[NSManagedObjectContext MR_defaultContext] save:nil];
        NSLog(@"Design images downloaded and saved to database.");
    }
    errorHandler:nil];
    
}

@end
