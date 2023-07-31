//
//  GSKBackgroundPlayer.h
//  iGSK
//
//  Created by 石山岭 on 2023/7/13.
//

#import <Foundation/Foundation.h>

//给App永久保活用

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSKBackgroundPlayer : NSObject

/// 创建单利
+ (GSKBackgroundPlayer *)shareManager;

/// 创建音乐播放器
- (void)creatAVAudioSessionObject;

/// 开始播放音乐
- (void)startPlayAudioSession;

/// 停止播放音乐
- (void)stopPlayAudioSession;

@end

NS_ASSUME_NONNULL_END
