//
//  SSAvatarView.h
//  SeeLoaderExample
//
//  Created by Gabriele Petronella on 9/3/13.
//  Copyright (c) 2013 Gabriele Petronella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSAvatarView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor * outerBorderColor;
@property (nonatomic, strong) UIColor * progressColor;
@property (nonatomic, strong) UIImage * avatarImage;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) BOOL indefinite;

- (void)startPulsing;
- (void)stopPulsing;

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder;
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder success:(void (^)(UIImage * image))success failure:(void (^)(NSError * error))failure;

@end
