//
//  KJHomeEmitterView.h
//  MoLiao
//
//  Created by 杨科军 on 2018/7/30.
//  Copyright © 2018年 杨科军. All rights reserved.
//  首页 - 粒子效果背景

#import <UIKit/UIKit.h>

@interface KJHomeEmitterView : UIView

+ (instancetype)createEmitterView:(void(^)(KJHomeEmitterView *obj))block;

// 链接式设置属性
@property(nonatomic,strong,readonly) KJHomeEmitterView *(^Tag)(NSInteger);
@property(nonatomic,strong,readonly) KJHomeEmitterView *(^Frame)(CGRect);//frame
@property(nonatomic,strong,readonly) KJHomeEmitterView *(^BackgroundColor)(UIColor *);//backgroundColor


@end
