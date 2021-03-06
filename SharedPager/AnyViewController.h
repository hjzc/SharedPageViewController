//
//  AnyViewController.h
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedPageViewController.h"

@interface AnyViewController : UIViewController  <SharedPageAble>

//ModelItems are passed by the pageViewController. Not needed in this simple case.
@property (nonatomic, strong) NSArray *modelItems;
@property (strong, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property NSUInteger pageIndex;

@end
