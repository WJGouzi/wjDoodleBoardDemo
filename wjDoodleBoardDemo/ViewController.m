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


@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, wjHandleImageViewDelegate>

@property (weak, nonatomic) IBOutlet wjColorView *colorChooseView;
@property (weak, nonatomic) IBOutlet wjDoodleBoardView *doodleBoardView;

@property (weak, nonatomic) IBOutlet UISlider *wjRedSlider;

@property (weak, nonatomic) IBOutlet UISlider *wjGreenSlider;

@property (weak, nonatomic) IBOutlet UISlider *wjBlueSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 接受通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorChoose:) name:@"chooseColor" object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
}

- (IBAction)wjUndoAction:(UIBarButtonItem *)sender {
    [self.doodleBoardView wjUndoPathInDoodleView];
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
    UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
    cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraPicker.delegate = self;
    [self presentViewController:cameraPicker animated:YES completion:nil];
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
    // 保存
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}

#pragma mark - 保存需要实现的方法
// 唯一需要实现的方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"保存成功！" message:@"你可以到相册中查看" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 相册、相机的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    NSLog(@"info is %@", info);
    UIImage *image = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
    wjHandleImageView *handleView = [[wjHandleImageView alloc] initWithFrame:self.doodleBoardView.frame];
    handleView.backgroundColor = [UIColor clearColor];
    handleView.image = image;
    handleView.delegate = self;
    [self.view addSubview:handleView];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"可对图片进行缩放\\旋转\\移动等编辑\n但需要'长按'才能保存到绘图板中!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma wjHandleImageViewDelegate
- (void)handleImageViewWithView:(wjHandleImageView *)handleView newImage:(UIImage *)newImage {
    self.doodleBoardView.image = newImage;
}




@end
