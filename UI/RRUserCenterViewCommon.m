//
//  RRUserCenterViewCommon.m
//  rrkd
//
//  Created by rrkd on 15/9/10.
//  Copyright (c) 2015年 创物科技. All rights reserved.
//

#import "RRUserCenterViewCommon.h"

#pragma mark - RROnlyTextTipView
@implementation RROnlyTextTipView {
    UILabel *_tipLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _tipLabel = [[UILabel alloc] init];

        [self setupViews];
    }

    return self;
}


- (void)setupViews
{
    [self addSubview:_tipLabel];

    _tipLabel.font      = [UIFont systemFontOfSize:12];
    _tipLabel.textColor = [UIColor grayColor];

    _tipLabel.numberOfLines = 0;

    [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
         make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
     }];
}


- (void)setText:(NSString *)text
{
    _tipLabel.text = text;
}


- (void)setContentInset:(UIEdgeInsets)insets
{
    [_tipLabel remakeConstraints:^(MASConstraintMaker *make) {
         make.edges.equalTo(self).insets(insets);
     }];
}


@end


#pragma mark - UILabelWithWorning
@implementation UILabelWithWorning

- (void)setText:(NSString *)text
{
    if (text.length == 0) return;

    NSString *lastChar = [text substringFromIndex:text.length-1];
    if ([lastChar isEqualToString:@"*"] || [lastChar isEqualToString:@"＊"]) {
        //最后一个是'*',变红
        NSMutableAttributedString *attrNameStr = [[NSMutableAttributedString alloc] initWithString:text];

        UIFont *bigFont = [UIFont fontWithName:@"Helvetica" size:25];
        if (bigFont == nil) bigFont = [UIFont systemFontOfSize:35];

        [attrNameStr addAttributes:@{NSFontAttributeName:bigFont
                                     , NSForegroundColorAttributeName:[UIColor redColor]}
                             range:NSMakeRange(text.length-1, 1)];

        self.attributedText = attrNameStr;
    } else {
        [super setText:text];
    }
}


@end

#pragma  mark - 文字单元
@implementation RRFormatTextFieldView {
    UILabelWithWorning *_nameLabel;
    UITextField        *_contentTextField;
    UIButton           *_rightBtn;
    CGFloat            _labelWidth;
    CGFloat            _nameLeftSpace;
    CGFloat            _contentRightSpc;
    CGFloat            _btnWidth;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _nameLabel        = [UILabelWithWorning new];
        _contentTextField = [UITextField new];
        _rightBtn         = [UIButton new];
        _labelWidth       = 92;
        _nameLeftSpace    = 10;
        _contentRightSpc  = -2;
        _btnWidth         = 50;

        [self addSubview:_nameLabel];
        [self addSubview:_contentTextField];
        [self addSubview:_rightBtn];

        _nameLabel.font        = [UIFont systemFontOfSize:15];
        _contentTextField.font = [UIFont systemFontOfSize:14];

        self.backgroundColor = [UIColor whiteColor];

        _contentTextField.returnKeyType = UIReturnKeyNext;
        self.backgroundColor            = [UIColor colorWithHexString:@"FFFFFF"];

        _M_UIViewSpecailLineReal(self, 0.1);
    }

    return self;
}


- (instancetype)initWithName:(NSString *)name contentPlaceholder:(NSString *)placeholder rightImageName:(NSString *)imgName
{
    if (self = [super init]) {
        [self setName:name contentPlaceholder:placeholder rightImageName:imgName];
        [self setupConstraints];
    }

    return self;
}


- (void)setupConstraints
{
    [_rightBtn remakeConstraints:^(MASConstraintMaker *make) {
         make.top.bottom.equalTo(self);
         make.right.equalTo(self).offset(0);
         make.width.equalTo(_btnWidth);
     }];

    [_nameLabel remakeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self);
         make.left.equalTo(self.left).offset(_nameLeftSpace);
         make.width.equalTo(_labelWidth);
     }];

    MASViewAttribute *tfRight = _rightBtn.hidden ? self.right : _rightBtn.left;
    [_contentTextField remakeConstraints:^(MASConstraintMaker *make) {
         make.top.bottom.equalTo(self);
         make.left.equalTo(_nameLabel.right).offset(2);
         make.right.equalTo(tfRight).offset(_contentRightSpc);
     }];
}


