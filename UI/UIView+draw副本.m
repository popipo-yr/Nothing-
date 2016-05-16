//
//  UIView.m
//
//
//  Created by yr on 15/9/4.
//  Copyright (c) 2015年 yr. All rights reserved.
//

#import "UIView+draw.h"
#import <objc/runtime.h>

@class DrawDelegate;

/////////////////////////////////
@interface UIView (Line_Param)

@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) DrawDelegate   *drawDelegate;
@property (nonatomic, strong) CALayer        *drawLayer;

@end


/////////////////////////////////
@interface  UIView (corner_param)

@property (nonatomic, assign) UIRectCorner cornersave;

- (void)setupMask;

@end


/////////////////////////////////
#pragma mark - #DrawDelegate

@interface DrawDelegate : NSObject{
    __weak UIView *_holdView;
}

- (instancetype)initWithHoldView:(UIView *)view;

@end

@implementation DrawDelegate

- (instancetype)initWithHoldView:(UIView *)view
{
    if (self = [super init]) {
        _holdView = view;
    }

    return self;
}


/**
 * 当点击UITextfield进入输入状态的时crash
 *
 * 原因:输入的时候有个改变字体的动画,视图调用layer的delegate的这个方法时,没有进行判断
 *     UIKit`-[CALayer(TextEffectsLayerOrdering) compareTextEffectsOrdering:]:
 *
 * 处理方式:第一种,添加方法compareTextEffectsOrdering:,
 *        第二种,发现这个视图是window的子类,禁止window子类添加drawlayer
 */
- (void)compareTextEffectsOrdering:(id)some
{
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (_holdView.drawLineDisable) return;

    for (RRLineInfo *aLineInfo in  _holdView.lines) {
        CGContextRef context = ctx;
        CGContextBeginPath(context);
        CGContextSetShouldAntialias(context, NO);
        if (aLineInfo.dottedLineLength > 0) {
            CGFloat lengths[] = {aLineInfo.dottedLineLength, aLineInfo.fullLineLength};
            CGContextSetLineDash(context, 0, lengths, 2);
        }

        CGPoint startPoint = aLineInfo.startPoint;
        CGPoint endPoint   = aLineInfo.endPoint;

        if (aLineInfo.isSpecail) {
            startPoint = [aLineInfo coverSpecailPoint:aLineInfo.startPointSpecial
                                       toNormalInRect:_holdView.bounds];

            endPoint = [aLineInfo coverSpecailPoint:aLineInfo.endPointSpecial
                                     toNormalInRect:_holdView.bounds];
        }

        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextSetLineWidth(context, aLineInfo.width);
        CGContextSetStrokeColorWithColor(context, aLineInfo.color.CGColor);
        CGContextStrokePath(context);
    }
}


/**
 * 调整drawlayer的大小为最新视图的大小
 */
- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    layer.frame = _holdView.bounds;
}


@end


/////////////////////////////////
#pragma mark - #UIView_Line_Draw


@implementation  UIView (Line_Draw)

+ (void)load
{
    Method oldInitCoder = class_getInstanceMethod([self class], @selector(initWithCoderCustom:));
    Method newInitCoder = class_getInstanceMethod([self class], @selector(initWithCoder:));
    method_exchangeImplementations(oldInitCoder, newInitCoder);

    Method oldInitFrame = class_getInstanceMethod([self class], @selector(initWithFrameCustom:));
    Method newInitFrame = class_getInstanceMethod([self class], @selector(initWithFrame:));
    method_exchangeImplementations(oldInitFrame, newInitFrame);

    Method oldSetBounds = class_getInstanceMethod([self class], @selector(setBounds:));
    Method newSetBounds = class_getInstanceMethod([self class], @selector(setBoundsCustom:));
    method_exchangeImplementations(oldSetBounds, newSetBounds);

    Method oldLayout = class_getInstanceMethod([self class], @selector(setNeedsLayout));
    Method newLayout = class_getInstanceMethod([self class], @selector(setNeedsLayoutCustom));
    method_exchangeImplementations(oldLayout, newLayout);
} /* load */


#pragma mark   Properties

