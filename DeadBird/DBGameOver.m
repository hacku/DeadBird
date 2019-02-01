//
//  DBGameOver.m
//  DeadBird
//
//  Created by Philipp Hackbarth on 04.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import "DBGameOver.h"

@interface DBGameOver()
{
    SKSpriteNode *restartButton;
    SKSpriteNode *musicButton;
}
@end

@implementation DBGameOver

-(id) initWithSize:(CGSize) size andScale:(CGFloat) scale
{
    self = [super init];
    
    if(self)
    {
        SKSpriteNode *bgNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.0] size:size];
        bgNode.zPosition = 1;
        bgNode.anchorPoint = CGPointZero;
        
        [self addChild:bgNode];
        
        SKTexture *GCButtonTexture = [SKTexture textureWithImageNamed:@"gamecenterbutton"];
        GCButtonTexture.filteringMode = SKTextureFilteringNearest;
        
        SKTexture *buttonTexture = [SKTexture textureWithImageNamed:@"playbutton"];
        buttonTexture.filteringMode = SKTextureFilteringNearest;
        
        SKTexture *gameoverTexture = [SKTexture textureWithImageNamed:@"gameover"];
        gameoverTexture.filteringMode = SKTextureFilteringNearest;
        
        restartButton = [SKSpriteNode spriteNodeWithTexture:buttonTexture];
        [restartButton setScale:1.5f];
        restartButton.zPosition = 10;
        restartButton.position = CGPointMake(bgNode.size.width / 2, bgNode.size.height / 2 - 40);
        
        SKSpriteNode *gameoverText = [SKSpriteNode spriteNodeWithTexture:gameoverTexture];
        gameoverText.zPosition = 8;
        gameoverText.position = CGPointMake(bgNode.size.width / 2, bgNode.size.height  - gameoverTexture.size.height * 1.2f);
        
        SKTexture *musicTexture = [SKTexture textureWithImageNamed:@"music"];
        musicTexture.filteringMode = SKTextureFilteringNearest;
        
        musicButton = [SKSpriteNode spriteNodeWithTexture:musicTexture];
        [musicButton setScale:scale * 2];
        
        musicButton.zPosition = 15;
        musicButton.position = CGPointMake(24, bgNode.size.height - 32);
        
        [self addChild:gameoverText];
        [self addChild:restartButton];
        [self addChild:musicButton];
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:@selector(gameOverButtonTapped)])
    {
        CGPoint contact = [[touches anyObject] locationInNode:self];
        
        if([restartButton containsPoint:contact])
            [self.delegate gameOverButtonTapped];
        else if([musicButton containsPoint:contact])
            [[NSNotificationCenter defaultCenter] postNotificationName:@"switchMusicState" object:nil];
    }
    
}

@end
