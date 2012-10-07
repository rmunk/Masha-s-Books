//
//  MyBooksViewController.h
//  Masha's Books
//
//  Created by Ranko Munk on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBDatabase.h"

@interface MyBooksViewController : UIViewController
@property (nonatomic, strong) UIManagedDocument *library;
@property (weak, nonatomic) IBOutlet UIImageView *mashaImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

- (void)setMBD:(MBDatabase *)database;
@end
