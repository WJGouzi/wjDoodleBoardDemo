//
//  wjDoodleBoardView.m
//  wjDoodleBoardDemo
//
//  Created by gouzi on 2017/5/25.
//  Copyright © 2017年 wj. All rights reserved.
//

#import "wjDoodleBoardView.h"
#import "wjBezierPath.h"
//#import "wjColorView.h"

@interface wjDoodleBoardView ()

@property (nonatomic, strong) wjBezierPath *path;

@property (nonatomic, strong) NSMutableArray *allPathArray;

/** color */
@property (nonatomic, strong) UIColor *wjColor;

/* line width*/
@property (nonatomic, assign) CGFloat wjLineWidth;

/** wjColorView */
//@property (nonatomic, strong) wjColorView *colorView;

@end

@implementation wjDoodleBoardView

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.allPathArray addObject:image];
    [self setNeedsDisplay];
}

- (NSMutableArray *)allPathArray {
    if (!_allPathArray) {
        _allPathArray = [NSMutableArray array];
    }
    return _allPathArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawLine:)];
    [self addGestureRecognizer:pan];
    self.wjColor = [UIColor blackColor];
    self.wjLineWidth = 1.0f;
}

- (void)drawLine:(UIPanGestureRecognizer *)pan {
    // 拿到当前的路径
    CGPoint currentPoint = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        wjBezierPath *path = [[wjBezierPath alloc] init];
        [path setLineJoinStyle:kCGLineJoinRound];
        [path setLineCapStyle:kCGLineCapRound];
        path.color = self.wjColor;
        [path setLineWidth:self.wjLineWidth];
        [path moveToPoint:currentPoint];
        self.path = path;
        [self.allPathArray addObject:path];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self.path addLineToPoint:currentPoint];
        [self setNeedsDisplay];
    }
}

#pragma mark - 各种操作

// 设置颜色
- (void)wjDoodleViewSetColorWith:(UIColor *)color {
    self.wjColor = color;
}


// 线宽
- (void)wjDoodleViewSetLineWidth:(CGFloat)lineWidth {
    self.wjLineWidth = lineWidth;
}


// 清屏
- (void)wjClearPathInDoodleView {
    [self.allPathArray removeAllObjects];
    [self setNeedsDisplay];
}

- (void)wjUndoPathInDoodleView {
    [self.allPathArray removeLastObject];
    [self setNeedsDisplay];
}

static BOOL isClicked = YES;
- (void)wjErasePathInDoodleView {
    if (isClicked) {
        [self wjDoodleViewSetColorWith:[UIColor whiteColor]];
    } else {
        [self wjDoodleViewSetColorWith:[UIColor blackColor]];
    }
    isClicked = !isClicked;
}




#pragma mark - 重绘
- (void)drawRect:(CGRect)rect {
    for (wjBezierPath *path in self.allPathArray) {
        if ([path isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)path;
            [image drawInRect:rect];
        } else {
            [path.color set];
            [path stroke];
        }
    }
}


@end
