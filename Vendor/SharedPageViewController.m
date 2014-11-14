//
//  SharedPageViewController.m
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import "SharedPageViewController.h"

@interface SharedPageViewController ()
@property (nonatomic, strong) UIViewController <SharedPageAble> *pendingViewController;
@property (nonatomic, strong) UIViewController <SharedPageAble> *selectedViewController;
@property (nonatomic) NSUInteger currentPageIndex;
@end

@implementation SharedPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    self.selectedViewController = self.pages[self.currentPageIndex];
    [self setViewControllers:@[self.selectedViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    [self.pageSetupDelegate pageViewController:self
                           setupViewController:self.selectedViewController
                                     pageIndex:self.currentPageIndex];
}

#pragma mark - Count pages

- (void)     pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.pendingViewController = pendingViewControllers[0];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        if (self.pendingViewController.pageIndex < self.selectedViewController.pageIndex) {
            self.currentPageIndex--;
        } else {
            self.currentPageIndex++;
        }
        self.selectedViewController = self.pendingViewController;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger previous = self.currentPageIndex - 1;
    if (previous < 0) {
        return nil;
    }

    return [self getController:(NSUInteger) previous];
}

- (UIViewController <SharedPageAble> *)getController:(NSUInteger)pageIndex
{
    NSUInteger pageModulo = pageIndex % self.pages.count;
    UIViewController <SharedPageAble> *vc = self.pages[pageModulo];
    vc.pageIndex = pageIndex;
    [self.pageSetupDelegate pageViewController:self
                           setupViewController:vc
                                     pageIndex:pageIndex];
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger next = self.currentPageIndex + 1;
    if (next >= self.maxNumberOfPages) {
        return nil;
    }
    return [self getController:next];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
