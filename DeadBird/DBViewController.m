//
//  DBViewController.m
//  DeadBird
//
//  Created by Philipp Hackbarth on 03.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import "DBViewController.h"
#import "DBMyScene.h"

@import AVFoundation;

@interface DBViewController ()

@property(nonatomic) AVAudioPlayer *backgroundMusicPlayer;

@property(nonatomic) DBMyScene *scene;
@property(nonatomic) SKView *skView;
@property(nonatomic) BOOL bannerIsVisible;
@property(nonatomic) BOOL musicIsPlaying;

@end

@implementation DBViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _skView = (SKView *)self.view;

  // Create and configure the scene.
  self.scene = [DBMyScene sceneWithSize:_skView.bounds.size];
  self.scene.scaleMode = SKSceneScaleModeAspectFill;

  // skView.showsPhysics = YES;

  // Musik
  NSError *error;
  NSURL *backgroundMusicURL =
      [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"aiff"];
  self.backgroundMusicPlayer =
      [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL
                                             error:&error];
  self.backgroundMusicPlayer.numberOfLoops = -1;
  self.backgroundMusicPlayer.volume = .5f;
  [self.backgroundMusicPlayer prepareToPlay];
  [self.backgroundMusicPlayer play];
  self.musicIsPlaying = YES;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(switchMusicState)
                                               name:@"switchMusicState"
                                             object:nil];

  // Present the scene.
  [_skView presentScene:self.scene];
}

- (BOOL)shouldAutorotate {
  return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  if ([[UIDevice currentDevice] userInterfaceIdiom] ==
      UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (BOOL)allowActionToRun {
  return YES;
}

- (void)switchMusicState {
  if (self.musicIsPlaying) {
    [self.backgroundMusicPlayer stop];
    self.musicIsPlaying = NO;
  } else {
    [self.backgroundMusicPlayer play];
    self.musicIsPlaying = YES;
  }
}

- (void)pauseGame {
  [self switchMusicState];
  self.scene.paused = YES;
}

- (void)resumeGame {
  [self switchMusicState];
  self.scene.paused = NO;
}

@end