/*dynamic param*/
- (NSMutableArray *)lines
{
    NSMutableArray *obj = objc_getAssociatedObject(self, @selector(lines));
    if (obj == nil) {
        obj = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, @selector(lines), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return obj;
}


- (BOOL)drawLineDisable
{
    BOOL ret = {0};
    [objc_getAssociatedObject(self, @selector(drawLineDisable)) getValue:&ret];
    return ret;
}


- (void)setDrawLineDisable:(BOOL)drawLineDisable
{
    NSValue *valueObj = [NSValue valueWithBytes:&drawLineDisable objCType:@encode(BOOL)];
    objc_setAssociatedObject(self, @selector(drawLineDisable), valueObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setDrawLayer:(CALayer *)drawLayer
{
    objc_setAssociatedObject(self, @selector(drawLayer), drawLayer,
                             OBJC_ASSOCIATION_RETAIN);
}


- (CALayer *)drawLayer
{
    return objc_getAssociatedObject(self, @selector(drawLayer));
}


- (void)setDrawDelegate:(DrawDelegate *)drawDelegate
{
    objc_setAssociatedObject(self, @selector(drawDelegate), drawDelegate,
                             OBJC_ASSOCIATION_RETAIN);
}


- (DrawDelegate *)drawDelegate
{
    return objc_getAssociatedObject(self, @selector(drawDelegate));
}


#pragma mark  Methods

- (void)_setupDrawLayer
{
    if (self.drawLayer != nil)
        return;

    /*windows的子类的calayer调用代理方法没有做判断,不附加layer*/
    if ([self isKindOfClass:[UIWindow class]])
        return;

    self.drawLayer                 = [CALayer layer];
    self.drawLayer.frame           = self.bounds;
    self.drawLayer.contentsScale   = [[UIScreen mainScreen] scale];
    self.drawLayer.backgroundColor = [UIColor clearColor].CGColor;

    [self.drawLayer setNeedsLayout];
    [self.drawLayer setNeedsDisplay]; // first need show,so whether need a switch here?
    [self.drawLayer setNeedsDisplayOnBoundsChange:true];

    [self.layer addSublayer:self.drawLayer];
} /* _setupDrawLayer */


#pragma mark  Exchange Methods
- (instancetype)initWithFrameCustom:(CGRect)frame
{
    if (self = [self initWithFrameCustom:frame]) {
        [self _setupDrawLayer];
    }

    return self;
}


- (id)initWithCoderCustom:(NSCoder *)aDecoder
{
    if (self = [self initWithCoderCustom:aDecoder]) {
        [self _setupDrawLayer];
    }

    return self;
}


/* view需要通过setNeedsLayout来重画drawlayer,
   如果view使用setNeedsDisplay,需要在drawrect处理,这样远离了出发点*/
- (void)setNeedsLayoutCustom
{
    [self setNeedsLayoutCustom];

    if (self.lines.count) {
        [self.drawLayer setNeedsDisplay];
    }
}


/*why not use setNeedsLayout layoutSubviews? let's simple*/
- (void)setBoundsCustom:(CGRect)bounds
{
    [self setBoundsCustom:bounds];

    if (self.lines.count) {
        [self.drawLayer setNeedsLayout];
    }

    if (self.cornersave != 0) {
        [self setupMask];
    }
}


#pragma mark  Methods

- (void)_addLineReally:(RRLineInfo *)lineInfo
{
    [self.lines addObject:lineInfo];
    /*有线条的时候才设置*/
    if (self.drawDelegate == nil) {
        self.drawDelegate       = [[DrawDelegate alloc] initWithHoldView:self];
        self.drawLayer.delegate = self.drawDelegate;
    }
}


- (void)addLineInfo:(RRLineInfo *)lineInfo
{
    [self addLineInfo:lineInfo clearOld:false];
}


- (void)addLineInfo:(RRLineInfo *)lineInfo clearOld:(BOOL)clear
{
    if (clear) [self clearLineInfo];

    [self _addLineReally:lineInfo];
}


- (void)clearLineInfo
{
    [self.lines removeAllObjects];
}


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
    [self.layer addSublayer:strokeLayer];
}


- (void)mask:(UIRectCorner)corners
{
    self.corners = corners;
}


@end


/////////////////////////////////
#pragma mark - #RRLineInfo

@implementation RRLineInfo

- (void)configAboutDottedLineWithWidth:(CGFloat)width color:(UIColor *)color startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint dottleInterval:(CGFloat)dottleInterval realInterval:(CGFloat)realInterval
{
    _isSpecail        = false;
    _width            = width;
    _color            = color;
    _startPoint       = startPoint;
    _endPoint         = endPoint;
    _dottedLineLength = dottleInterval;
    _fullLineLength   = realInterval;
}


- (void)configAboutFullLineWithWidth:(CGFloat)width color:(UIColor *)color startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [self configAboutDottedLineWithWidth:width color:color startPoint:startPoint endPoint:endPoint dottleInterval:0 realInterval:10];
}


- (void)configAboutSpecailDottedLineWithWidth:(CGFloat)width color:(UIColor *)color startPoint:(RRLinePoint)startPoint endPoint:(RRLinePoint)endPoint dottleInterval:(CGFloat)dottleInterval realInterval:(CGFloat)realInterval percentage:(CGFloat)percentage
{
    _isSpecail = true;

    _width             = width;
    _color             = color;
    _dottedLineLength  = dottleInterval;
    _fullLineLength    = realInterval;
    _startPointSpecial = startPoint;
    _endPointSpecial   = endPoint;
    _percentage        = percentage;
}


- (void)configAboutSpecailFullLineWithWidth:(CGFloat)width color:(UIColor *)color startPoint:(RRLinePoint)startPoint endPoint:(RRLinePoint)endPoint percentage:(CGFloat)percentage
{
    [self configAboutSpecailDottedLineWithWidth:width color:color startPoint:startPoint endPoint:endPoint dottleInterval:0 realInterval:10 percentage:percentage];
}


- (CGPoint)coverSpecailPoint:(RRLinePoint)specialPoint toNormalInRect:(CGRect)rect
{
    CGFloat percentage = _percentage;

    CGFloat percentageCo = percentage >= 0 ? percentage : (1 + percentage);
    CGFloat dy           = rect.size.height -  _width*0.5f;
    CGFloat dx           = rect.size.width * percentageCo;

    CGFloat uy = _width*0.5f;

    if (specialPoint == RRLinePointLeftUP) {
        return percentage >= 0 ? CGPointMake(dx, uy) : CGPointMake(0, uy);
    }

    if (specialPoint == RRLinePointLeftDown) {
        return percentage >= 0 ? CGPointMake(dx, dy) : CGPointMake(0, dy);
    }

    if (specialPoint == RRLinePointRightUp) {
        return percentage >= 0 ? CGPointMake(rect.size.width, uy) : CGPointMake(dx, uy);
    }

    if (specialPoint == RRLinePointRightDown) {
        return percentage >= 0 ? CGPointMake(rect.size.width, dy) : CGPointMake(dx, dy);
    }

    return CGPointZero;
}


@end