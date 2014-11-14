//
//  SharedPageViewController.h
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SharedPageViewController;

@protocol SharedPageAble <NSObject>

@property NSUInteger pageIndex;

@end

@protocol SharedPageSetupDelegate <NSObject>
- (void)pageViewController:(SharedPageViewController *)pageViewController
       setupViewController:(UIViewController <SharedPageAble> *)viewController
                 pageIndex:(NSUInteger)pageIndex;
@end

@interface SharedPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, weak) NSObject <SharedPageSetupDelegate> *pageSetupDelegate;
@property (nonatomic) NSUInteger maxNumberOfPages;

/*
* Array of 3 viewControllers that can be reused for data content. They should conform to <SharedPageAble>
 */
@property (nonatomic, strong) NSArray *pages;
@end
