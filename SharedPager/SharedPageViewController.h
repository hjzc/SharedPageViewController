//
//  SharedPageViewController.h
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic) NSUInteger maxNumberOfPages;
@end
