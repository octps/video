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

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoritelabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
- (IBAction)startPlaying:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
   

    // UIImagePickerControllerで選択された写真を取得する
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Assets Library frameworkによって提供されるURLを取得する
    // NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    // 取得したURLを使用して、PHAssetを取得する
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url,] options:nil];
    PHAsset *asset = fetchResult.firstObject;
    
    // ラベルのテキストを更新する
    self.dateLabel.text = asset.creationDate.description;
    self.favoritelabel.text = (asset.favorite ? @"registered Favorites" : @"not registered Favorites");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setupPlayer:(NSURL *) url
{
    // 1
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
//    NSURL *url = [NSURL fileURLWithPath:path];
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
}
@end
