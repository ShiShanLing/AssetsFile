//
//  GSKHFURLSchemeHandler.m
//  iGSK
//
//  Created by 石山岭 on 2023/7/12.
//

#import "GSKHFURLSchemeHandler.h"
#import <objc/runtime.h>
#import "AFHTTPClient.h"
#import "GSKWebFileUploadManage.h"


//#import "AFNetworking.h"


//
//#import "AFNetworking/AFURLSessionManager.h"
//#import "AFNetworking/AFHTTPRequestOperationManager.h"
static char *const stopKey = "stopKey";

@interface NSURLRequest(requestId)
@property (nonatomic,assign) BOOL ss_stop;
@end

@implementation NSURLRequest(requestId)

- (void)setSs_stop:(BOOL)ss_stop
{
    objc_setAssociatedObject(self, stopKey, @(ss_stop), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)ss_stop
{
    return [objc_getAssociatedObject(self, stopKey) boolValue];
}

@end
@implementation GSKHFURLSchemeHandler
/*
 拦截到的链接formData和body都会丢失,需要自己注入 我是在 hookFileUploadFilename 这个方法注入的,具体代码就不放出来了
 */
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask{
    NSLog(@"urlSchemeTask===%@", urlSchemeTask.request.URL);
    NSURLRequest *request = urlSchemeTask.request;
    if (self.isStopTask == NULL){
        self.isStopTask = NO;
    }
    NSString *filename = [[GSKWebFileUploadManage sharedInstance] getFileNameRequest:(NSMutableURLRequest *)request];
    
//    ZNLog(@"是否拦截到文件名字filename====%@", filename);
    if ([urlSchemeTask.request.URL.absoluteString containsString:@"你要拦截的链接"]){
        NSDictionary* param = @{@"parent_dir":@"apptest"};
        //hookFileUploadFilename是一个网络请求而已
        [self hookFileUploadFilename:filename schemeTask:urlSchemeTask completeHander:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                ZNLog(@"请求出错 %@",connectionError);
                [urlSchemeTask didReceiveResponse:[NSURLResponse new]];
            }else{
                [urlSchemeTask didReceiveResponse:response];
                [urlSchemeTask didReceiveData:data];
            }
            [urlSchemeTask didFinish];
        }];

        return;
    }
    self.task = [[NSURLSession sharedSession]
           dataTaskWithRequest:urlSchemeTask.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           if (!data) {
               [urlSchemeTask didReceiveResponse:[NSURLResponse new]];
           } else {
               [urlSchemeTask didReceiveResponse:response];
               [urlSchemeTask didReceiveData:data];
           }
           [urlSchemeTask didFinish];
       }];
       [self.task resume];
}


 
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    //urlSchemeTask 不用做任何操作不然会崩溃
    //取消时记得停止网络请求.不然会崩溃.   这里记得吧 hookFileUploadFilename 里面的网络请求也停止掉,
    [self.task suspend];
    self.task = nil;
}



@end
