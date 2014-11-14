//
// Created by Stijn Willems on 14/11/14.
// Copyright (c) 2014 dooZ. All rights reserved.
//

#import "AnyPageContainer.h"
#import "SharedPageViewController.h"
#import "AnyViewController.h"


@implementation AnyPageContainer

- (void)pageViewController:(SharedPageViewController *)pageViewController
       setupViewController:(UIViewController <SharedPageAble> *)viewController
                 pageIndex:(NSUInteger)pageIndex
{
   AnyViewController * anyViewController = (AnyViewController *) viewController;
    anyViewController.pageNumberLabel.text = @(pageIndex).stringValue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SharedPageViewController *pageViewController = segue.destinationViewController;
    pageViewController.maxNumberOfPages = 10;
    pageViewController.pages = @[[self vc:0], [self vc:1], [self vc:2]];
    pageViewController.pageSetupDelegate = self;
}

- (AnyViewController *)vc:(NSUInteger)index
{
    AnyViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"AnyViewController"];
    vc1.pageIndex = index;
    return vc1;
}

@end