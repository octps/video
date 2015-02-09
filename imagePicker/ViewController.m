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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (IBAction)startPlaying:(id)sender {
    //    [self setupPlayer];
    // 現状は、アクションなし
}
@end
