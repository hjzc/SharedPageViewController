//
//  SharedPageViewController.m
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import "SharedPageViewController.h"
#import "AnyViewController.h"

@interface SharedPageViewController ()
@property (nonatomic, strong) NSArray *pages;

@property (nonatomic, strong) AnyViewController *pendingViewController;
@property (nonatomic, strong) AnyViewController *selectedViewController;
@property (nonatomic) NSUInteger currentPageIndex;
@end

@implementation SharedPageViewController

- (NSArray *)pages
{
    if (!_pages) {
        _pages = @[[self vc:0], [self vc:1], [self vc:2]];
    }
    return _pages;
}

- (NSString *)identifier
{
    if (!_identifier) {
        _identifier = @"AnyViewController";
    }
    return _identifier;
}

- (AnyViewController *)vc:(NSUInteger)index
{
    AnyViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:self.identifier];
    vc1.pageIndex = index;
    return vc1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.maxNumberOfPages = 3;
    self.delegate = self;
    self.dataSource = self;
    self.selectedViewController = self.pages[0];
    [self setViewControllers:@[self.selectedViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:^(BOOL finished) {
                      //
                  }];
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

- (AnyViewController *)getController:(NSUInteger)pageNumber
{
    AnyViewController *vc = self.pages[pageNumber];
    vc.pageNumberLabel.text = @(pageNumber).stringValue;
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
