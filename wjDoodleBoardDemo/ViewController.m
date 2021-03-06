//
//  ViewController.m
//  wjDoodleBoardDemo
//
//  Created by gouzi on 2017/5/25.
//  Copyright © 2017年 wj. All rights reserved.
//

#import "ViewController.h"
#import "wjColorView.h"
#import "wjDoodleBoardView.h"
#import "wjHandleImageView.h"
#import "WJNewEditionTestManager.h"
#import "WJEditPhotoVC.h"

#define appID @"1251844760"

#define isIPhoneX [[UIScreen mainScreen] bounds].size.width == 375.f && [[UIScreen mainScreen] bounds].size.height == 812.0f

#define isIPhoneSE [[UIScreen mainScreen] bounds].size.width == 320.f && [[UIScreen mainScreen] bounds].size.height == 568.0f

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, wjHandleImageViewDelegate>

@property (weak, nonatomic) IBOutlet wjColorView *colorChooseView;
@property (weak, nonatomic) IBOutlet wjDoodleBoardView *doodleBoardView;
@property (nonatomic, strong) wjHandleImageView *handleView;

@property (weak, nonatomic) IBOutlet UISlider *wjRedSlider;

@property (weak, nonatomic) IBOutlet UISlider *wjGreenSlider;

@property (weak, nonatomic) IBOutlet UISlider *wjBlueSlider;
@property (weak, nonatomic) IBOutlet UIToolbar *WJToolBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:177/255.0 green:219/255.0 blue:254/251.0 alpha:1.0];
    // 接受通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorChoose:) name:@"chooseColor" object:nil];
    // 检测有误更新程序
    [WJNewEditionTestManager checkNewEditionWithAppID:appID ctrl:self];
    // 屏幕适配
    [self adjustIPhoneSEScreen];
}

- (BOOL)prefersStatusBarHidden {
    if (isIPhoneX) {
        return NO;
    } else {
        return YES;
    }
}

//Interface的方向是否会跟随设备方向自动旋转，如果返回NO,后两个方法不会再调用
- (BOOL)shouldAutorotate {
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        return NO;
    } else {
        return YES;
    }
}

//返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskAll;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - SE屏幕的适配
- (void)adjustIPhoneSEScreen {
    if (isIPhoneSE) {
        NSLog(@"is iphone SE");
        for (UIBarButtonItem *item in self.WJToolBar.items) {
            [item setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f]} forState:UIControlStateNormal];
            [item setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f]} forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - 颜色选择
- (IBAction)wjRedColorAction:(UISlider *)sender {
    self.colorChooseView.wjRedValue = sender.value;
}

- (IBAction)wjGreenColorAction:(UISlider *)sender {
    self.colorChooseView.wjGreenValue = sender.value;
}

- (IBAction)wjBlueColorAction:(UISlider *)sender {
    self.colorChooseView.wjBlueValue = sender.value;
}


#pragma mark - 个性化设置
// 颜色选择
- (void)colorChoose:(NSNotification *)notification {
    UIColor *color = (UIColor *)notification.userInfo[@"color"];
    [self.doodleBoardView wjDoodleViewSetColorWith:color];
}

- (IBAction)wjSetLineWidth:(UISlider *)sender {
    [self.doodleBoardView wjDoodleViewSetLineWidth:sender.value];
}

- (IBAction)wjClearScreenAction:(UIBarButtonItem *)sender {
    [self.doodleBoardView wjClearPathInDoodleView];
    if ([self.view.subviews containsObject:(UIView *)self.handleView]) {
        [self.handleView removeFromSuperview];
    }
}

- (IBAction)wjUndoAction:(UIBarButtonItem *)sender {
    if ([self.view.subviews containsObject:(UIView *)self.handleView]) {
        [self.handleView removeFromSuperview];  // 如果有未编辑的图片就直接移除掉
    } else {
        [self.doodleBoardView wjUndoPathInDoodleView];
    }
}

static BOOL isClicked = YES;
- (IBAction)wjEraseAction:(UIBarButtonItem *)sender {
    NSDictionary *dict = @{
                           NSForegroundColorAttributeName : [UIColor redColor]
                           };
    [sender setTitleTextAttributes:isClicked ? dict : nil forState:UIControlStateNormal];
    [self.doodleBoardView wjErasePathInDoodleView];
    if (isClicked) {
        // rgb归为0，->黑色
        self.wjRedSlider.value = self.wjGreenSlider.value = self.wjBlueSlider.value = 0.0f;
    }
    isClicked = !isClicked;
}

- (IBAction)wjCameraTakePhotoAction:(UIBarButtonItem *)sender {
    // 设备是否支持摄像头
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraPicker.delegate = self;
        [self presentViewController:cameraPicker animated:YES completion:nil];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"打开摄像头失败" message:@"您的设备不支持摄像头或未被开启！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];    }
}

- (IBAction)wjChoosePhotoFromAlbumAction:(UIBarButtonItem *)sender {
    UIImagePickerController *albumPicker = [[UIImagePickerController alloc] init];
    albumPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    albumPicker.delegate = self;
    [self presentViewController:albumPicker animated:YES completion:nil];
}


// 保存到相册中
- (IBAction)wjSaveDoodleAction:(UIBarButtonItem *)sender {
    UIGraphicsBeginImageContextWithOptions(self.doodleBoardView.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.doodleBoardView.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 判断有没有进行绘画
    if (self.doodleBoardView.allPathArray.count > 0) {
        // 有就进行保存
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
    } else {
        // 给出提示，还没进行绘画
        [self wjShowAlertNoticeWithTitle:@"提示" message:@"您还未在画布上进行绘制\n保存无法执行!" actionTitle:@"知道了"];
    }
}

#pragma mark - 保存需要实现的方法
// 唯一需要实现的方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self wjShowAlertNoticeWithTitle:@"保存成功!" message:@"你可以到相册中查看" actionTitle:@"确定"];
}

/**
 显示提示框
 
 @param title 提示标题
 @param message 提示信息
 @param actionTitle 按钮文字
 */
- (void)wjShowAlertNoticeWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - 相册、相机的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    WJEditPhotoVC *editPhotoVC = [[WJEditPhotoVC alloc] init];
    editPhotoVC.selectedImage = image;
    __weak typeof(self) weakSelf = self;
    editPhotoVC.block = ^(UIImage *image) {
        wjHandleImageView *handleView = [[wjHandleImageView alloc] initWithFrame:weakSelf.doodleBoardView.frame];
        handleView.contentMode = UIViewContentModeScaleAspectFit;
        handleView.backgroundColor = [UIColor clearColor];
        handleView.image = image;
        handleView.delegate = self;
        [weakSelf.view addSubview:handleView];
        weakSelf.handleView = handleView;
        dispatch_async(dispatch_get_main_queue(), ^{

            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"可对图片进行缩放\\旋转\\移动等编辑\n但需要'长按'才能保存到绘图板中!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];
        });
    };
    [self presentViewController:editPhotoVC animated:YES completion:nil];
}

#pragma wjHandleImageViewDelegate
- (void)handleImageViewWithView:(wjHandleImageView *)handleView newImage:(UIImage *)newImage {
    self.doodleBoardView.image = newImage;
}




@end
