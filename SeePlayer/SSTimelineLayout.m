//
//  SSTimelineLayout.m
//  SeePlayer
//
//  Created by Gabriele Petronella on 9/19/13.
//  Copyright (c) 2013 buildo. All rights reserved.
//

#import "SSTimelineLayout.h"

#define kItemSize 70

@interface SSTimelineLayout ()
@property (nonatomic, strong) NSMutableArray * deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray * insertIndexPaths;
@end

@implementation SSTimelineLayout

- (id)init {
    if (self = [super init]) {
        _activeDistance = kItemSize;
        _zoomFactor = 0.5;
        self.itemSize = (CGSize){ .width = kItemSize, .height = kItemSize };
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = (UIEdgeInsets){ .left =  240, .right = 240 };  //Make this dynamic
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in layoutAttributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat normalizedDistance = distance / self.activeDistance;
            if (ABS(distance) < self.activeDistance) {
                CGFloat zoom = 1 + self.zoomFactor*(1 - ABS(normalizedDistance));
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1;
            }
        }
    }
    return layoutAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems) {
        if (update.updateAction == UICollectionUpdateActionDelete) {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        } else if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if ([self.insertIndexPaths containsObject:itemIndexPath]) {
        NSIndexPath * centerIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:self.collectionView.center fromView:self.collectionView.superview]];
        attributes.center = (CGPoint){
            .x = itemIndexPath.item <= centerIndexPath.item ? - self.itemSize.width : CGRectGetMaxX(self.collectionView.bounds) + self.itemSize.width,
            .y = CGRectGetMidY(self.collectionView.bounds)};
    }
    return attributes;
}

@end
