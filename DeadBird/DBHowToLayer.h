//
//  DBHowToLayer.h
//  DeadBird
//
//  Created by Philipp Hackbarth on 05.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol HowToDelegate;

@interface DBHowToLayer : SKNode

@property (nonatomic, assign) id<HowToDelegate> delegate;

-(id) initWithSize:(CGSize) size andScale:(CGFloat) scale;

@end


@protocol HowToDelegate <NSObject>

-(void) howToTapped;

@end