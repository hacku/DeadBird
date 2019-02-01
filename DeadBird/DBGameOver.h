//
//  DBGameOver.h
//  DeadBird
//
//  Created by Philipp Hackbarth on 04.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol GameOverDelegate;

@interface DBGameOver : SKNode

@property (nonatomic, assign) id<GameOverDelegate> delegate;

-(id) initWithSize:(CGSize) size andScale:(CGFloat) scale;

@end


@protocol GameOverDelegate <NSObject>

-(void) gameOverButtonTapped;

@end
