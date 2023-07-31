//
//  WKWebView+SchemeHandle.m
//  iGSK
//
//  Created by 石山岭 on 2023/7/12.
//

#import "WKWebView+SchemeHandle.h"
#import <objc/runtime.h>
 
@implementation WKWebView (SchemeHandle)
 
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod1 = class_getClassMethod(self, @selector(handlesURLScheme:));
        Method swizzledMethod1 = class_getClassMethod(self, @selector(yyhandlesURLScheme:));
        method_exchangeImplementations(originalMethod1, swizzledMethod1);
    });
}
//https://storex.igskapp.com/seafhttp/upload-aj/c727f375-3db4-4269-88e0-cc527b85679b
+ (BOOL)yyhandlesURLScheme:(NSString *)urlScheme {
    if ([urlScheme isEqualToString:@"http"] || [urlScheme isEqualToString:@"https"] || [urlScheme isEqualToString:@"file"]) {
        return NO;  //这里让返回NO,应该是默认不走系统断言或者其他判断啥的
    } else {
        return [self handlesURLScheme:urlScheme];
    }
}
@end

