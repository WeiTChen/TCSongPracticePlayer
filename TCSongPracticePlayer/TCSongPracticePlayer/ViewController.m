//
//  ViewController.m
//  TCPracticePlayer
//
//  Created by william on 2017/12/20.
//  Copyright © 2017年 william. All rights reserved.
//

#import "ViewController.h"
#import "NSString+MD5.h"
#import <AVFoundation/AVFoundation.h>

//这是数值是系统默认的倍率
#define TIME_SCALE 1000000000

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UILabel *rateLb;

//播放器
@property (nonatomic,strong) AVPlayer *player;

//定时器
@property (nonatomic,strong) NSTimer *timer;

//开始时间
@property (nonatomic,assign) double startTime;

//结束时间
@property (nonatomic,assign) double endTime;

//开启
@property (nonatomic,assign) bool replay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rateSlider.maximumValue = 2;
    self.rateSlider.value = 1;
    
    //可以通过URL的方式来加载远程资源
    //[self loadFromWebURL];
    
    [self loadFromSandbox];
    
    CMTime duration = self.player.currentItem.asset.duration;
    float seconds = CMTimeGetSeconds(duration);
    self.timeSlider.maximumValue = seconds;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        CMTime t = self.player.currentTime;
        long long int v = t.value/TIME_SCALE;
        self.timeLb.text = [NSString stringWithFormat:@"%d:%02d", (int)v / 60, (int)v % 60, nil];
        self.timeSlider.value = v;
        if (self.replay) {
            if (v>self.endTime) {
                CMTime time;
                time.value =  (Float64)self.startTime*TIME_SCALE;
                time.timescale = TIME_SCALE;
                time.flags=1;
                time.epoch=0;
                [self.player seekToTime:time];
            }
            NSLog(@"%lld,%d,%d,%lld",v,t.timescale,t.flags,t.epoch);
        }
        
        if (self.player.timeControlStatus==0) {
            [self.player seekToTime:CMTimeMake(0, 1)];
        }
    }];
    [self.timer fire];
    
}

- (void)loadFromWebURL{
    NSString *url = @"http://m10.music.126.net/20171220135639/75927f3cf64b1d807a544ee446b6fa63/ymusic/5f28/46b3/b450/765744ce078a05425679683d326f1601.mp3";
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",[url MD5]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        [data writeToFile:filePath atomically:YES];
    }
    [self createAndPlayFromURL:[NSURL fileURLWithPath:filePath]];
}

- (void)loadFromSandbox{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"0465f4e8ce06d47300ac621f49eceee0" ofType:@"mp3"];
    [self createAndPlayFromURL:[NSURL fileURLWithPath:filePath]];
}

- (void)createAndPlayFromURL:(NSURL *)url{
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    self.player = player;
    [self.player play];
}

- (IBAction)ABSection:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"A段"]) {
        self.startTime = self.timeSlider.value;
        [sender setTitle:@"B段" forState:UIControlStateNormal];
        self.replay = NO;
    }
    else if ([sender.currentTitle isEqualToString:@"B段"]) {
        self.endTime = self.timeSlider.value;
        [sender setTitle:@"AB段" forState:UIControlStateNormal];
        self.replay = YES;
    }
    else if ([sender.currentTitle isEqualToString:@"AB段"]) {
        [sender setTitle:@"A段" forState:UIControlStateNormal];
        self.replay = NO;
    }
}

- (IBAction)play:(UIButton *)sender {
    if (self.player.timeControlStatus==AVPlayerTimeControlStatusPlaying) {
        [self.player pause];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        [self.player play];
        [sender setTitle:@"停止" forState:UIControlStateNormal];
    }
}

- (IBAction)playAtTime:(UISlider *)sender {
    CMTime time;
    time.value =  (Float64)sender.value*TIME_SCALE;
    time.timescale = TIME_SCALE;
    time.flags=1;
    time.epoch=0;
    [self.player seekToTime:time];
}

- (IBAction)changeRate:(UISlider *)sender {
    self.player.rate = sender.value;
    self.rateLb.text = [NSString stringWithFormat:@"播放速度为:%.2f",sender.value];
}


@end

