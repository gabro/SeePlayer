//
//  PlayerViewController.m
//  SeePlayer
//
//  Created by Gabriele Petronella on 9/19/13.
//  Copyright (c) 2013 buildo. All rights reserved.
//

#import "PlayerViewController.h"
#import "SSTimelineLayout.h"
#import "SSTimelineCell.h"
#import "SSAvatarView.h"
#import "VideoViewController.h"

typedef enum _PlayerModes {
    SSPlayerModePlayback = 0,
    SSPlayerModeTimeline
} SSPlayerMode;

@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *timeline;
@property (nonatomic, assign) NSUInteger numberOfItems;
@property (nonatomic, strong) NSArray * avatars;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalCenterConstraint;
@property (nonatomic, assign) SSPlayerMode mode;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    _mode = SSPlayerModeTimeline;
    
    self.avatars = @[
                     [NSURL URLWithString:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c42.42.529.529/s320x320/315759_10200114897655157_1411883421_n.jpg"],
                     [NSURL URLWithString:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/c170.50.621.621/s320x320/1173595_10151531721246637_1208900379_n.jpg"],
                     [NSURL URLWithString:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc1/c32.32.400.400/s320x320/387879_10150394634018683_329652416_n.jpg"],
                     [NSURL URLWithString:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/c229.1.410.410/s320x320/247253_2178309095863_930911_n.jpg"]
                     ];
    
    self.numberOfItems = 20;
    self.timeline.collectionViewLayout = [SSTimelineLayout new];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * kIdentifier = @"AvatarView";
    SSTimelineCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIdentifier forIndexPath:indexPath];
    
    NSIndexPath * centerIndexPath = [collectionView indexPathForItemAtPoint:[collectionView convertPoint:collectionView.center fromView:collectionView.superview]];
    
    cell.avatarView.indefinite = [indexPath isEqual:centerIndexPath];
    cell.avatarView.borderWidth = 3;
    cell.avatarView.progressColor = [UIColor colorWithRed:48/256.0 green:191/256.0 blue:184/256.0 alpha:1];
    [cell.avatarView setImageWithURL:self.avatars[indexPath.item % self.avatars.count] placeholder:[UIImage imageNamed:@"Avatar-placeholder"]];
  
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView * collectionView = (UICollectionView *)scrollView;
        
        for (SSTimelineCell * visibleCell in collectionView.visibleCells) {
            visibleCell.avatarView.progress = 0;
            visibleCell.avatarView.indefinite = NO;
        }
        
        NSIndexPath * centerIndexPath = [collectionView indexPathForItemAtPoint:[collectionView convertPoint:collectionView.center fromView:collectionView.superview]];
        SSTimelineCell * cell = (SSTimelineCell *)[collectionView cellForItemAtIndexPath:centerIndexPath];
        cell.avatarView.indefinite = YES;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    VideoViewController * newVideoVC = pendingViewControllers[0];
    VideoViewController * currentVideoVC = pageViewController.viewControllers[0];
    NSIndexPath * centerIndexPath = [self centerIndexPathForTimeline:self.timeline];
    NSInteger item = newVideoVC.index > currentVideoVC.index ? centerIndexPath.item + 1 : centerIndexPath.item - 1;
    NSIndexPath * newCenterIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.timeline scrollToItemAtIndexPath:newCenterIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)setMode:(SSPlayerMode)mode {
    if (mode == _mode)
        return;
    _mode = mode;
    
    switch (mode) {
        case SSPlayerModePlayback:
            [self moveTimelineDown];
            self.timeline.userInteractionEnabled = NO;
            break;
        case SSPlayerModeTimeline:
            [self moveTimelineUp];
            self.timeline.userInteractionEnabled = YES;
            break;
    }
}

- (IBAction)handleButton:(id)sender {
    if (self.mode == SSPlayerModePlayback) {
        [self setMode:SSPlayerModeTimeline];
    } else {
        [self setMode:SSPlayerModePlayback];
    }
}

- (void)moveTimelineUp {
    NSLayoutConstraint * yCenterConstraint = [NSLayoutConstraint constraintWithItem:self.timeline
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0];
    [self.view removeConstraint:self.verticalCenterConstraint];
    [self.view addConstraint:yCenterConstraint];
    self.verticalCenterConstraint = yCenterConstraint;
    
    NSArray * rightCells;
    NSArray * leftCells;
    SSTimelineCell * centerCell;
    [self getLeftCells:&leftCells rightCells:&rightCells centerCell:&centerCell inTimeline:self.timeline];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        centerCell.avatarView.indefinite = YES;
        centerCell.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1);
    } completion:^(BOOL finished) {
        [self showRightCells:rightCells leftCells:leftCells completion:nil];
    }];
}

