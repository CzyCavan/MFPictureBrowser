
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFPictureView.h"
#import "YYAnimatedImageView+TransitionImage.h"
@interface MFPictureView()
<
UIScrollViewDelegate
>
@property (nonatomic, assign) CGSize showPictureSize;
@property (nonatomic, assign) BOOL doubleClicks;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign, getter = isShowingAnimation) BOOL showingAnimation;
@property (nonatomic, assign, getter = isLoadingFinished) BOOL loadingFinished;
@property (nonatomic, assign, getter = isLocalImage) BOOL localImage;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation MFPictureView

- (instancetype)initWithPictureModel:(id<MFPictureModelProtocol>)pictureModel {
    self = [super init];
    if (self) {
        self.localImage = false;
        if (pictureModel.imageName) {
            self.localImage = true;
        }
        [self setupUI];
        self.pictureModel = pictureModel;
    }
    return self;
}

- (void)setupUI {
    self.delegate = self;
    self.alwaysBounceVertical = true;
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = false;
    self.showsVerticalScrollIndicator = false;
    self.maximumZoomScale = 2;

    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = 3;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.bounds;
    imageView.userInteractionEnabled = true;
    _imageView = imageView;
    [self addSubview:imageView];
    
    if (!self.isLocalImage) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 3, [UIScreen mainScreen].bounds.size.width, 3)];
        progressView.progressViewStyle = UIProgressViewStyleDefault;
        progressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.2];
        progressView.trackTintColor = [UIColor blackColor];
        [self addSubview:progressView];
        _progressView = progressView;
    }

    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTapGesture];
}

#pragma mark - 外部方法

- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    self.imageView.frame = rect;
    self.showingAnimation = true;
    [UIView animateWithDuration:0.25 delay:0 options:7 << 16 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        self.imageView.frame = [self getImageActualFrame:self.showPictureSize];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
            self.showingAnimation = false;
        }
    }];
}

- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    self.progressView.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:7 << 16 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        CGRect toRect = rect;
        toRect.origin.y += self.offsetY;
        // 这一句话用于在放大的时候去关闭
        toRect.origin.x += self.contentOffset.x;
        self.imageView.frame = toRect;
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
                self.pictureModel = nil;
            }
        }
    }];
}

#pragma mark - 私有方法

- (void)setPictureModel:(id<MFPictureModelProtocol>)pictureModel {
    if (!pictureModel) {
        return;
    }
    _pictureModel = pictureModel;
    if (pictureModel.imageName) {
        if (pictureModel.imageType == MFImageTypeGIF) {
            UIImage *image = pictureModel.posterImage;
            [self setPictureSize:image.size];
            self.imageView.image = image;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                YYImage *animatedImage = [YYImage imageNamed:pictureModel.imageName];
                if (animatedImage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                            [_pictureDelegate pictureView:self image:nil animatedImage:animatedImage didLoadAtIndex:self.index];
                        }
                        [self setPictureSize:animatedImage.size];
                        [self.imageView animatedTransitionAnimatedImage:animatedImage];
                    });
                }
            });
        }else {
            UIImage *image = [UIImage imageNamed:pictureModel.imageName];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                        [_pictureDelegate pictureView:self image:image animatedImage:nil didLoadAtIndex:self.index];
                    }
                    [self setPictureSize:image.size];
                    self.imageView.image = image;
                });
            }
        }
    }else {
        self.progressView.alpha = 1;
        UIImage *image = pictureModel.posterImage;
        [self setPictureSize:image.size];
        __weak __typeof(self)weakSelf = self;
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:pictureModel.imageURL] placeholder:image options:YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionProgressiveBlur progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.progressView setProgress:(1.0 * receivedSize / expectedSize) animated:true];
            });
        } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (stage == YYWebImageStageProgress) {
                    strongSelf.progressView.alpha = 1;
                }else {
                    strongSelf.progressView.alpha = 0;
                }
                if (!error && (stage == YYWebImageStageFinished || stage == YYWebImageStageCancelled)) {
                    strongSelf.loadingFinished = true;
                    [strongSelf setPictureSize:image.size];
                    if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                        if (pictureModel.imageType == MFImageTypeGIF) {
                            [_pictureDelegate pictureView:strongSelf image:nil animatedImage:(YYImage *)image didLoadAtIndex:strongSelf.index];
                        }else {
                            [_pictureDelegate pictureView:strongSelf image:image animatedImage:nil didLoadAtIndex:strongSelf.index];
                        }
                        
                    }
                }
            });
        }];
    }
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.25 delay:0 options:7 << 16  animations:^{
            CGPoint center = self.imageView.center;
            center.x = self.contentSize.width * 0.5;
            self.imageView.center = center;
        } completion:nil];
    }
}

