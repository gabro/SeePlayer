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
    firstPage.index = 0;
    [self setViewControllers:@[firstPage]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES completion:nil];
    self.dataSource = self;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(VideoViewController *)viewController {
    return [self videoViewControllerForPage:viewController.index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(VideoViewController *)viewController {
    return [self videoViewControllerForPage:viewController.index + 1];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    self.delegate = (id<UIPageViewControllerDelegate>)parent;
}

- (VideoViewController *)videoViewControllerForPage:(NSInteger)page {
    if (page < 0) {
        return nil;
    }
    VideoViewController * videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    videoVC.index = page;
    return videoVC;
}

@end
