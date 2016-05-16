//
//  RRNetClientOpr.h
//
//  Created by rrkd on 15/12/24.
//  Copyright © 2015年 创物科技. All rights reserved.
//

#import "PYNetRequestProtocol.h"



@interface RRNetClientInOpr : NSObject


- (NSDictionary*)addParamer;
- (NSDictionary*)newParamerFromOldParamer:(NSDictionary*)oldParamer;


@end


@interface RRNetClientOutOpr : NSObject

- (id)newResponseObjectFromOld:(id)oldResponseObject
                       stopOpr:(BOOL*) stopOpr;

@end



@interface PYEncry : NSObject <PYNetStartRequestPro>

@end


@interface PYHttpDNS : NSObject <PYNetStartRequestPro>

@end