//
//  WJEditPhotoVC.m
//  photoEditDemo
//
//  Created by 王钧 on 2017/11/28.
//  Copyright © 2017年 王钧. All rights reserved.
//  编辑图片

#import "WJEditPhotoVC.h"

@interface WJEditPhotoVC ()

// 开始手指的点
/* startPoint*/
@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, strong) UIImageView *editImageView;

/** coverView*/
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIImage *neweditImage;

@property (nonatomic, strong) UIImageView *lookOutImageView;

@property (nonatomic, assign) CGRect coverRect;

@property (nonatomic, strong) UIImageView *noticeImageView;

@end

@implementation WJEditPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self versionAndIsShowJudge];
}


- (void)versionAndIsShowJudge {
    //获取版本号
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
    NSString *version = [dict objectForKey:@"CFBundleShortVersionString"];
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    if (![currentVersion isEqualToString:version]) {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isFirst"];
        NSString *isFirstFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirst"];
        if (!isFirstFlag.length) {
            [[NSUserDefaults standardUserDefaults] setObject:@"isFirstShow" forKey:@"isFirst"];
            [self creatUI];
        }
    }
}

- (void)creatUI {
    UIView *noticeView = [[UIView alloc] initWithFrame:self.view.frame];
    noticeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:noticeView];
    noticeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeNoticeViewAction:)];
    [noticeView addGestureRecognizer:tap];
    UIImageView *noticeImageView = [[UIImageView alloc] init];
    noticeImageView.image = [UIImage imageNamed:@"finger"];
    noticeImageView.frame = CGRectMake(50, 100, 50, 50);
    [noticeView addSubview:noticeImageView];
    _noticeImageView = noticeImageView;
    
    // 提示文字
    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.text = @"滑动手指截取图片";
    noticeLabel.textColor = [UIColor redColor];
    noticeLabel.font = [UIFont systemFontOfSize:15.f];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    [noticeLabel sizeToFit];
    noticeLabel.center = self.view.center;
    [noticeView addSubview:noticeLabel];
    
    [self imageViewMoveAction];
}

- (void)imageViewMoveAction {
    // 1.创建动画对象
    CABasicAnimation *animation = [CABasicAnimation animation];
    // 2.设置属性值
    animation.keyPath = @"position";
    animation.toValue = (id)[NSValue valueWithCGPoint:CGPointMake(150, 250)];
    // 动画完成时不要移除动画
    animation.removedOnCompletion = NO;
    /* The legal values->动画完成后的状态
     * are `backwards', `forwards', `both' and `removed'. Defaults to
     * `removed'. */
    animation.repeatCount = MAXFLOAT;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = YES;
    animation.duration = 2;
    // 3.添加动画
    [_noticeImageView.layer addAnimation:animation forKey:nil]; // 动画完成时会自动删除动画
}

- (void)removeNoticeViewAction:(UITapGestureRecognizer *)tap {
    UIView *coverView = tap.view;
    [coverView removeFromSuperview];
}



- (void)setUpUI {
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = self.selectedImage;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:backgroundImageView];
    UIView *coveredView = [[UIView alloc] initWithFrame:self.view.frame];
    coveredView.userInteractionEnabled = YES;
    coveredView.backgroundColor = [UIColor blackColor];
    coveredView.alpha = 0.6;
    [backgroundImageView addSubview:coveredView];

    // 剪切的imageView
    UIImageView *editImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    editImageView.contentMode = UIViewContentModeScaleAspectFit;
    editImageView.image = self.selectedImage;
    [coveredView addSubview:editImageView];
    editImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInPicture:)];
    [editImageView addGestureRecognizer:pan];
    self.editImageView = editImageView;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, 50, 50, 30);
    [button addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    sureButton.frame = CGRectMake(300, 50, 50, 30);
    [sureButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureButton];
    [self.view bringSubviewToFront:sureButton];
    
    UIImageView *lookOutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 600, 50, 50)];
    lookOutImageView.contentMode = UIViewContentModeScaleAspectFit;
    lookOutImageView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:lookOutImageView];
    [self.view bringSubviewToFront:lookOutImageView];
    self.lookOutImageView = lookOutImageView;
}


- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor darkGrayColor];
        _coverView.alpha = 0.6;
    }
    return _coverView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.editImageView.frame = self.view.frame;
    self.editImageView.image = self.selectedImage;
}

// 在storyBoard中拖入的一个手势
- (void)panInPicture:(UIPanGestureRecognizer *)pan {
    
    CGPoint currentPoint = [pan locationInView:self.view];
    // 1判断手势状态
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 获取当前点
        self.startPoint = currentPoint;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        // 移除遮盖
        [self.coverView removeFromSuperview];
        CGFloat x = self.startPoint.x;
        CGFloat y = self.startPoint.y;
        CGFloat width = currentPoint.x - self.startPoint.x;
        CGFloat height = currentPoint.y - self.startPoint.y;
        if (width < 0) {
            width = -width;
            x = x - width;
        }
        if (height < 0) {
            height = -height;
            y = y - height;
        }
        CGRect rect = CGRectMake(x, y, width, height);
        // 添加一个view
        self.coverView.frame = rect;
        [self.editImageView addSubview:_coverView]; // 解决下次进行裁剪的时候没有coverview的覆盖
        self.coverRect = rect;
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        NSLog(@"coverView:%@ - coverRect:%@",NSStringFromCGRect(self.coverView.frame), NSStringFromCGRect(self.coverRect));
        [self.coverView removeFromSuperview];
        UIImageView *resultImageView = self.editImageView;
        UIImage *resultImage = [self editImageFromView:resultImageView];
        // 超过遮盖以外的内容裁剪掉
        UIGraphicsBeginImageContextWithOptions(self.editImageView.bounds.size, NO, [UIScreen mainScreen].scale);
        // 设置一个裁剪区域
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.coverView.frame];
        [clipPath addClip];
        // 移除遮盖
        // 进行渲染
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.editImageView.layer renderInContext:ctx];
        // 生成一张图片
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.editImageView.image = newImage;
        NSLog(@"coverView:%@ - coverRect:%@",NSStringFromCGRect(self.coverView.frame), NSStringFromCGRect(self.coverRect));
        self.neweditImage = resultImage;
        self.lookOutImageView.image = resultImage;
    }
}


- (UIImage *)editImageFromView:(UIView *)theView {
    //截取全屏
    UIGraphicsBeginImageContext(theView.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //截取所需区域
    CGRect captureRect = self.coverRect;
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, captureRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    return newImage;
}


- (void)cancelAction:(UIButton *)btn {
//    self.editImageView.frame = self.view.frame;
//    self.editImageView.image = self.selectedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sureAction:(UIButton *)btn {
    self.block(self.neweditImage);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
