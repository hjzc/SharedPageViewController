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
@property (nonatomic, strong) NSArray *modelItems;

- (void)reloadData;

@optional
- (void)scheduleDataReload;
- (void)cancelScheduledDataReload;
- (void)reloadDataIfNeeded;

@end

@protocol SharedPageCountDelegate <NSObject>

- (void)pageViewController:(SharedPageViewController *)pageViewController didChangeToPageIndex:(NSUInteger)pageIndex;

@optional
- (void)pageViewController:(SharedPageViewController *)pageViewController willChangeToPageIndex:(NSUInteger)index;

@end

@protocol SharedPageSetupDelegate <NSObject>
- (void)pageViewController:(SharedPageViewController *)pageViewController
       setupViewController:(UIViewController <SharedPageAble> *)viewController
                 pageIndex:(NSUInteger)pageIndex;
@end

@interface SharedPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, weak) NSObject <SharedPageSetupDelegate> *pageSetupDelegate;
@property (nonatomic, weak) NSObject <SharedPageCountDelegate> *pageCountDelegate;

@property (nonatomic, strong) NSArray *pageItems;

/**
 * By calling this method for every filterItem a viewController is created.
 */
- (void)cacheAllViewControllers;

/*
 * Subclasses must override this method to create a viewcontroller for a specific page.
 */

- (UIViewController <SharedPageAble> *)createViewControllerAtPageIndex:(NSUInteger)index;

//Managing reusable pages
/*
* Reusable pages are pages that have similar view layout but can have different content.
* You can set as many as you want but a minimum is 2.
* You set the maxNumberOfPages to be the number of pages you want to page too.
* maxNumberOfPages can be more the numberOfReusablePages.
*
 */
- (void)addReusablePages:(NSArray *)reusablePages;

- (void)removeReusablePageAtIndex:(NSUInteger)reusablePageIndex;
- (void)replaceAllReusablePagesWithReusablePages:(NSArray *)reusablePages;
- (NSUInteger)numberOfReusablePages;


//Dealing with page numbers
/*
* The maxNumberOfPages defines the amount of pages available.
* If this was a book it would be the last page number of the book.
 */
@property (nonatomic) NSUInteger maxNumberOfPages;

- (void)goToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (UIViewController <SharedPageAble> *)visibleViewController;


/*
     * The content on the pages can come from a modelItem.
     * Methods below handle reloading of this content and setting modelItems.
 */
- (void)passModelItemsToAllPages:(NSArray *)modelItems;

- (void)reloadScreensOfAllPages;
- (void)scheduleDataReloadOfAllPages;
- (void)cancelScheduledDataReloadOfAllPages;
- (void)reloadDataOfAllPagesIfNeeded;

- (void)resetupReusablePages;

@end
