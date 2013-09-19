//
//  PlayerPageViewController.m
//  SeePlayer
//
//  Created by Gabriele Petronella on 9/19/13.
//  Copyright (c) 2013 buildo. All rights reserved.
//

#import "PlayerPageViewController.h"
#import "VideoViewController.h"

@interface PlayerPageViewController ()

@end

@implementation PlayerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    VideoViewController * firstPage = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    [self setViewControllers:@[firstPage]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES completion:nil];
    self.dataSource = self;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
}

@end
