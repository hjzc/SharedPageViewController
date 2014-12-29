//
//  AnyViewController.m
//  SharedPager
//
//  Created by Stijn Willems on 13/11/14.
//  Copyright (c) 2014 dooZ. All rights reserved.
//

#import "AnyViewController.h"

@interface AnyViewController ()

@end

@implementation AnyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageNumberLabel.text = @(self.pageIndex).stringValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SharedPageAble
-(void)reloadData
{
    /*
     * Method will be called by the page
     * You can reload data on screen here. Not needed in this simple case.
    */
}

@end
