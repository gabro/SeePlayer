//
//  SSPlayerView.m
//  ssvids
//
//  Created by Gabriele Petronella on 7/4/13.
//  Copyright (c) 2013 77 Division. All rights reserved.
//

#import "SSPlayerView.h"


@implementation SSPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setVideoGravity:(NSString *)videoGravity {
    [(AVPlayerLayer *)[self layer] setVideoGravity:videoGravity];
    ((AVPlayerLayer *)[self layer]).bounds = ((AVPlayerLayer *)[self layer]).bounds;
}

- (NSString *)videoGravity {
    return [(AVPlayerLayer *)[self layer] videoGravity];
}

@end