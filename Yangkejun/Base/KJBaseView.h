//
//  KJBaseView.h
//  启蒙画板
//
//  Created by 杨科军 on 2018/10/23.
//  Copyright © 2018 杨科军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJBaseView : UIView

@property(nonatomic,strong) CAShapeLayer *shapeLayer;
@property(nonatomic,strong) UIBezierPath *path;

@end

NS_ASSUME_NONNULL_END
