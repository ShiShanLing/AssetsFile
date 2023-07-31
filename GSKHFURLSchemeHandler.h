//
//  GSKHFURLSchemeHandler.h
//  iGSK
//
//  Created by 石山岭 on 2023/7/12.
//

#import <Foundation/Foundation.h>

#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSKHFURLSchemeHandler : NSObject<WKURLSchemeHandler>

@property(nonatomic, assign)BOOL isStopTask;

@property(nonatomic, strong)NSURLSessionDataTask *task;


@end

NS_ASSUME_NONNULL_END
