//
//  PYMasonry.m
//  yr
//
//  Created by yr on 15/9/23.
//  Copyright © 2015年 yr. All rights reserved.
//

#import "PYMasonry.h"
#import <objc/message.h>


@implementation MasonryUtil

+(MasSimplyAppendTo)simplyAppendTo:(UIView*) toView widthView:(UIView *)widthView{
    
    __weak typeof(toView) weakToView = toView;
    __weak typeof(widthView) weakWidthView = widthView;
    MasSimplyAppendTo  simply =   ^(UIView *doView, CGFloat height, MASViewAttribute *topViewAttr, CGFloat topOffset){
        [weakToView addSubview:doView];
        NSArray* constraints = [doView makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakWidthView);
            make.height.equalTo(height);
            make.top.equalTo(topViewAttr).offset(topOffset);
        }];
        return constraints;
    };
    
    return simply;
    
}

+(void)removeConstraintsFromView:(UIView *)view aboutAttribute:(NSLayoutAttribute)attribute{
    
    NSArray* installedConstraints = [MASViewConstraint installedConstraintsForView:view];
    
    MASViewConstraint* findConstraint = nil;
    
    for (MASViewConstraint* attr in installedConstraints) {
        
        if (![attr isKindOfClass:[MASViewConstraint class]]) continue;
        if (attr.firstViewAttribute.layoutAttribute != attribute) continue;
        if (attr.firstViewAttribute.view != view) continue;
            
        findConstraint = attr;
        break;
    }
    if (findConstraint) {
        [findConstraint uninstall];
    }

}

+(void)removeAllConstraintsFromView:(UIView *)view{

    NSArray* installedConstraints = [MASViewConstraint installedConstraintsForView:view];
    
    for (MASViewConstraint* attr in installedConstraints) {
        
        [attr uninstall];
    }

}


+(void)removeOriginalConstraintsFromView:(UIView *)view aboutAttribute:(NSLayoutAttribute)attribute{
    
    NSArray* installedConstraints = view.constraints;
    
    NSLayoutConstraint* findConstraint = nil;
    
    for (NSLayoutConstraint* attr in installedConstraints) {
        
        if (![attr isKindOfClass:[NSLayoutConstraint class]]) continue;
        if (attr.firstAttribute != attribute) continue;
        if (attr.firstItem != view) continue;
        
        findConstraint = attr;
        break;
    }
    if (findConstraint) {
        [view removeConstraint:findConstraint];
    }
    
}


+(void)removeOriginalAllConstraintsFromView:(UIView *)view{
    
    [view removeConstraints:view.constraints];
}

@end


