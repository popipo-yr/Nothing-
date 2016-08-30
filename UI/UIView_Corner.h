//
//  UIView.h
//
//
//  Created by yr on 15/9/4.
//  Copyright (c) 2015年 yr. All rights reserved.
//

#import <UIKit/UIKit.h>

/***************************************/
/*视图呈现半角扩展*/
/***************************************/

/*note:谨慎使用,没有在实际项目中进行长时间运行测试*/
@interface UIView (corner)
//设置圆角位置
- (void)mask:(UIRectCorner)corners;
@end

