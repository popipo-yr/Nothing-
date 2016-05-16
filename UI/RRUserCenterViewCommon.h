//
//  RRUserCenterViewCommon.h
//  rrkd
//
//  Created by rrkd on 15/9/10.
//  Copyright (c) 2015年 创物科技. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @author YangRui, 16-02-24 09:02:38
 *
 *  只有文字提示视图,包含一个label
 */
@interface RROnlyTextTipView : UIView
@property(nonatomic, readonly) UILabel *tipLabel; //内容label
- (void)setText:(NSString *)text; //设置显示内容
- (void)setContentInset:(UIEdgeInsets)insets; //设置label距离视图的间隔
@end



/**
 *  @author YangRui, 16-02-24 09:02:36
 *
 *  最后一个字符是‘*’,将进行红色提示处理
 */
@interface UILabelWithWorning : UILabel
@end



/**
 *  @author YangRui, 16-02-24 09:02:22
 *
 *  表单文本输入视图,从左到右包含一个内容项目标签,值输入框,一个按钮
 */
@interface RRFormatTextFieldView : UIView
@property(nonatomic, readonly) UITextField        *contentTextField; //值输入框
@property(nonatomic, readonly) UIButton           *rightBtn; //右侧按钮,可用仅作图片展示
@property(nonatomic, readonly) UILabelWithWorning *nameLabel; //左侧内容项目标签
/**
 *  创建一个输入表单文本视图,
 *
 *  @param name       左侧内容项目标签文字
 *  @param placehoder 值输入框placehoder
 *  @param imgName    右侧按钮normal状态下的图片
 */
- (instancetype)initWithName:(NSString *)name
          contentPlaceholder:(NSString *)placehoder
              rightImageName:(NSString *)imgName;
/**
 *  修改项目标签的宽度
 */
- (void)setTipLabelWidth:(CGFloat)width;
/**
 *  修改项目标签左侧距离视图的位置
 */
- (void)setTipLabelLeftSpace:(CGFloat)space;
/**
 *  修改内容文本右侧距离视图的位置
 */
- (void)setContentTextFieldRightSpace:(CGFloat)space;
/**
 *  设置图标显示的宽度
 */
- (void)setImageShowWidth:(CGFloat)width;
@end



/**
 *  @author YangRui, 16-02-24 09:02:01
 *
 *  表单文本展示视图,从左到右包含一个内容项目标签,值文本标签,一个右侧图片
 */
/*文字单元只是显示*/
@interface RRFormatLabelView : UIView
@property(nonatomic, readonly) UILabel            *contentLabel;  //值文本标签
@property(nonatomic, readonly) UILabelWithWorning *nameLabel;     //项目标签
@property(nonatomic, readonly) UIImageView        *rightImageView;
/**
 *  创建一个表单文本展示视图
 *
 *  @param name 项目标签
 */
- (instancetype)initWithName:(NSString *)name;
/**
 *  创建一个表单文本展示视图
 *
 *  @param name    项目标签
 *  @param imgName 右侧图片文件名
 */
- (instancetype)initWithName:(NSString *)name rightImageName:(NSString *)imgName;
/**
 *  修改项目标签的宽度
 */
- (void)setTipLabelWidth:(CGFloat)width;
/**
 *  修改项目标签左侧距离视图右侧的位置
 */
- (void)setTipLabelLeftSpace:(CGFloat)space;
/**
 *  修改值标签左侧距离项目标签右侧的位置
 */
- (void)setTipContentLeftSpace:(CGFloat)space;
/**
 *  修改值标签右侧距离视图右侧的位置
 */
- (void)setTipContentTextFieldRightSpace:(CGFloat)space;
/**
 *  设置图标显示的宽度
 */
- (void)setImageShowWidth:(CGFloat)width;
/**
 *  值标签开启多行显示
 *  @param singleHeight 单行时标签的高度
 */
- (void)enableContentMultilineWithSingleHeight:(CGFloat)singleHeight;
@end



/**
 *  @author YangRui, 16-02-24 10:02:45
 *
 *  警告提示文本,从左到右包含一个提示图片视图,提示内容文本框
 */
@interface RRWorningTextTipView : UIView
@property(nonatomic, readonly) UIImageView *noteImgView; //提示图片视图
@property(nonatomic, readonly) UILabel     *noteLabel;   //提示内容文本框
/**
 *  修改图片左侧距离视图左侧的位置
 */
- (void)setImageViewLeftOffset:(CGFloat)leftOffset;
/**
 *  修改图片展示尺寸
 */
- (void)setImageViewSize:(CGSize)size;
/**
 *  修改文本左侧距离图片右侧的位置
 */
- (void)setLabelLeftOffset:(CGFloat)leftOffset;
/**
 *  提示内容文本框开启多行显示
 *  @param singleHeight 单行时文本框的高度
 */
- (void)enableContentMultilineWithSingleHeight:(CGFloat)singleHeight;

@end