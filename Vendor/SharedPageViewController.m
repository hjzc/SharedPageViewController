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
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, strong) NSTimer *interactionTimer;
@property (nonatomic, assign) UIPageViewControllerNavigationDirection direction;

@end

@implementation SharedPageViewController

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex
{
    self.direction = [self getDirection:currentPageIndex];
    _currentPageIndex = currentPageIndex;
    [self updateControllers];
}

- (void)updateControllers
{
    if (self.currentPageIndex >= self.maxNumberOfPages) {
        return;
    }

    self.selectedViewController = [self getController:self.currentPageIndex];
    
    __weak SharedPageViewController *weakSelf = self;
    NSArray *viewControllers = @[self.selectedViewController];
    [self setViewControllers:viewControllers
                   direction:self.direction
                    animated:YES
                  completion:^(BOOL finished) {
                      if (finished) {
                          //http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller
                          dispatch_async (dispatch_get_main_queue (), ^{
                              [weakSelf setViewControllers:viewControllers
                                                 direction:weakSelf.direction
                                                  animated:NO
                                                completion:NULL];// bug fix for uipageviewcontroller
                          });
                      }
                  }];
}


- (UIPageViewControllerNavigationDirection)getDirection:(NSUInteger)currentPageIndex
{
    UIPageViewControllerNavigationDirection direction;
    if (currentPageIndex > _currentPageIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    return direction;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    self.currentPageIndex = 0;
}

#pragma mark - Count pages

- (void)     pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.pendingViewController = pendingViewControllers[0];
    NSUInteger index = [self getPageIndex];
    if ([(self.pageCountDelegate) respondsToSelector:@selector (pageViewController:willChangeToPageIndex:)]) {
        [(self.pageCountDelegate) pageViewController:self
                               willChangeToPageIndex:index];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed && finished) {
        NSUInteger index = [self getPageIndex];
        _currentPageIndex = index;
        self.selectedViewController = self.pendingViewController;
    } else {
        self.pendingViewController = nil;
    }
    [self.pageCountDelegate pageViewController:self
                          didChangeToPageIndex:self.currentPageIndex];
}

- (NSUInteger)getPageIndex
{
    NSUInteger index = self.currentPageIndex;
    if (self.pendingViewController.pageIndex < self.selectedViewController.pageIndex) {
        index--;
    } else {
        index++;
    }
    if (index >= self.maxNumberOfPages) {
        index = self.maxNumberOfPages - 1;
    }
    return index;
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

- (void)goToPageAtIndex:(NSUInteger)index
{
    self.currentPageIndex = index;
}

- (void)passModelItemsToAllPages:(NSArray *)modelItems
{
    for (id <SharedPageAble> page in self.pages){
        page.modelItems = modelItems;
        [page reloadData];
    }
}

- (void)reloadScreensOfAllPages
{
    for (id <SharedPageAble> page in self.pages){
        [page reloadData];
    }
}

- (void)scheduleDataReloadOfAllPages
{
     for (NSObject <SharedPageAble> *vc in self.pages){
         if ([vc respondsToSelector:@selector (scheduleDataReload)]) {
             [vc scheduleDataReload];
         }
     }
}

- (void)cancelScheduledDataReloadOfAllPages
{
    for (NSObject <SharedPageAble> *vc in self.pages){
        if ([vc respondsToSelector:@selector (cancelScheduledDataReload)]) {
            [vc cancelScheduledDataReload];
        }
    }
}

- (void)reloadDataOfAllPagesIfNeeded
{
    for (NSObject <SharedPageAble> *vc in self.pages){
        if ([vc respondsToSelector:@selector (reloadDataIfNeeded)]) {
            [vc reloadDataIfNeeded];
        }
    }
}
@end
