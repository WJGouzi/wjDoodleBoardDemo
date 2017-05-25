//
//  wjHandleImageView.h
//  wjDoodleBoardDemo
//
//  Created by gouzi on 2017/5/25.
//  Copyright © 2017年 wj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class wjHandleImageView;
@protocol wjHandleImageViewDelegate <NSObject>

@optional
- (void)handleImageViewWithView:(wjHandleImageView *)handleView newImage:(UIImage *)newImage;

@end


@interface wjHandleImageView : UIView

/** image */
@property (nonatomic, strong) UIImage *image;

/** delegate */
@property (nonatomic, weak) id<wjHandleImageViewDelegate> delegate;

@end
