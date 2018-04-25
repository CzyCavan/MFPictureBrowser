

#import "RemoteImageViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import "MFPictureModel.h"
#import "MFPictureBrowser/YYAnimatedImageView+TransitionImage.h"
@interface RemoteImageViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *picList;
@end

@implementation RemoteImageViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 20) collectionViewLayout:flow];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (NSMutableArray *)picList {
    if (!_picList) {
        _picList = @[
                     [[MFPictureModel alloc] initWithURL:@"https://pic2.zhimg.com/80/v2-9d0d69e867ed790715fa11d1c55f3151_hd.jpg"
                                               imageName:nil
                                               imageType:MFImageTypeOther],
                     [[MFPictureModel alloc] initWithURL:@"https://ww3.sinaimg.cn/mw690/79ba7be1jw1e5jdfqobcdg20bh06gwwz.gif"
                                               imageName:nil
                                               imageType:MFImageTypeGIF],
                     [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903092531_ZTaFm.gif"
                                               imageName:nil
                                               imageType:MFImageTypeGIF],
                     [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903092605_3KdcV.gif"
                                               imageName:nil
                                               imageType:MFImageTypeGIF],
                     [[MFPictureModel alloc] initWithURL:@"https://pic2.zhimg.com/e336f051665a796be2d86ab37aa1ffb9_r.jpg"
                                               imageName:nil
                                               imageType:MFImageTypeLongImage],
                     [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903085932_PTrKh.gif"
                                               imageName:nil
                                               imageType:MFImageTypeGIF],
                     [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903085850_ZHaP5.gif"
                                               imageName:nil
                                               imageType:MFImageTypeGIF],
                     ].mutableCopy;
    }
    return _picList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[MFDisplayPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    YYImageCache *imageCache = [YYWebImageManager sharedManager].cache;
//    [imageCache.memoryCache removeAllObjects];
//    [imageCache.diskCache removeAllObjects];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.picList.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView
                  cellForItemAtIndexPath: (NSIndexPath *)indexPath {
    
    MFDisplayPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    MFPictureModel *pictureModel = self.picList[indexPath.row];
    NSURL *url = [NSURL URLWithString:pictureModel.imageURL];
    __weak MFDisplayPhotoCollectionViewCell *weakCell = cell;
    [weakCell.displayImageView yy_setImageWithURL:url placeholder:pictureModel.posterImage options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (!error && stage == YYWebImageStageFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (pictureModel.imageType == MFImageTypeGIF) {
                    pictureModel.posterImage = ((YYImage *)image).posterImage;
                    weakCell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
                    weakCell.tagImageView.alpha = 1;
                }else if (pictureModel.imageType == MFImageTypeLongImage) {
                    pictureModel.posterImage = image;
                    weakCell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
                    weakCell.tagImageView.alpha = 1;
                }else {
                    pictureModel.posterImage = image;
                    weakCell.tagImageView.image = nil;
                    weakCell.tagImageView.alpha = 0;
                }
            });
        }else if (error || stage == YYWebImageStageCancelled) {
            pictureModel.posterImage = image;
            weakCell.tagImageView.image = nil;
            weakCell.tagImageView.alpha = 0;
        }
    }];
    return cell;
}

- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath: (NSIndexPath *)indexPath{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 20 - 20)/3, ([UIScreen mainScreen].bounds.size.width - 20 - 20)/3);
}

- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex: (NSInteger)section{
    return 5.0f;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex: (NSInteger)section{
    return 5.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MFPictureBrowser *browser = [[MFPictureBrowser alloc] init];
    browser.delegate = self;
    [browser showImageFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (YYAnimatedImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView;
}

- (id<MFPictureModelProtocol>)pictureBrowser:(MFPictureBrowser *)pictureBrowser pictureModelAtIndex:(NSInteger)index {
    MFPictureModel *pictureModel = self.picList[index];
    return pictureModel;
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageDidLoadAtIndex:(NSInteger)index image:(UIImage *)image animatedImage:(YYImage *)animatedImage error:(NSError *)error {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFPictureModel *pictureModel = self.picList[index];
    if (animatedImage) {
        pictureModel.posterImage = animatedImage.posterImage;
    }else if (image) {
        pictureModel.posterImage = image;
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
