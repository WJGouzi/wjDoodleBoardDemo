//
//  WJEditPhotoVC.h
//  photoEditDemo
//
//  Created by 王钧 on 2017/11/28.
//  Copyright © 2017年 王钧. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WJEditPhotoBlock)(UIImage *image);

@interface WJEditPhotoVC : UIViewController

@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, strong) WJEditPhotoBlock block;

@end
