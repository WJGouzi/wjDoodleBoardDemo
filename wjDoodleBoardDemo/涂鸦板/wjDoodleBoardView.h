//
//  wjDoodleBoardView.h
//  wjDoodleBoardDemo
//
//  Created by gouzi on 2017/5/25.
//  Copyright © 2017年 wj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wjDoodleBoardView : UIView

// 设置颜色
- (void)wjDoodleViewSetColorWith:(UIColor *)color;

- (void)wjDoodleViewSetLineWidth:(CGFloat)lineWidth;

- (void)wjClearPathInDoodleView;

- (void)wjUndoPathInDoodleView;

- (void)wjErasePathInDoodleView;

/** image */
@property (nonatomic, strong) UIImage *image;

// 存放的是path
@property (nonatomic, strong) NSMutableArray *allPathArray;
@end
