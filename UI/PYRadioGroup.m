//
//  PYRadioGroup.m
//  yr
//
//  Created by yr on 15/9/11.
//  Copyright (c) 2015年 yr. All rights reserved.
//

#import "PYRadioGroup.h"

#pragma mark - Item
#pragma mark -

/**
 *  PYRadioItem 代理
 */
@protocol PYRadioItemDelegate <NSObject>
/**
 *  单项改变状态时调用
 *
 *  @param item    改变的项
 *  @param isCheck 改变的状态
 */
- (void)PYRadioItem:(PYRadioItem *)item checkWillChangeTo:(BOOL)isCheck;
@end


/**
 *  单项选择项扩展
 */
@interface PYRadioItem (){
    @private
    BOOL     _isCheck;
    UIButton *_checkBtn;
}

@property (nonatomic, weak) id<PYRadioItemDelegate> delegate;

@end


//////
@implementation PYRadioItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }

    return self;
}


- (void)setupViews
{
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBtn addTarget:self action:@selector(chilkMe) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:checkBtn];
    
    _checkBtn   = checkBtn;
}


- (void)setContentView:(UIView *)content
            withConfig:(void (^)(UIView *content, UIButton *checkButton, UIView *mainView))configBlock
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    [self addSubview:_checkBtn];
    if (content) [self addSubview:content];

    if (configBlock) configBlock(content, _checkBtn, self);
}


- (void)chilkMe
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(PYRadioItem:checkWillChangeTo:)]) {
        [_delegate PYRadioItem:self checkWillChangeTo:!_isCheck];
    }
}


- (BOOL)isCheck
{
    return _isCheck;
}


- (void)setCheck:(BOOL)check
{
    _isCheck          = check;
    _checkBtn.selected = _isCheck;
}


@end


//////////////////////////////////////


#pragma mark - PYRadioGroup
#pragma mark -

@interface PYRadioGroup ()<PYRadioItemDelegate>{
    @private
    NSMutableArray *_items;
    NSUInteger     _checkedIndex;
    PYRadioItem    *_currentCheckedItem;
}

@end

//////
@implementation PYRadioGroup

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _items        = [NSMutableArray array];
        _checkedIndex = NSNotFound;
    }

    return self;
}


- (instancetype)initWithItems:(NSArray *)items
{
    if (self = [self init]) {
        [self setItems:items];
    }

    return self;
}


- (void)setItems:(NSArray *)items
{
    for (PYRadioItem *aItem in items) {
        if (![aItem isKindOfClass:[PYRadioItem class]])
            continue;

        aItem.delegate = self;

        [self addSubview:aItem];
        [_items addObject:aItem];
    }

    _checkedIndex = NSNotFound;
}


- (void)resetItems:(NSArray *)items
{
    [_items removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setItems:items];
}


- (NSUInteger)checkedIndex
{
    return _checkedIndex;
}


- (void)setCheckedIndex:(NSUInteger)checkedIndex
{
    if (checkedIndex >= _items.count ||
        checkedIndex == _checkedIndex) return;

    PYRadioItem *item = [_items objectAtIndex:checkedIndex];
    _currentCheckedItem.check = false;
    item.check                = true;

    _checkedIndex       = checkedIndex;
    _currentCheckedItem = item;

    if (_delegate && [_delegate respondsToSelector:@selector(PYRadioGroup:changeCheckedOnItem:atIndex:)]) {
        [_delegate PYRadioGroup:self changeCheckedOnItem:_currentCheckedItem atIndex:_checkedIndex];
    }
}


- (PYRadioItem *)radioItemAtIndex:(NSUInteger)index
{
    if (index >= _items.count) return nil;

    return [_items objectAtIndex:index];
}


- (void)cancelCheck
{
    _currentCheckedItem.check = false;
    _currentCheckedItem       = nil;
    _checkedIndex             = NSNotFound;
}


#pragma mark - PYRadioItemDelegate

- (void)PYRadioItem:(PYRadioItem *)item checkWillChangeTo:(BOOL)isCheck
{
    if (!isCheck || item == _currentCheckedItem) return;

    NSUInteger index = [_items indexOfObject:item];
    if (index == NSNotFound) return;

    [self setCheckedIndex:index];
}


@end