- (void)setLastContentOffset:(CGPoint)lastContentOffset {
    // 如果用户没有在拖动，并且绽放比 > 0.15
    if (!(self.dragging == false && _scale > 0.15)) {
        _lastContentOffset = lastContentOffset;
    }
}

- (void)setPictureSize:(CGSize)pictureSize {
    _pictureSize = pictureSize;
    if (CGSizeEqualToSize(pictureSize, CGSizeZero)) {
        return;
    }
    // 计算实际的大小
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = screenW / pictureSize.width;
    CGFloat height = scale * pictureSize.height;
    self.showPictureSize = CGSizeMake(screenW, height);
}

- (void)setShowPictureSize:(CGSize)showPictureSize {
    _showPictureSize = showPictureSize;
    self.imageView.frame = [self getImageActualFrame:showPictureSize];
    self.contentSize = self.imageView.frame.size;
}

- (CGRect)getImageActualFrame:(CGSize)imageSize {
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (imageSize.height < [UIScreen mainScreen].bounds.size.height) {
        y = ([UIScreen mainScreen].bounds.size.height - imageSize.height) / 2;
    }
    return CGRectMake(x, y, imageSize.width, imageSize.height);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - 监听方法

- (void)doubleClick:(UITapGestureRecognizer *)gesture {
    if (!self.isLoadingFinished) {
        return;
    }
    CGFloat newScale = 2;
    if (_doubleClicks) {
        newScale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
    _doubleClicks = !_doubleClicks;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
    // 保存 offsetY
    _offsetY = scrollView.contentOffset.y;
    self.progressView.alpha = 0;
    // 正在动画
    if ([self.imageView.layer animationForKey:@"transform"] != nil) {
        return;
    }
    // 用户正在缩放
    if (self.zoomBouncing || self.zooming) {
        return;
    }
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    // 滑动到中间
    if (scrollView.contentSize.height > screenH) {
        // 代表没有滑动到底部
        if (_lastContentOffset.y > 0 && _lastContentOffset.y <= scrollView.contentSize.height - screenH) {
            return;
        }
    }
    _scale = fabs(_lastContentOffset.y) / screenH;
    
    // 如果内容高度 > 屏幕高度
    // 并且偏移量 > 内容高度 - 屏幕高度
    // 那么就代表滑动到最底部了
    if (scrollView.contentSize.height > screenH &&
        _lastContentOffset.y > scrollView.contentSize.height - screenH) {
        _scale = (_lastContentOffset.y - (scrollView.contentSize.height - screenH)) / screenH;
    }
    
    // 条件1：拖动到顶部再继续往下拖
    // 条件2：拖动到顶部再继续往上拖
    // 两个条件都满足才去设置 scale -> 针对于长图
    if (scrollView.contentSize.height > screenH) {
        // 长图
        if (scrollView.contentOffset.y < 0 || _lastContentOffset.y > scrollView.contentSize.height - screenH) {
            [_pictureDelegate pictureView:self scale:_scale];
        }
    }else {
        [_pictureDelegate pictureView:self scale:_scale];
    }
    
    // 如果用户松手
    if (scrollView.dragging == false) {
        if (_scale > 0.08 && _scale <= 1) {
            // 关闭
            [_pictureDelegate pictureView:self didClickAtIndex:self.index];
            // 设置 contentOffset
            [scrollView setContentOffset:_lastContentOffset animated:false];
        }else {
            if (!_scale && !self.isLoadingFinished) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.progressView.alpha = 1;
                }];
            }
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGPoint center = _imageView.center;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    center.y = scrollView.contentSize.height * 0.5 + offsetY;
    _imageView.center = center;
    if (scrollView.zoomScale == 1 && !self.isLoadingFinished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.progressView.alpha = 1;
        }];
    }
    // 如果是缩小，保证在屏幕中间
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        center.x = scrollView.contentSize.width * 0.5 + offsetX;
        _imageView.center = center;
    }
}

@end