- (void)moveTimelineDown {
    NSArray * rightCells;
    NSArray * leftCells;
    SSTimelineCell * centerCell;
    [self getLeftCells:&leftCells rightCells:&rightCells centerCell:&centerCell inTimeline:self.timeline];
    
    [self hideRightCells:rightCells leftCells:leftCells completion:^(BOOL finished) {
        NSLayoutConstraint * yCenterConstraint = [NSLayoutConstraint constraintWithItem:self.timeline
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.view
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.0
                                                                               constant:100];
        [self.view removeConstraint:self.verticalCenterConstraint];
        [self.view addConstraint:yCenterConstraint];
        self.verticalCenterConstraint = yCenterConstraint;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            centerCell.avatarView.indefinite = NO;
            centerCell.avatarView.progress = 0;
            centerCell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
    }];
}

- (void)getLeftCells:(NSArray **)leftCells rightCells:(NSArray **)rightCells centerCell:(SSTimelineCell **)centerCell inTimeline:(UICollectionView *)timeline {
    NSIndexPath * centerIndexPath = [self centerIndexPathForTimeline:timeline];
    *centerCell = (SSTimelineCell *)[timeline cellForItemAtIndexPath:centerIndexPath];
    NSMutableArray * tmpLeftCells = [NSMutableArray array];
    NSMutableArray * tmpRightCells = [NSMutableArray array];
    
    for (SSTimelineCell * cell in timeline.visibleCells) {
        NSIndexPath * indexPath = [timeline indexPathForCell:cell];
        if (indexPath.item < centerIndexPath.item) {
            [tmpLeftCells addObject:cell];
        } else if (indexPath.item > centerIndexPath.item) {
            [tmpRightCells addObject:cell];
        }
    }
    
    *leftCells = tmpLeftCells;
    *rightCells = tmpRightCells;
}

- (NSIndexPath *)centerIndexPathForTimeline:(UICollectionView *)timeline {
    return [timeline indexPathForItemAtPoint:[timeline convertPoint:timeline.center fromView:timeline.superview]];
}

- (void)showRightCells:(NSArray *)rightCells leftCells:(NSArray *)leftCells completion:(void (^)(BOOL finished))completion {
    [self toggleRightCells:rightCells leftCells:leftCells show:YES completion:completion];
}

- (void)hideRightCells:(NSArray *)rightCells leftCells:(NSArray *)leftCells completion:(void (^)(BOOL finished))completion {
    [self toggleRightCells:rightCells leftCells:leftCells show:NO completion:completion];
}

- (void)toggleRightCells:(NSArray *)rightCells leftCells:(NSArray *)leftCells show:(BOOL)show completion:(void (^)(BOOL finished))completion {
    if (leftCells.count == 0 && rightCells.count == 0 && completion) {
        completion(YES);
    }
    
    NSComparator xPositionComparator = ^(SSTimelineCell * cell1, SSTimelineCell * cell2) {
        if (cell1.center.x < cell2.center.x)
            return NSOrderedAscending;
        if(cell1.center.x > cell2.center.x)
            return NSOrderedDescending;
        return NSOrderedSame;
    };
    
    leftCells = [leftCells sortedArrayUsingComparator:xPositionComparator];
    rightCells = [rightCells sortedArrayUsingComparator:xPositionComparator];
    
    CGFloat xOffset = (CGRectGetWidth(self.timeline.bounds) - [(SSTimelineLayout *)self.timeline.collectionViewLayout itemSize].width) / 2;
    
    [leftCells enumerateObjectsUsingBlock:^(SSTimelineCell * cell, NSUInteger idx, BOOL *stop) {
        float delay = 0.05 * (show ? (leftCells.count - 1 - idx) : idx);
        [UIView animateWithDuration:0.3 delay:delay options:0 animations:^{
            cell.layer.transform = show ? CATransform3DIdentity : CATransform3DMakeTranslation(-xOffset, 0, 0);
        } completion:^(BOOL finished) {
            if (rightCells.count == 0 && idx == leftCells.count - 1) {
                if (completion) {
                    completion(finished);
                }
            }
        }];
    }];
    
    [rightCells enumerateObjectsUsingBlock:^(SSTimelineCell * cell, NSUInteger idx, BOOL *stop) {
        float delay = 0.05 * (show ? idx : (rightCells.count - 1 - idx));
        [UIView animateWithDuration:0.3 delay:delay options:0 animations:^{
            cell.layer.transform = show ? CATransform3DIdentity : CATransform3DMakeTranslation(xOffset, 0, 0);
        } completion:^(BOOL finished) {
            if (idx == rightCells.count - 1) {
                if (completion) {
                    completion(finished);
                }
            }
        }];
    }];
}

@end
