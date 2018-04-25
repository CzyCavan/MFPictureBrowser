//
//  YYAnimatedImageView+TransitionImage.h
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/25.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <YYImage/YYImage.h>

@interface YYAnimatedImageView (TransitionImage)
- (void)animatedTransitionAnimatedImage:(YYImage *)animatedImage;
- (void)animatedTransitionImage:(UIImage *)image;
@end
