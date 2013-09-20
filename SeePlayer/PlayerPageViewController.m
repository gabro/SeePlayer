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
@property (nonatomic, assign, getter = isScrolling) BOOL scrolling;
@property (nonatomic, assign) NSInteger currentPage;
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
    self.delegate = self;
}

- (void)dealloc {
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if ([parent conformsToProtocol:@protocol(PlayerPageViewControllerDelegate)]) {
        self.playerPageDelegate = (id<PlayerPageViewControllerDelegate>)parent;
    }
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(VideoViewController *)viewController {
    return [self videoViewControllerForPage:viewController.index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(VideoViewController *)viewController {
    return [self videoViewControllerForPage:viewController.index + 1];
}

#pragma mark - Page View Controller Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    if (!self.scrolling) {
        self.scrolling = YES;
        if ([self.playerPageDelegate respondsToSelector:@selector(playerPageViewControllerWillBeginScrolling:)]) {
            [self.playerPageDelegate playerPageViewControllerWillBeginScrolling:self];
        }
        UIScrollView * scrollView = [self internalScrollView];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (self.scrolling) {
        self.scrolling = NO;
        if ([self.playerPageDelegate respondsToSelector:@selector(playerPageviewControllerDidEndScrolling:)]) {
            [self.playerPageDelegate playerPageviewControllerDidEndScrolling:self];
        }
        UIScrollView * scrollView = [self internalScrollView];
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    if (completed) {
        self.currentPage = [self.viewControllers[0] index];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.scrolling && [keyPath isEqualToString:@"contentOffset"]) {
        if ([self.playerPageDelegate respondsToSelector:@selector(playerPageViewController:didScrollFromViewController:atPage:toViewController:atPage:withRatio:)]) {
            BOOL forward = [object contentOffset].x > CGRectGetWidth([object bounds]);
            NSInteger destinationPage = self.currentPage + (forward ? 1 : -1);
            VideoViewController * currentViewController = self.viewControllers[0];
            VideoViewController * destinationViewController = [self videoViewControllerForPage:destinationPage];
            CGFloat ratio = ABS([object contentOffset].x - CGRectGetWidth([object bounds])) / [object bounds].size.width;
            [self.playerPageDelegate playerPageViewController:self didScrollFromViewController:currentViewController atPage:self.currentPage toViewController:destinationViewController atPage:destinationPage withRatio:ratio];
        }
    }
}

#pragma mark - Page Scrolling
- (void)scrollToPage:(NSInteger)page {
    [self scrollToPage:page triggeredByUser:NO];
}

- (void)scrollToPage:(NSInteger)page triggeredByUser:(BOOL)triggeredByUser {
    [self scrollToPage:page triggeredByUser:triggeredByUser completion:nil];
}

- (void)scrollToPage:(NSInteger)page triggeredByUser:(BOOL)triggeredByUser completion:(void (^)(BOOL finished))completion {
    NSInteger currentPage = self.currentPage;
    if (currentPage == page) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    VideoViewController * viewController = [self videoViewControllerForPage:page];
    if (viewController == nil) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    NSArray * viewControllers = @[ viewController ];
    
    UIPageViewControllerNavigationDirection direction = (page > currentPage) ?
    UIPageViewControllerNavigationDirectionForward :
    UIPageViewControllerNavigationDirectionReverse;
    
    NSArray * previousViewControllers = self.viewControllers;
    
    BOOL contiguousTransition = ABS(currentPage - page) == 1;
    
    if (triggeredByUser) {
        [self.delegate pageViewController:self willTransitionToViewControllers:viewControllers];
    }
    typeof(self) __weak weakSelf = self;
    [self setViewControllers:viewControllers direction:direction animated:contiguousTransition completion:^(BOOL finished) {
        weakSelf.currentPage = page;
        if (completion) {
            completion(finished);
        }
        if (triggeredByUser) {
            [weakSelf.delegate pageViewController:weakSelf didFinishAnimating:finished previousViewControllers:previousViewControllers transitionCompleted:YES];
        }
    }];
}

- (void)scrollToPreviousPage {
    [self scrollToPreviousPageTriggeredByUser:NO];
}

- (void)scrollToPreviousPageTriggeredByUser:(BOOL)triggeredByUser {
    [self scrollToPreviousPageTriggeredByUser:triggeredByUser completion:nil];
}

- (void)scrollToPreviousPageTriggeredByUser:(BOOL)triggeredByUser completion:(void (^)(BOOL))completion {
    [self scrollToPage:(self.currentPage - 1) triggeredByUser:triggeredByUser completion:completion];
}

- (void)scrollToNextPage {
    [self scrollToNextPageTriggeredByUser:NO];
}

- (void)scrollToNextPageTriggeredByUser:(BOOL)triggeredByUser {
    [self scrollToNextPageTriggeredByUser:triggeredByUser completion:nil];
}

- (void)scrollToNextPageTriggeredByUser:(BOOL)triggeredByUser completion:(void (^)(BOOL))completion {
    [self scrollToPage:(self.currentPage + 1) triggeredByUser:triggeredByUser completion:completion];
}

#pragma mark - Utilities
- (VideoViewController *)videoViewControllerForPage:(NSInteger)page {
    if (page < 0 || page > 19) {
        return nil;
    }
    VideoViewController * videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    videoVC.index = page;
    return videoVC;
}

- (UIScrollView *)internalScrollView {
    for (UIView * v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)v;
        }
    }
    NSAssert(NO, @"Internal scroll view not found");
    return nil;
}

@end