- (void)setName:(NSString *)name contentPlaceholder:(NSString *)placeholder rightImageName:(NSString *)imgName
{
    if (imgName != nil && ![imgName isEqualToString:@""]) {
        _rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rightBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, RR_HORIZONTAL_SPACE)];
        _rightBtn.enabled = true;
        _rightBtn.hidden  = false;
    } else {
        _rightBtn.hidden  = true;
        _rightBtn.enabled = false;
    }

    _contentTextField.placeholder = placeholder;
    _nameLabel.text               = name;
}


- (void)setTipLabelWidth:(CGFloat)width
{
    _labelWidth = width;

    [_nameLabel updateConstraints:^(MASConstraintMaker *make) {
         make.width.equalTo(width);
     }];
}


- (void)setTipLabelLeftSpace:(CGFloat)space
{
    _nameLeftSpace = space;
    
    [_nameLabel updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(space);
    }];
}


- (void)setContentTextFieldRightSpace:(CGFloat)space
{
    _contentRightSpc = space * -1;
    
    MASViewAttribute *tfRight = _rightBtn.hidden ? self.right : _rightBtn.left;
    [_contentTextField updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tfRight).offset(_contentRightSpc);
    }];
}

- (void)setImageShowWidth:(CGFloat)width
{
    _btnWidth = width;
   
    [_rightBtn updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_btnWidth);
    }];
}
@end
#pragma  mark - 文字单元只是显示
@implementation RRFormatLabelView {
    UILabelWithWorning *_nameLabel;
    UILabel            *_contentLabel;
    UIImageView        *_rightImageView;

    CGFloat _labelWidth;
    CGFloat _nameLeftSpace;
    CGFloat _contentLeftSpace;
    CGFloat _contentRightSpace;
    CGSize _imageViewSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _nameLabel        = [UILabelWithWorning new];
        _contentLabel     = [UILabel new];
        _labelWidth       = 92;
        _nameLeftSpace    = 10;
        _contentLeftSpace = 2;
        _contentRightSpace = -10;

        [self addSubview:_nameLabel];
        [self addSubview:_contentLabel];

        _nameLabel.font    = [UIFont systemFontOfSize:15];
        _contentLabel.font = [UIFont systemFontOfSize:14];

        self.backgroundColor = [UIColor whiteColor];

        _M_UIViewSpecailLineReal(self, 0.1);
    }

    return self;
}


- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name rightImageName:nil];
}


- (instancetype)initWithName:(NSString *)name rightImageName:(NSString *)imgName
{
    if (self = [super init]) {
        if (imgName != nil) {
            _rightImageView             = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
            _rightImageView.contentMode = UIViewContentModeCenter;
            _imageViewSize              = _rightImageView.image.size;
            [self addSubview:_rightImageView];
        }

        [self setName:name];
        [self setupConstraints:0 contentLessHeight:0];
    }

    return self;
}


- (void)setupConstraints:(CGFloat)interval  contentLessHeight:(CGFloat)contentLessHeight;
{
    [_nameLabel remakeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self).offset(interval);

         if (_contentLabel.numberOfLines != 0) { /*单行,如果不指定底部,那么将置顶,
                                                  *多行,如果指定底部,将会居中*/
             make.bottom.equalTo(self).offset(-interval);
         }

         make.left.equalTo(self).offset(_nameLeftSpace);
         make.width.equalTo(_labelWidth);
     }];

    MASViewAttribute *contentRight = _rightImageView ? _rightImageView.left : self.right;
    [_contentLabel remakeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self).offset(interval);
         make.bottom.equalTo(self).offset(-interval);
         make.left.equalTo(_nameLabel.right).offset(_contentLeftSpace);
         make.right.equalTo(contentRight).offset(_contentRightSpace);
         make.height.greaterThanOrEqualTo(contentLessHeight);
     }];

    [_rightImageView remakeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self);
         make.right.equalTo(self).offset(-10);
         make.size.equalTo(_imageViewSize);
     }];
}


