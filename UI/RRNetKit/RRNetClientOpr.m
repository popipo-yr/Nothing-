//
//  RRNetClientOpr.m
//  rrkd
//
//  Created by rrkd on 15/12/24.
//  Copyright © 2015年 创物科技. All rights reserved.
//

#import "RRNetClientOpr.h"


@implementation  RRNetClientInOpr

- (NSDictionary*)addParamer{
    
    
    NSMutableDictionary *addParameters = [NSMutableDictionary dictionary];

   
//    [addParameters setValue: kApiVersion      forKey:@"version"];
//    [addParameters setValue: kPdaType         forKey:@"pdatype"];
//    [addParameters setValue: [RRUtils getUID] forKey:@"udid"];
   
    return addParameters;
    
}

- (NSDictionary*)newParamerFromOldParamer:(NSDictionary*)oldParamer{

     NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:oldParamer];
    //经纬度
//    NSString *lon = [NSString formatValue:oldParamer[@"lon"]];
//    NSString *lat = [NSString formatValue:oldParamer[@"lat"]];
//    if ([RRLocationFounction isUserLocationAvailable]) {
//
//        if ([lon length]==0||[lat length]==0) {
//            CLLocation *location = [[RRSession session] objectForKey:kCurrentLocation];
//            CLLocationCoordinate2D cor = [RRCoordCover convertGCJ02ToBD:location.coordinate];
//            if (location) {
//                [newParameters setValue: [NSString stringWithFormat:@"%f", cor.longitude] forKey:@"lon"];
//                [newParameters setValue: [NSString stringWithFormat:@"%f", cor.latitude] forKey:@"lat"];
//            }
//        }
//    }
//    else {
//
//#if SERVER_MENU == 1
//        [newParameters setValue:lon forKey:@"lon"];
//        [newParameters setValue:lat forKey:@"lat"];
//#else
//        [newParameters setValue:@"" forKey:@"lon"];
//        [newParameters setValue:@"" forKey:@"lat"];
//#endif
//    }
//    
//    
//    NSString *city = oldParamer[@"city"];
//    if (nil == city) {
//        city = [RRConfig currentCity];;
//        if (city.length>0) {
//            [newParameters setValue:city forKey:@"city"];
//        }
//    }

    
    return newParameters;
}


@end

@implementation RRNetClientOutOpr

- (id)newResponseObjectFromOld:(id)oldResponseObject stopOpr:(BOOL*) stopOpr{

    //保证单一设备登陆
    BOOL isLoginAtOtherDevice = [RRUtils detectLoginOtherDevice:oldResponseObject];
    
    *stopOpr = isLoginAtOtherDevice;
    
   
    return isLoginAtOtherDevice ? nil : oldResponseObject;
}

@end


@implementation PYEncry


- (void)_changeHearderKey:(NSString*)key object:(NSObject*)object forRequest:(NSMutableURLRequest*)request{
    
    NSMutableDictionary* header = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [header setObject:object forKey:key];
    [request setAllHTTPHeaderFields:header];
}

///加密参数

- (void)_encryptionRequest:(NSMutableURLRequest*)request paramters:(NSDictionary*)paramters{
    
    if (paramters == nil) return;
    
    //调用加密会更新时间戳,需要重新设置http头
    NSString *timeStamp = nil;
    NSData* encryptData = [self _encryptionParamters:paramters retTimeStamp:&timeStamp];
    [self _changeHearderKey:@"TIMESTAMP" object:timeStamp forRequest:request];
    
    [request setHTTPBody:encryptData];
}

//返回加密的字典数据 和dita
- (NSData*)_encryptionParamters:(NSDictionary*)paramters retTimeStamp:(NSString**)retTimeStamp{
    
    NSString *JSONString = _AFJSONStringFromParameters(paramters);
    NSString *key = [EncryptionBusiness encryptionWith:JSONString retTimeStamp:retTimeStamp];
    
    return  [key dataUsingEncoding:NSUTF8StringEncoding];
    
}


static NSString * _AFJSONStringFromParameters(NSDictionary *parameters) {
    NSError *error = nil;
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!error) {
        return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}


-(void)oprBeforeAllStartWithInfo:(PYNetStartRequestInfo *)info{
    
    [self _encryptionRequest:info.request paramters:info.param];
    
   
    info.header = @{};
    


}

@end


@implementation PYHttpDNS


- (void) afterURLRequestCreateOprWithStartInfo:(PYNetStartRequestWithRequestInfo *)info
{
    
    NSString* urlStr = info.request.URL.absoluteString;


    
    NSRange range = [urlStr rangeOfString:@"www.abc.com"];
//    NSString* curIP = [RRHttpDNSService curIP];
    NSString* curIP = @"192.27.88.9";
    
    if (curIP && range.length > 0) {
        
        
        urlStr = [urlStr stringByReplacingCharactersInRange:range withString:curIP];
        
        if (range.location == 0) {
            urlStr = [@"http://" stringByAppendingString:urlStr];
        }
        
        NSMutableDictionary* allHeader = [NSMutableDictionary dictionaryWithDictionary:info.request.allHTTPHeaderFields];
        [allHeader setObject:curIP forKey:@"Host"];
        [info.request setAllHTTPHeaderFields:allHeader];
    }
    
    
    [info.request setURL:[NSURL URLWithString:urlStr]]];
    
}


@end