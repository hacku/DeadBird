//
//  DBStartGameLayer.m
//  DeadBird
//
//  Created by Philipp Hackbarth on 03.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import "DBStartGameLayer.h"

@interface DBStartGameLayer()
{
    SKSpriteNode *playButton;
    SKSpriteNode *musicButton;
}

@end

@implementation DBStartGameLayer

-(id) initWithSize:(CGSize) size andScale:(CGFloat) scale
{
    self = [super init];
    
    if(self)
    {
        SKSpriteNode *bgNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.0] size:size];
        bgNode.zPosition = 1;
        bgNode.anchorPoint = CGPointZero;
        
        [self addChild:bgNode];
        
        SKTexture *titleTexture = [SKTexture textureWithImageNamed:@"Logo"];
        titleTexture.filteringMode = SKTextureFilteringNearest;
        
        SKSpriteNode *title = [SKSpriteNode spriteNodeWithTexture:titleTexture];
        title.position = CGPointMake(bgNode.size.width / 2, bgNode.size.height / 1.2f);
        [title setScale:scale];
        
        [self addChild:title];
        
        SKTexture *buttonTexture = [SKTexture textureWithImageNamed:@"playbutton"];
        buttonTexture.filteringMode = SKTextureFilteringNearest;
        
        playButton = [SKSpriteNode spriteNodeWithTexture:buttonTexture];
        [playButton setScale:scale * 2];
        
        playButton.zPosition = 10;
        playButton.position = CGPointMake(bgNode.size.width / 2, bgNode.size.height / 2);
        
        SKTexture *musicTexture = [SKTexture textureWithImageNamed:@"music"];
        musicTexture.filteringMode = SKTextureFilteringNearest;
        
        musicButton = [SKSpriteNode spriteNodeWithTexture:musicTexture];
        [musicButton setScale:scale * 2];
        
        musicButton.zPosition = 15;
        musicButton.position = CGPointMake(24, bgNode.size.height - 32);
        
        
        [self addChild:playButton];
        [self addChild:musicButton];
        
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:@selector(startGameButtonTapped)])
    {
        CGPoint contact = [[touches anyObject] locationInNode:self];
        
        if([playButton containsPoint:contact])
            [self.delegate startGameButtonTapped];
        else if([musicButton containsPoint:contact])
            [[NSNotificationCenter defaultCenter] postNotificationName:@"switchMusicState" object:nil];

    }
    
}

@end
