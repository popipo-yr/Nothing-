//
//  UIView.h
//
//
//  Created by yr on 15/9/4.
//  Copyright (c) 2015年 yr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRLineInfo;

/*******************************************/
/*视图呈现半角扩展*/
/***************************************/
@interface UIView (corner)
//设置圆角位置
- (void)mask:(UIRectCorner)corners;
@end



/***************************************/
/*画线*/
/***************************************/
@interface UIView (Line_Draw)

/*设置true时,画线动作将不会执行*/
@property (nonatomic, assign)  BOOL drawLineDisable;

/*添加线条*/
- (void)addLineInfo:(RRLineInfo *)lineInfo; //默认不会清空以前的线条
- (void)addLineInfo:(RRLineInfo *)lineInfo clearOld:(BOOL)clear;
/*清空线条信息*/
- (void)clearLineInfo;

@end



/******************************/
/*线条参数*/
/*关于特殊的线条,由一个矩形的四个顶点创建的线段*/
/***************************************/
@interface RRLineInfo : NSObject

    typedef  NS_ENUM (NSUInteger, RRLinePoint){
    RRLinePointLeftUP,     //左上角
    RRLinePointLeftDown,   //左下角
    RRLinePointRightUp,    //右上角
    RRLinePointRightDown   //右下角
};


@property(nonatomic, assign) CGFloat width; ///线条宽度
@property(nonatomic, strong) UIColor *color; ///线条颜色
@property(nonatomic, assign) CGPoint startPoint;  ///起始点
@property(nonatomic, assign) CGPoint endPoint;    ///结束点
@property(nonatomic, assign) CGFloat dottedLineLength; ///虚线时线段间隔的长度;实线时为0
@property(nonatomic, assign) CGFloat fullLineLength;   ///虚线时线段的长度;实线时为大于0任何值,最优值为线段长度


/*specail定义*/
@property(nonatomic, assign) BOOL        isSpecail; //是否时特殊线条
@property(nonatomic, assign) RRLinePoint startPointSpecial;  ///开始的顶点
@property(nonatomic, assign) RRLinePoint endPointSpecial;    ///结束的顶点
@property(nonatomic, assign) CGFloat     percentage; ///线条空白长度与开始顶点和结束顶点总长度的百分比
//percentage线条空白长度占视图宽带百分比; 正数空白在左边,负数空白在右边



- (void)configAboutDottedLineWithWidth:(CGFloat)width
                                 color:(UIColor *)color
                            startPoint:(CGPoint)startPoint
                              endPoint:(CGPoint)endPoint
                        dottleInterval:(CGFloat)dottleInterval
                          realInterval:(CGFloat)realInterval;

- (void)configAboutFullLineWithWidth:(CGFloat)width
                               color:(UIColor *)color
                          startPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint;

- (void)configAboutSpecailDottedLineWithWidth:(CGFloat)width
                                        color:(UIColor *)color
                                   startPoint:(RRLinePoint)startPoint
                                     endPoint:(RRLinePoint)endPoint
                               dottleInterval:(CGFloat)dottleInterval
                                 realInterval:(CGFloat)realInterval
                                   percentage:(CGFloat)percentage;

- (void)configAboutSpecailFullLineWithWidth:(CGFloat)width
                                      color:(UIColor *)color
                                 startPoint:(RRLinePoint)startPoint
                                   endPoint:(RRLinePoint)endPoint
                                 percentage:(CGFloat)percentage;;

- (CGPoint)coverSpecailPoint:(RRLinePoint)specialPoint toNormalInRect:(CGRect)rect;

@end