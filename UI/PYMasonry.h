//
//  PYMasonry.h
//  yr
//
//  Created by yr on 15/9/23.
//  Copyright © 2015年 yr. All rights reserved.
//

#import <Masonry/Masonry.h>

/*masonry 简化操作*/
@interface MasonryUtil : NSObject

/**
 *doView: 需要添加的视图
 *height:  视图需要的高度
 *topViewAttr: 添加视图的top属性,可以是其他视图的top,down,centery。。。
 *topOffset:  添加视图的top属性偏移值
 */
typedef NSArray*(^MasSimplyAppendTo)(UIView *doView, CGFloat height, MASViewAttribute *topViewAttr, CGFloat topOffset);

/**
 **简单的添加视图到其他视图底部
 *toView: 视图添加位置
 *widthView: 视图宽度依据的视图,为什么不和toview一致,如果toview是scrollview会有问题
 */
+(MasSimplyAppendTo)simplyAppendTo:(UIView*)toView widthView:(UIView*)widthView;

/**
 **移除指定视图的一个布局限制
 */
+(void)removeConstraintsFromView:(UIView *)view aboutAttribute:(NSLayoutAttribute)attribute;

/**
 **移除指定视图的所有布局限制
 */
+(void)removeAllConstraintsFromView:(UIView *)view;

/**
 **移除指定视图的一个布局限制(原生态方式,通过xib指定的...)
 */
+(void)removeOriginalConstraintsFromView:(UIView *)view aboutAttribute:(NSLayoutAttribute)attribute;

/**
 **移除指定视图的所有布局限制(原生态方式,通过xib指定的...)
 */
+(void)removeOriginalAllConstraintsFromView:(UIView *)view;
@end

#define MasonryUtilRemoveConstraints(aboutView, attribute) \
    [MasonryUtil removeConstraintsFromView:(aboutView) aboutAttribute:(attribute)];

#define MasonryUtilRemoveAllConstraintsFromView(aboutView) \
[MasonryUtil removeAllConstraintsFromView:(aboutView)];


#define safeBlockCall(block,...) if(block) block(__VA_ARGS__)
