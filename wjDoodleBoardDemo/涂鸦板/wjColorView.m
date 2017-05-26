//
//  wjColorView.m
//  wjDoodleBoardDemo
//
//  Created by gouzi on 2017/5/25.
//  Copyright © 2017年 wj. All rights reserved.
//

#import "wjColorView.h"

@interface wjColorView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation wjColorView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.userInteractionEnabled = YES;

    // 这种方案是在颜色示意图上加一个点击手势，然后再进行选择颜色
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//    [self addGestureRecognizer:tap];
}

//- (UIColor *)tapAction:(UITapGestureRecognizer *)tap {
//    if (tap.state == UIGestureRecognizerStateEnded) {
//        
//        UIColor *color = [UIColor colorWithRed:self.wjRedValue green:self.wjGreenValue blue:self.wjBlueValue alpha:1.0f];
//        
//        // 添加通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"chooseColor" object:self userInfo:@{@"color" : color}];
//        
//        return color;
//    }
//    return nil;
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        [self addSubview:_imageView];
    }
    return _imageView;
}



- (void)setWjRedValue:(CGFloat)wjRedValue {
    _wjRedValue = wjRedValue;
    [self setNeedsDisplay];
}


- (void)setWjGreenValue:(CGFloat)wjGreenValue {
    _wjGreenValue = wjGreenValue;
    [self setNeedsDisplay];
}

- (void)setWjBlueValue:(CGFloat)wjBlueValue {
    _wjBlueValue = wjBlueValue;
    [self setNeedsDisplay];
}


- (void)postNotification {
    UIColor *color = [UIColor colorWithRed:self.wjRedValue green:self.wjGreenValue blue:self.wjBlueValue alpha:1.0f];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chooseColor" object:self userInfo:@{@"color" : color}];
}


- (void)drawRect:(CGRect)rect {
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    // 开启上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    UIColor *color = [UIColor colorWithRed:self.wjRedValue green:self.wjGreenValue blue:self.wjBlueValue alpha:1.0f];
    CGContextSetFillColorWithColor(ref, color.CGColor);
    // 渲染上下文
    CGContextFillRect(ref, rect);
    // 从上下文中获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    self.imageView.image = image;
    // 这一步则是在滑动颜色选择滑杆的时候，就重新设置颜色
    [self postNotification];
}


@end
