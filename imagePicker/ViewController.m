//
//  ViewController.m
//  imagePicker
//
//  Created by s001 on 2015/02/04.
//  Copyright (c) 2015年 s001. All rights reserved.
//

#import "ViewController.h"
@import AVFoundation;

@import Photos;
@import CoreLocation;
@import MobileCoreServices; // add for mediaTypes

@interface ViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
- (IBAction)startPlaying:(id)sender;


@end

@implementation ViewController

// 変数宣言
UIImageView *ivMe;
UIImageView *ivTracer;

//画像trace用の変数宣言
NSTimer *timer = nil;


- (void)viewDidLoad {
    // 画像を表示 me
    UIImage *imageMe = [UIImage imageNamed:@"me.png"];
    ivMe = [[UIImageView alloc] initWithImage:imageMe];
    ivMe.backgroundColor = [UIColor whiteColor];
    [ivMe setFrame:CGRectMake(50.0, 50.0, imageMe.size.width, imageMe.size.height)];
    [self.view addSubview:ivMe];
    
    // 画像を表示 tracer
    UIImage *imageTracer = [UIImage imageNamed:@"tracer.png"];
    ivTracer = [[UIImageView alloc] initWithImage:imageTracer];
    ivTracer.backgroundColor = [UIColor whiteColor];
    [ivTracer setFrame:CGRectMake(50.0, 50.0, imageTracer.size.width, imageTracer.size.height)];
    [self.view addSubview:ivTracer];
    
    // tracer用のsetInterval タイマー
    [NSTimer
     scheduledTimerWithTimeInterval:0.01
     target:self
     selector:@selector(onTimer:)
     userInfo:nil
     repeats:YES];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// タッチした時の座標に画像meと画像tracerとを移動
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint p = [[touches anyObject] locationInView:self.view];
    ivMe.center = p;
    ivTracer.center = p;
}

// タッチしてmoveした時に画像meを移動するメソッド
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint p = [[touches anyObject] locationInView:self.view];
    ivMe.center = p;
}

// tracer用のメソッド
- (void)onTimer:(NSTimer *)timer {
    // meとtracerの距離を出す
    // 距離を適当な数値でわる
    // tracerに追加する
    // 直接代入だとエラー、構造体とクラスの問題らしい。参考は以下
    // http://info-utakura.blogspot.jp/2011/11/xcodeexpression-is-no-assignable.html
    
    CGRect ivTracerFrame = ivTracer.frame;
    ivTracerFrame.origin.x = ivTracerFrame.origin.x + ((ivMe.center.x - ivTracer.center.x)/20);
    [ivTracer setFrame:ivTracerFrame];
    
    //ここで、距離の問題がはっせい
    //-2〜2までとする挙動を追加すること
    [self setupRate:(double) ((ivMe.center.x - ivTracer.center.x)/20)];
}

//動画の再生速度を決めるメソッド
- (void)setupRate:(double) value
{
    self.player.rate = value;
}

- (IBAction)selectImageButtonDidTouch:(id)sender {
    // PhotoLibraryから写真を選択するためのUIImagePickerControllerを作成し、表示する
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.mediaTypes =  @[(NSString*)kUTTypeMovie]; // add for 動画選択
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL]; // add for 動画のURL
    [self setupPlayer:url];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setupPlayer:(NSURL *) url
{
    // 1
    self.player = [AVPlayer playerWithURL:url];
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    // 2
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.previewView.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.playerLayer];
    
    // 3
    [self.playerLayer addObserver:self
                       forKeyPath:@"readyForDisplay"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 1
    if ([keyPath isEqualToString:@"readyForDisplay"])
    {
        // 2
        [self.playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
        
        // 3
        [self.player play];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
}

- (void)onVideoEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self.player play];
}

- (IBAction)startPlaying:(id)sender {
    //    [self setupPlayer];
    // 現状は、アクションなし
}
@end
