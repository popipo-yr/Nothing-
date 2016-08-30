//
//  UIView.m
//
//
//  Created by yr on 15/9/4.
//  Copyright (c) 2015年 yr. All rights reserved.
//

#import "UIView_Corner.h"
#import <objc/runtime.h>

/////////////////////////////////
@interface  UIView (corner_param)

@property (nonatomic, assign) UIRectCorner cornersave;

- (void)setupMask;

@end


/////////////////////////////////
#pragma mark - #UiView+Corner


@implementation UIView (corner)

- (UIRectCorner)cornersave
{
    UIRectCorner ret = {0};
    [objc_getAssociatedObject(self, @selector(cornersave)) getValue:&ret];
    return ret;
}


- (void)setCorners:(UIRectCorner)corner
{
    NSValue *valueObj = [NSValue valueWithBytes:&corner objCType:@encode(UIRectCorner)];
    objc_setAssociatedObject(self, @selector(cornersave), valueObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (CAShapeLayer *)strokeLayerSave
{
    CAShapeLayer *ret = objc_getAssociatedObject(self, @selector(strokeLayerSave));
    if (ret == nil) {
        ret = [CAShapeLayer layer];
        objc_setAssociatedObject(self, @selector(strokeLayerSave), ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return ret;
}


- (void)setupMask
{
    UIRectCorner corners = self.cornersave;

    if (self.bounds.size.height == 0 || self.cornersave == 0)
        return;

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(5, 10)];

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.layer.mask = maskLayer;

    CGFloat lineWidth = 0.5f;

    CGRect useRect = self.bounds;

    if ((corners & UIRectCornerTopLeft) != UIRectCornerTopLeft) {//top没半圆
        useRect.origin.y    -= 100;  //100为了超出范围
        useRect.size.height += 100;
    }

    if ((corners & UIRectCornerBottomLeft) != UIRectCornerBottomLeft) {//没有下半部
        useRect.size.height += 100;
    }

    UIBezierPath *strokePath;
    strokePath = [UIBezierPath bezierPathWithRoundedRect:useRect
                                       byRoundingCorners:(UIRectCornerAllCorners)
                                             cornerRadii:CGSizeMake(5.0f, 10.0f)];
    CAShapeLayer *strokeLayer = [self strokeLayerSave];
    strokeLayer.path      = strokePath.CGPath;
    strokeLayer.fillColor = nil;
    //RR_BORDER_COLOR
    strokeLayer.strokeColor = [UIColor colorWithRed:(195.0/255.0f) green:(195.0/255.0f) blue:(195.0/255.0f) alpha:1.0].CGColor;
    strokeLayer.lineWidth   = (lineWidth*2.0f - 0.2f);   /*减了0.2是因为和直接设置borderWidth有区别*/
    strokeLayer.lineWidth   = lineWidth;   /*方法1,方法1会受到屏幕像素精度影响*/
    strokeLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.layer.mask = maskLayer;
}


- (void)mask:(UIRectCorner)corners
{
    self.corners = corners;
}


@end