- (void)enableContentMultilineWithSingleHeight:(CGFloat)singleHeight
{
    [self updateConstraints:^(MASConstraintMaker *make) {
         make.height.greaterThanOrEqualTo(singleHeight);
     }];

    _contentLabel.numberOfLines = 0;

    CGSize  size     = [_nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat interval = (singleHeight - size.height) * 0.5F;

    [self setupConstraints:interval contentLessHeight:size.height];
}


- (void)setName:(NSString *)name
{
    _nameLabel.text = name;
}


- (void)setTipLabelWidth:(CGFloat)width
{
    _labelWidth = width;

    [_nameLabel updateConstraints:^(MASConstraintMaker *make) {
         make.width.equalTo(width);
     }];
}


- (void)setTipLabelLeftSpace:(CGFloat)space
{
    _nameLeftSpace = space;

    [_nameLabel updateConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self).offset(space);
     }];
}


- (void)setTipContentLeftSpace:(CGFloat)space
{
    _contentLeftSpace = space;

    [_contentLabel updateConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(_nameLabel.right).offset(space);
     }];
}

- (void)setTipContentTextFieldRightSpace:(CGFloat)space
{
    _contentRightSpace = space * -1;
    
    MASViewAttribute *tfRight = _rightImageView ? _rightImageView.left : self.right;
    [_contentLabel updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tfRight).offset(_contentRightSpace);
    }];
}


- (void)setImageShowWidth:(CGFloat)width
{
    _imageViewSize.width = width;
    
    [_rightImageView updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_imageViewSize);
    }];
}

@end


#pragma mark -  RRWorningTextTipView

@implementation RRWorningTextTipView {
    UIImageView *_noteImgView;
    UILabel     *_noteLabel;

    CGFloat _imageViewLeftOffset;
    CGFloat _labelLeftOffset;
    CGSize  _imageViewSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //设置默认值
        _imageViewLeftOffset = 11;
        _imageViewSize       = CGSizeMake(13, 13);
        _labelLeftOffset     = 4;

        [self setupViews];
        [self setupConstraints:0];
        self.backgroundColor = [UIColor colorWithHexString:@"FFF7EF"];
    }

    return self;
}


- (void)setupViews
{
    _noteImgView = [UIImageView new];
    _noteLabel   = [[UILabel alloc] init];

    _noteLabel.textColor = [UIColor colorWithHexString:@"FC2F34"];
    _noteLabel.font      = [UIFont systemFontOfSize:11];

    [self addSubview:_noteLabel];
    [self addSubview:_noteImgView];
}


- (void)setupConstraints:(float)interval
{
    [_noteImgView remakeConstraints:^(MASConstraintMaker *make) {
         make.size.equalTo(_imageViewSize);
         make.left.equalTo(self).offset(_imageViewLeftOffset);
         if (_noteLabel.numberOfLines == 0) {
             make.top.equalTo(self).offset(interval);
         } else {
             make.centerY.equalTo(self);
         }
     }];

    [_noteLabel remakeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self).offset(interval);
         make.bottom.equalTo(self).offset(-interval);
         make.left.equalTo(_noteImgView.right).offset(_labelLeftOffset);
         make.right.equalTo(self).offset(-_imageViewLeftOffset);
     }];
}


- (void)setImageViewLeftOffset:(CGFloat)leftOffset
{
    [_noteImgView updateConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self).offset(leftOffset);
     }];

    _imageViewLeftOffset = leftOffset;
}


- (void)setImageViewSize:(CGSize)size
{
    [_noteImgView updateConstraints:^(MASConstraintMaker *make) {
         make.size.equalTo(size);
     }];

    _imageViewSize = size;
}


- (void)setLabelLeftOffset:(CGFloat)leftOffset
{
    [_noteLabel updateConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(_noteImgView.right).offset(leftOffset);
     }];

    _labelLeftOffset = leftOffset;
}


- (void)enableContentMultilineWithSingleHeight:(CGFloat)singleHeight
{
    [self updateConstraints:^(MASConstraintMaker *make) {
         make.height.greaterThanOrEqualTo(singleHeight);
     }];

    _noteLabel.numberOfLines = 0;

    CGSize  size     = [@"高度" sizeWithAttributes:@{NSFontAttributeName : _noteLabel.font}];
    CGFloat interval = (singleHeight - size.height) * 0.5F;

    [self setupConstraints:interval];
}


@end