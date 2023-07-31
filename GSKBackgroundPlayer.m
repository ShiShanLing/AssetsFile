
#import "GSKBackgroundPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
//为了实现应用在后台无线存活,所以做一个播放器.
@interface GSKBackgroundPlayer()
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation GSKBackgroundPlayer

///创建单例--
+ (GSKBackgroundPlayer *)shareManager{
   static GSKBackgroundPlayer *manager = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       manager = [[GSKBackgroundPlayer alloc]init];
   });
   return manager;
}

/// 创建音乐播放器
- (void)creatAVAudioSessionObject{
   //设置后台模式和锁屏模式下依然能够播放
   [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
   [[AVAudioSession sharedInstance] setActive: YES error: nil];
   //初始化音频播放器
   NSError *playerError;
   NSURL *urlSound = [[NSURL alloc]initWithString:[[NSBundle mainBundle]pathForResource:@"laojie" ofType:@"mp3"]];
   _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlSound error:&playerError];
   _audioPlayer.numberOfLoops = -1;//无限播放
   _audioPlayer.volume = 0;
}

/// 开始播放声音
- (void)startPlayAudioSession{
   BOOL  isPlay = [_audioPlayer play];
    NSLog(@"isPlay===%id", isPlay);
}

/// 停止播放声音
- (void)stopPlayAudioSession{
   [_audioPlayer stop];
}

@end
