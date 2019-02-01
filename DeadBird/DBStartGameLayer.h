//
//  DBStartGameLayer.h
//  DeadBird
//
//  Created by Philipp Hackbarth on 03.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol StartGameDelegate;

@interface DBStartGameLayer : SKNode

@property (nonatomic, assign) id<StartGameDelegate> delegate;

-(id) initWithSize:(CGSize) size andScale:(CGFloat) scale;

@end


@protocol StartGameDelegate <NSObject>

-(void) startGameButtonTapped;

@end