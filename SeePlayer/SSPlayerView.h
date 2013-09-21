//
//  SSPlayerView.h
//  ssvids
//
//  Created by Gabriele Petronella on 7/4/13.
//  Copyright (c) 2013 77 Division. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SSPlayerView : UIView
@property (nonatomic) AVPlayer * player;
@property (nonatomic) NSString * videoGravity;
@end