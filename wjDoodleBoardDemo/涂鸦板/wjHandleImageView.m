//
//  wjHandleImageView.m
//  wjDoodleBoardDemo
//
//  Created by gouzi on 2017/5/25.
//  Copyright © 2017年 wj. All rights reserved.
//

#import "wjHandleImageView.h"


@interface wjHandleImageView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imgV;


@end


@implementation wjHandleImageView

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imgV.image = image;
}

- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgV.userInteractionEnabled = YES;
        [self addSubview:_imgV];
        [self handleViewWithGesture];
    }
    return _imgV;
}


- (void)handleViewWithGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.imgV addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    pinch.delegate = self;
    [self.imgV addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationAction:)];
    rotate.delegate = self;
    [self.imgV addGestureRecognizer:rotate];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.imgV addGestureRecognizer:longPress];
}


#pragma mark - 各种手势操作
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan translationInView:pan.view];
    pan.view.transform = CGAffineTransformTranslate(pan.view.transform, currentPoint.x, currentPoint.y);
    // 复位操作
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    pinch.view.transform = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
    pinch.scale = 1.0f;
}

- (void)rotationAction:(UIRotationGestureRecognizer *)rotate {
    rotate.view.transform = CGAffineTransformRotate(rotate.view.transform, rotate.rotation);
    rotate.rotation = 0;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        // 开始操作的时候进行设置到视图中，不然会执行很多次，也会渲染很多次，在撤销操作的时候体验不好。
        // 长按进行绘制到当前的视图中
        [UIView animateWithDuration:0.3 animations:^{
            self.imgV.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.imgV.alpha = 1.0f;
                // 进行截屏操作
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                [self.layer renderInContext:ctx];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                // 传递出图片
                if ([self.delegate respondsToSelector:@selector(handleImageViewWithView: newImage:)]) {
                    [self.delegate handleImageViewWithView:self newImage:newImage];
                }
                [self removeFromSuperview];
            }];
        }];
    }
}



@end
