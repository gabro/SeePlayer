//
//  VideoViewController.m
//  SeePlayer
//
//  Created by Gabriele Petronella on 9/19/13.
//  Copyright (c) 2013 buildo. All rights reserved.
//

#import "VideoViewController.h"
#import <ios-realtimeblur/DRNRealTimeBlurView.h>

@interface VideoViewController ()

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray * images = @[@"bg1.jpg", @"bg2.jpg", @"bg3.jpg"];
    
    CGRect rect = (CGRect){ .origin = {0,0}, .size = { self.view.frame.size.height, self.view.frame.size.width } };
        
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:rect];
    backgroundView.image = [UIImage imageNamed:images[arc4random_uniform(images.count)]];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:backgroundView];
    
    DRNRealTimeBlurView * blurOverlay = [[DRNRealTimeBlurView alloc] initWithFrame:rect];
    blurOverlay.layer.cornerRadius = 0;
    blurOverlay.renderStatic = YES;
    [self.view addSubview:blurOverlay];
}

@end
