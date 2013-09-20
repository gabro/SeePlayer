//
//  PlayerPageViewController.h
//  SeePlayer
//
//  Created by Gabriele Petronella on 9/19/13.
//  Copyright (c) 2013 buildo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerPageViewController;

@protocol PlayerPageViewControllerDelegate <NSObject>
@optional
- (void)playerPageViewControllerWillBeginScrolling:(PlayerPageViewController *)pageViewController;
- (void)playerPageViewController:(PlayerPageViewController *)pageViewController didScrollFromViewController:(UIViewController *)fromViewController atPage:(NSInteger)fromPage toViewController:(UIViewController *)toViewController atPage:(NSInteger)toPage withRatio:(CGFloat)ratio;
- (void)playerPageviewControllerDidEndScrolling:(PlayerPageViewController *)pageViewController;
@end


@interface PlayerPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, weak) id<PlayerPageViewControllerDelegate> playerPageDelegate;

- (void)scrollToPage:(NSInteger)page;
- (void)scrollToPage:(NSInteger)page triggeredByUser:(BOOL)triggeredByUser;
- (void)scrollToPage:(NSInteger)page triggeredByUser:(BOOL)triggeredByUser completion:(void (^)(BOOL finished))completion;
- (void)scrollToPreviousPage;
- (void)scrollToPreviousPageTriggeredByUser:(BOOL)triggeredByUser;
- (void)scrollToPreviousPageTriggeredByUser:(BOOL)triggeredByUser completion:(void (^)(BOOL finished))completion;
- (void)scrollToNextPage;
- (void)scrollToNextPageTriggeredByUser:(BOOL)triggeredByUser;
- (void)scrollToNextPageTriggeredByUser:(BOOL)triggeredByUser completion:(void (^)(BOOL finished))completion;

@end
