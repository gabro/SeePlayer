//
//  SSAvatarView.m
//  SeeLoaderExample
//
//  Created by Gabriele Petronella on 9/3/13.
//  Copyright (c) 2013 Gabriele Petronella. All rights reserved.
//

#import "SSAvatarView.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/SDWebImageManager.h>

@interface SSAvatarView ()
@property (nonatomic, strong) NSTimer * indefiniteTimer;
@end

@implementation SSAvatarView

@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _outerBorderColor = [UIColor whiteColor];
    _progressColor = [UIColor redColor];
    _progress = 0.0;
    _borderWidth = 20;
    self.indefinite = NO; //Use property access to trigger the timer
}

- (void)updateProgress {
    if (_progress > 1) {
        _progress = 0;
    }
    self.progress += 0.001;
}

- (void)drawRect:(CGRect)rect {
    CGFloat outerRadius = CGRectGetWidth(rect) / 2;
    CGPoint center = (CGPoint){CGRectGetMidX(rect), CGRectGetMidY(rect)};
    CGRect innerRect = CGRectInset(rect, self.borderWidth, self.borderWidth);
    CGFloat innerRadius = CGRectGetWidth(innerRect) / 2;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextAddEllipseInRect(ctx, innerRect);
    CGContextSetFillColorWithColor(ctx, self.outerBorderColor.CGColor);
    CGContextEOFillPath(ctx);
    
    CGFloat startAngle;
    CGFloat endAngle;
    CGPoint arcStartPoint;
    if (self.indefinite) {
        startAngle = M_PI_2 * 3 + self.progress * 2 * M_PI;
        endAngle = startAngle + M_PI_2;
        arcStartPoint = (CGPoint){outerRadius + cosf(startAngle) * outerRadius, outerRadius + sinf(startAngle) * outerRadius};
    } else {
        startAngle = M_PI_2 * 3;
        endAngle = startAngle + self.progress * 2 * M_PI;
        arcStartPoint = (CGPoint){center.x, 0};
    }
    
    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathMoveToPoint(progressPath, NULL, arcStartPoint.x, arcStartPoint.y);
    CGPathAddArc(progressPath, NULL, center.x, center.y, outerRadius, startAngle, endAngle, 0);
    CGPathAddLineToPoint(progressPath, NULL, outerRadius + innerRadius * cosf(endAngle), outerRadius + innerRadius * sinf(endAngle));
    CGPathAddArc(progressPath, NULL, center.x, center.y, innerRadius, endAngle, startAngle, 1);
    CGPathCloseSubpath(progressPath);
    
    CGContextSetFillColorWithColor(ctx, self.progressColor.CGColor);
    CGContextAddPath(ctx, progressPath);
    CGContextFillPath(ctx);
    CGPathRelease(progressPath);
    
    UIBezierPath * innerCircle = [UIBezierPath bezierPathWithOvalInRect:innerRect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, innerCircle.CGPath);
    CGContextClip(context);
    [self.avatarImage drawInRect:innerRect];
}

- (float)progress {
    return MAX(MIN(1, _progress), 0);
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setOuterBorderColor:(UIColor *)outerBorderColor {
    _outerBorderColor = outerBorderColor;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setIndefinite:(BOOL)indefinite {
    _indefinite = indefinite;
    if (indefinite) {
        self.indefiniteTimer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.indefiniteTimer forMode:NSRunLoopCommonModes];
    } else {
        [self.indefiniteTimer invalidate];
        self.indefiniteTimer = nil;
    }
    [self setNeedsDisplay];
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImage = avatarImage;
    [self setNeedsDisplay];
}

- (void)startPulsing {
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        self.alpha = 0.6;
    } completion:nil];
}

- (void)stopPulsing {
    [self.layer removeAllAnimations];
}

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholder:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder {
    [self setImageWithURL:url placeholder:placeholder success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder success:(void (^)(UIImage *))success failure:(void (^)(NSError *))failure {
    self.avatarImage = placeholder;
    [[SDWebImageManager sharedManager] downloadWithURL:url
                                               options:0
                                              progress:nil
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                 if (error) {
                                                     if (failure) {
                                                         failure(error);
                                                     }
                                                     return;
                                                 }
                                                 self.avatarImage = image;
                                                 if (success) {
                                                     success(image);
                                                 }
                                             }];
}

@end
