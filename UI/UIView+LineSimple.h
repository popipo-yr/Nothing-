//
//  UIView.h
//  test
//
//  Created by rrkd on 16/5/10.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "UIView+draw.h"


///实现配置信息
#define _C_Full_Line_Width  0.25f
#define _C_Full_Line_Color [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0]

///虚线配置信息
#define _C_Dotted_Line_Width 0.25f
#define _C_Dotted_Line_Color [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0]
#define _C_Dotted_Line_DottedLength  2.0f
#define _C_Dotted_Line_FullLength   2.0f


/////画线简单封装
@interface UIView (LineSimple)

///percent
///线条空白长度与两顶点长度的百分比
///正数空白在开始点,负数空白在结束点

//实线
-(void)addSpecailFullLineAtUp:(CGFloat)percent;
-(void)addSpecailFullLineAtDown:(CGFloat)percent;
-(void)addSpecailFullLineAtUp:(CGFloat)percent clearOld:(BOOL)clear;
-(void)addSpecailFullLineAtDown:(CGFloat)percent clearOld:(BOOL)clear;

//虚线
-(void)addSpecailDottedLineAtUp:(CGFloat)percent;
-(void)addSpecailDottedLineAtDown:(CGFloat)percent;
-(void)addSpecailDottedLineAtUp:(CGFloat)percent clearOld:(BOOL)clear;
-(void)addSpecailDottedLineAtDown:(CGFloat)percent clearOld:(BOOL)clear;

@end

