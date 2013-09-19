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

    if (self.mode == SSPlayerModePlayback) {
        cell.alpha = 0;
    }
    
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

- (void)setMode:(SSPlayerMode)mode {
    if (mode == _mode)
        return;
    _mode = mode;
    
    switch (mode) {
        case SSPlayerModePlayback:
            [self moveTimelineUp:NO];
            self.timeline.userInteractionEnabled = NO;
            break;
        case SSPlayerModeTimeline:
            [self moveTimelineUp:YES];
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

- (void)moveTimelineUp:(BOOL)up {
    NSLayoutConstraint * yCenterConstraint = [NSLayoutConstraint constraintWithItem:self.timeline
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:up ? 0 : 100];
    [self.view removeConstraint:self.verticalCenterConstraint];
    [self.view addConstraint:yCenterConstraint];
    self.verticalCenterConstraint = yCenterConstraint;

    NSIndexPath * centerIndexPath = [self.timeline indexPathForItemAtPoint:[self.timeline convertPoint:self.timeline.center fromView:self.timeline.superview]];
    if (!up) {
        NSMutableArray * indexPaths = [[self.timeline indexPathsForVisibleItems] mutableCopy];
        [indexPaths removeObject:centerIndexPath];
        [self.timeline reloadItemsAtIndexPaths:indexPaths];
    }

    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        SSTimelineCell * currentCell = (SSTimelineCell *)[self.timeline cellForItemAtIndexPath:centerIndexPath];
        if (up) {
            currentCell.avatarView.indefinite = YES;
            currentCell.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1);
        } else {
            currentCell.avatarView.indefinite = NO;
            currentCell.avatarView.progress = 0;
            currentCell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }
    } completion:^(BOOL finished) {
        if (up) {
            NSMutableArray * indexPaths = [[self.timeline indexPathsForVisibleItems] mutableCopy];
            [indexPaths removeObject:centerIndexPath];
            [self.timeline reloadItemsAtIndexPaths:indexPaths];
        }
    }];
}

@end
