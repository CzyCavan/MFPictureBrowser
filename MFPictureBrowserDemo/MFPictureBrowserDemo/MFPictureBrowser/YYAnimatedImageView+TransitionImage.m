//
//  YYAnimatedImageView+TransitionImage.m
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/25.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "YYAnimatedImageView+TransitionImage.h"

@implementation YYAnimatedImageView (TransitionImage)
- (void)animatedTransitionAnimatedImage:(YYImage *)animatedImage {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = animatedImage;
                    } completion:NULL];
}

- (void)animatedTransitionImage:(UIImage *)image {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = image;
                    } completion:NULL];
}
@end
