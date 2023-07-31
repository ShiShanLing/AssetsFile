//
//  GSKUIDocumentPickerViewController+custom.m
//  iGSK
//
//  Created by 石山岭 on 2023/7/19.
//

#import "GSKUIDocumentPickerViewController+custom.h"
#import "GSKFileStore.h"
#import <MobileCoreServices/UTType.h>
#import "GSKFileUploadModel.h"
#import "GSKWebFileUploadManage.h"
@implementation UIDocumentPickerViewController(custom)
static BOOL isDelegateMethodHooked = false;


static inline NSString * AFContentTypeForPathExtension(NSString *extension) {
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
#else
#pragma unused (extension)
    return @"application/octet-stream";
#endif
}

- (void)swizzled_documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls{
    for (NSURL * tempUrl in urls) {
        NSString *filename = [tempUrl.absoluteString lastPathComponent];
        BOOL jurisdiction = [tempUrl startAccessingSecurityScopedResource];
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;

        [fileCoordinator coordinateReadingItemAtURL:tempUrl options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSFileHandle * readFileHandle = [NSFileHandle fileHandleForReadingFromURL:newURL error:nil];
            GSKFileUploadModel * fileModel = [[GSKFileUploadModel alloc] initFilePath:newURL.absoluteString fileName:filename state:0];
            fileModel.fileURL = newURL;
            fileModel.readFileHandle = readFileHandle;
            [[GSKWebFileUploadManage sharedInstance].modelArray addObject:fileModel];
        }];
        if (error) {
            // error handing
            ZNLog(@"error handing===%@", error);
        }
        
        [tempUrl stopAccessingSecurityScopedResource];
    }
    
    [self swizzled_documentPicker:controller didPickDocumentsAtURLs:urls];
    
}

+ (void)hookDelegate {
    SEL swizzledSEL = @selector(swizzled_documentPicker:didPickDocumentsAtURLs:);
    SEL originSEL = @selector(documentPicker:didPickDocumentsAtURLs:);
    
    if (swizzledSEL && originSEL) {
        Class class = NSClassFromString(@"WKFileUploadPanel");
        hook_delegateMethod(class, originSEL, [UIDocumentPickerViewController class], swizzledSEL, swizzledSEL);
    }
}

+ (void)unHookDelegate {
    SEL swizzledSEL = @selector(swizzled_documentPicker:didPickDocumentsAtURLs:);
    SEL originSEL = @selector(documentPicker:didPickDocumentsAtURLs:);
    Class class = NSClassFromString(@"WKFileUploadPanel");
    unHook_delegateMethod(class,swizzledSEL,originSEL);
}

/**
 替换代理方法的实现
 */
static void hook_delegateMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL noneSel)  {
    //原实例方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    //替换的实例方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    
    if (!originalMethod) {// 如果没有实现 delegate 方法，则手动动态添加
        Method noneMethod = class_getInstanceMethod(replacedClass, noneSel);
        class_addMethod(originalClass, originalSel, method_getImplementation(noneMethod), method_getTypeEncoding(noneMethod));
        return;
    }
    
    // 向实现 delegate 的类中添加新的方法
    class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    
    // 重新拿到添加被添加的 method, 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
    Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
    if(!isDelegateMethodHooked && originalMethod && newMethod) {
        method_exchangeImplementations(originalMethod, newMethod);// 实现交换
        isDelegateMethodHooked = YES;
    }
}

/**
 恢复代理方法的实现
 */
static void unHook_delegateMethod(Class originalClass, SEL originalSel, SEL replacedSel){
    if(isDelegateMethodHooked) {
        Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
        Method replacedMethod = class_getInstanceMethod(originalClass, replacedSel);
        if (originalMethod && replacedMethod){
            // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
            Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
            method_exchangeImplementations(originalMethod, newMethod);// 实现交换
            isDelegateMethodHooked = NO;
        }
    }
}

/**
 替换的代理实现

 @param picker picker
 @param info info
 */
//- (void)swizzled_imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//
//    NSString *imageURLKey = @"UIImagePickerControllerImageURL";
//    NSString *imageKey = @"UIImagePickerControllerOriginalImage";
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:info];
//
//    //UIImagePickerControllerReferenceURL设为空是关键一步。
//    //相机是不会有asset URL,即referenceURL会为空，所以这里不需要传asset URL，直接传图片对象即可。
//    //让WKFileUploadPanel以为从相册来的图片也是从相机来的
//    [dict setValue:nil forKey:@"UIImagePickerControllerReferenceURL"];
//    UIImage *originImage = [dict valueForKey:imageKey];;
//
//    UIImage *targetImage = [UIImagePickerController compressImage:originImage];
//
//    NSString *imageFilePath = [UIImagePickerController imageFilePath];
//    [UIImagePickerController saveToSandBox:targetImage filePath:imageFilePath];
//    NSURL *targetImageURL = [NSURL fileURLWithPath:imageFilePath];
//    [dict setObject:targetImage forKey:imageKey];
//    [dict setObject:targetImageURL forKey:imageURLKey];
//
//    //方法的实现已经通过Method swizling交换了，所以这里调用的是原始实现
//    [self swizzled_imagePickerController:picker didFinishPickingMediaWithInfo:dict];
//}

+ (void)saveToSandBox:(UIImage *)image filePath:(NSString *)path {
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
}

+ (NSString *)imageFilePath {
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateString = [dateFormater stringFromDate:date];
    NSString *fileName = [dateString stringByAppendingString:@".png"];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

/**
 压缩图片
 
 @param image 原始图片
 @return 加工完成的图片
 */
+ (UIImage *)compressImage:(UIImage *)image {
    return image;
}
@end
