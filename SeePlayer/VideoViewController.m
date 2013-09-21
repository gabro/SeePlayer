//
//  VideoViewController.m
//  SeePlayer
//
//  Created by Gabriele Petronella on 9/19/13.
//  Copyright (c) 2013 buildo. All rights reserved.
//

#import "VideoViewController.h"
#import <ios-realtimeblur/DRNRealTimeBlurView.h>
#import <AVFoundation/AVFoundation.h>
#import "SSPlayerView.h"

static const NSString *ItemStatusContext;

@interface VideoViewController ()
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) SSPlayerView * playerView;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePlayer];
    [self configureGestureRecognizers];
        
    //
//    NSArray * images = @[@"bg1.jpg", @"bg2.jpg", @"bg3.jpg"];
//    
//    CGRect rect = (CGRect){ .origin = {0,0}, .size = { self.view.frame.size.height, self.view.frame.size.width } };
//
//    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:rect];
//    backgroundView.image = [UIImage imageNamed:images[arc4random_uniform(images.count)]];
//    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    [self.view addSubview:backgroundView];
//    
//    DRNRealTimeBlurView * blurOverlay = [[DRNRealTimeBlurView alloc] initWithFrame:rect];
//    blurOverlay.layer.cornerRadius = 0;
//    blurOverlay.renderStatic = YES;
//    [self.view addSubview:blurOverlay];
}

- (void)configurePlayer {
    self.player = [AVPlayer new];

    AVURLAsset * asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"] options:nil];
    NSArray * keys = @[@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        });
    }];
    
    CGRect rect = (CGRect){ .origin = {0,0}, .size = { self.view.frame.size.height, self.view.frame.size.width } };
    self.playerView = [[SSPlayerView alloc] initWithFrame:rect];
    [self.view addSubview:self.playerView];
    self.playerView.player = self.player;
    ((AVPlayerLayer *) self.playerView.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.player addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
}

- (void)configureGestureRecognizers {
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlayback)];
    tapRecognizer.delegate = self;
    [self.playerView addGestureRecognizer:tapRecognizer];
}

- (void)dealloc {
    [self.player removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &ItemStatusContext && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay && self.isVisible) {
            [self play];
            
            // Watch for progress
            CMTime interval = CMTimeMake(33, 1000); // 30fps
            typeof(self) __weak weakSelf = self;
            [self.player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
                CMTime endTime = CMTimeConvertScale(weakSelf.player.currentItem.asset.duration, weakSelf.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
                if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
                    double normalizedTime = (double) weakSelf.player.currentTime.value / (double) endTime.value;
                    //TODO: update the video progress bar
//                    weakSelf.progressBar.progress = normalizedTime;
                }
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self play];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self pause];
    
    [super viewDidDisappear:animated];
}

- (void)togglePlayback {
    if (self.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}
    
- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (BOOL)isPlaying {
    return self.player.rate != 0.0;
}

- (BOOL)isVisible {
    return self.isViewLoaded && self.view.window != nil;
}

@end