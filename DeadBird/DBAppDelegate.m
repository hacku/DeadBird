//
//  DBAppDelegate.m
//  DeadBird
//
//  Created by Philipp Hackbarth on 03.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import "DBAppDelegate.h"
#import "DBViewController.h"

@interface DBAppDelegate () {
  DBViewController *gameviewController;
}

@end

@implementation DBAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  gameviewController = (DBViewController *)self.window.rootViewController;

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // prevent audio crash
  [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [gameviewController pauseGame];

  // prevent audio crash
  [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

  // resume audio
  [[AVAudioSession sharedInstance] setActive:YES error:nil];

  [gameviewController resumeGame];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

@end
