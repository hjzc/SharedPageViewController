//
//  AnyViewController.h
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnyViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property NSUInteger pageIndex;

@end
