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

/*
    * Array of any number of reusable viewControllers that can be reused for data content.
    * Every viewController in the array should conform to <SharedPageAble>
    * This array can contain less pages then the maxNumberOfPages.
 */
@property (nonatomic, strong) NSMutableArray *reusablePages;
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated;
@end

@implementation SharedPageViewController

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex
{
    [self setCurrentPageIndex:currentPageIndex animated:YES];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated
{
    self.direction = [self getDirection:currentPageIndex];
    _currentPageIndex = currentPageIndex;
    [self updateControllers:animated];
}

- (void)updateControllers:(BOOL)animated
{
    if (self.currentPageIndex >= self.maxNumberOfPages) {
        return;
    }

    self.selectedViewController = [self getController:self.currentPageIndex];

    __weak SharedPageViewController *weakSelf = self;
    NSArray *viewControllers = @[self.visibleViewController];
    [self setViewControllers:viewControllers
                   direction:self.direction
                    animated:animated
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
    [self updateControllers:YES];
}

#pragma mark - Count reusablePages

- (void)     pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.pendingViewController = pendingViewControllers[0];
    NSUInteger index = [self getPageIndex];
    //Needed to prevent reloading reusablePages to often when tapping the reusablePages very heavily.
    self.view.userInteractionEnabled = NO;
    //Re-enable userInteraction after a fixed period of time (safeguard to ensure it does not stay disabled)
    [self resetUserInteractionTimer];
    self.interactionTimer = [NSTimer scheduledTimerWithTimeInterval:2.f
                                                             target:self
                                                           selector:@selector (resetUserInteraction:)
                                                           userInfo:pageViewController
                                                            repeats:NO];
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
    [self resetUserInteractionTimer];
    self.view.userInteractionEnabled = YES;
    [self.pageCountDelegate pageViewController:self
                          didChangeToPageIndex:self.currentPageIndex];
}

- (void)resetUserInteraction:(NSTimer *)timer
{
    self.view.userInteractionEnabled = YES;
    [self resetUserInteractionTimer];
}

- (void)resetUserInteractionTimer
{
    [self.interactionTimer invalidate];
    self.interactionTimer = nil;
}

- (NSUInteger)getPageIndex
{
    NSUInteger index = self.currentPageIndex;
    if (self.pendingViewController.pageIndex < self.visibleViewController.pageIndex) {
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
    NSUInteger pageModulo = pageIndex % self.reusablePages.count;
    UIViewController <SharedPageAble> *vc = self.reusablePages[pageModulo];
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

- (void)addReusablePages:(NSArray *)reusablePages
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.reusablePages];

    [array addObjectsFromArray:reusablePages];
    self.reusablePages = array;
}

- (NSUInteger)numberOfReusablePages
{
    return self.reusablePages.count;
}

- (void)removeReusablePageAtIndex:(NSUInteger)reusablePageIndex
{
    if (reusablePageIndex < self.reusablePages.count) {
        [self.reusablePages removeObjectAtIndex:reusablePageIndex];
        if (reusablePageIndex == self.currentPageIndex) {
            [self goToPageBefore:reusablePageIndex];
        }
    }
}

- (void)replaceAllReusablePagesWithReusablePages:(NSArray *)reusablePages
{
    self.reusablePages = [reusablePages mutableCopy];
}


- (void)goToPageBefore:(NSUInteger)index
{
    NSInteger pageBeforeIndex = index - 1;
    if (pageBeforeIndex > 0 && pageBeforeIndex < self.reusablePages.count) {
        [self goToPageAtIndex:pageBeforeIndex animated:YES];
    }
}


- (void)goToPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self setCurrentPageIndex:index animated:animated];
}

- (UIViewController <SharedPageAble> *)visibleViewController
{
    return self.selectedViewController;
}


- (void)passModelItemsToAllPages:(NSArray *)modelItems
{
    for (id <SharedPageAble> page in self.reusablePages) {
        page.modelItems = modelItems;
        [page reloadData];
    }
}

- (void)reloadScreensOfAllPages
{
    for (id <SharedPageAble> page in self.reusablePages) {
        [page reloadData];
    }
}

- (void)scheduleDataReloadOfAllPages
{
    for (NSObject <SharedPageAble> *vc in self.reusablePages) {
        if ([vc respondsToSelector:@selector (scheduleDataReload)]) {
            [vc scheduleDataReload];
        }
    }
}

- (void)cancelScheduledDataReloadOfAllPages
{
    for (NSObject <SharedPageAble> *vc in self.reusablePages) {
        if ([vc respondsToSelector:@selector (cancelScheduledDataReload)]) {
            [vc cancelScheduledDataReload];
        }
    }
}

- (void)reloadDataOfAllPagesIfNeeded
{
    for (NSObject <SharedPageAble> *vc in self.reusablePages) {
        if ([vc respondsToSelector:@selector (reloadDataIfNeeded)]) {
            [vc reloadDataIfNeeded];
        }
    }
}

- (void)resetupReusablePages
{
    for (UIViewController<SharedPageAble> *page in self.reusablePages) {
        [self.pageSetupDelegate pageViewController:self setupViewController:page pageIndex:page.pageIndex];
    }
}

- (UIViewController <SharedPageAble> *)createViewControllerAtPageIndex:(NSUInteger)index{
    
    NSLog(@"Override %@ to have pages showing content of the created viewController.", NSStringFromSelector(_cmd));
    return nil;
}
- (void)cacheAllViewControllers
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.pageItems.count];
    
    for (NSUInteger i = [self numberOfReusablePages]; i < self.pageItems.count; i++) {
        UIViewController <SharedPageAble> *vc = [self createViewControllerAtPageIndex:i];
        [array addObject:vc];
    }
    [self addReusablePages:array];
}
@end
