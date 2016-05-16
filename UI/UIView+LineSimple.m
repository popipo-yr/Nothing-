//
//  UIView.m
//  test
//
//  Created by rrkd on 16/5/10.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "UIView+LineSimple.h"

@implementation UIView (LineSimple)


- (void)addSpecailFullLineAtUp:(CGFloat)percent
{
    [self addSpecailFullLineAtUp:percent clearOld:false];
}


- (void)addSpecailFullLineAtUp:(CGFloat)percent clearOld:(BOOL)clear
{
    PYLineInfo *aLineInfo = [[PYLineInfo alloc] init];
    [aLineInfo configAboutSpecailDottedLineWithWidth:_C_Full_Line_Width
                                               color:_C_Full_Line_Color
                                          startPoint:PYLinePointLeftUP
                                            endPoint:PYLinePointRightUp
                                      dottleInterval:0
                                        realInterval:100
                                     blankPercentage:percent];

    [self addLineInfo:aLineInfo clearOld:clear];
}


- (void)addSpecailFullLineAtDown:(CGFloat)percent
{
    [self addSpecailFullLineAtDown:percent clearOld:false];
}


- (void)addSpecailFullLineAtDown:(CGFloat)percent clearOld:(BOOL)clear
{
    PYLineInfo *aLineInfo = [[PYLineInfo alloc] init];
    [aLineInfo configAboutSpecailDottedLineWithWidth:_C_Full_Line_Width
                                               color:_C_Full_Line_Color
                                          startPoint:PYLinePointLeftDown
                                            endPoint:PYLinePointRightDown
                                      dottleInterval:0
                                        realInterval:100
                                     blankPercentage:percent];

    [self addLineInfo:aLineInfo clearOld:clear];
}


- (void)addSpecailDottedLineAtUp:(CGFloat)percent
{
    [self addSpecailDottedLineAtUp:percent clearOld:false];
}


- (void)addSpecailDottedLineAtUp:(CGFloat)percent clearOld:(BOOL)clear
{
    PYLineInfo *aLineInfo = [[PYLineInfo alloc] init];
    [aLineInfo configAboutSpecailDottedLineWithWidth:_C_Dotted_Line_Width
                                               color:_C_Dotted_Line_Color
                                          startPoint:PYLinePointLeftUP
                                            endPoint:PYLinePointRightUp
                                      dottleInterval:_C_Dotted_Line_DottedLength
                                        realInterval:_C_Dotted_Line_FullLength
                                     blankPercentage:percent];

    [self addLineInfo:aLineInfo clearOld:clear];
}


- (void)addSpecailDottedLineAtDown:(CGFloat)percent
{
    [self addSpecailDottedLineAtDown:percent clearOld:false];
}


- (void)addSpecailDottedLineAtDown:(CGFloat)percent clearOld:(BOOL)clear
{
    PYLineInfo *aLineInfo = [[PYLineInfo alloc] init];
    [aLineInfo configAboutSpecailDottedLineWithWidth:_C_Dotted_Line_Width
                                               color:_C_Dotted_Line_Color
                                          startPoint:PYLinePointLeftDown
                                            endPoint:PYLinePointRightDown
                                      dottleInterval:_C_Dotted_Line_DottedLength
                                        realInterval:_C_Dotted_Line_FullLength
                                     blankPercentage:percent];

    [self addLineInfo:aLineInfo clearOld:clear];
}


@end
