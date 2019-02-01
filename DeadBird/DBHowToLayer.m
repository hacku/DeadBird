//
//  DBHowToLayer.m
//  DeadBird
//
//  Created by Philipp Hackbarth on 05.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import "DBHowToLayer.h"

@implementation DBHowToLayer

-(id) initWithSize:(CGSize) size andScale:(CGFloat) scale
{
    self = [super init];
    
    if(self)
    {
        SKSpriteNode *howToNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.0] size:size];
        
        
        //howToNode.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        howToNode.anchorPoint = CGPointZero;
        self.userInteractionEnabled = YES;
        
        SKTexture *helpTexture = [SKTexture textureWithImageNamed:@"help"];
        helpTexture.filteringMode = SKTextureFilteringNearest;
        
        SKTexture *birdTexture = [SKTexture textureWithImageNamed:@"Bird1"];
        birdTexture.filteringMode = SKTextureFilteringNearest;
        
        SKSpriteNode *help = [SKSpriteNode spriteNodeWithTexture:helpTexture];
        [help setScale:scale];
        help.position = CGPointMake(howToNode.size.width / 2, howToNode.size.height / 2);
        
        SKSpriteNode *bird2 = [SKSpriteNode spriteNodeWithTexture:birdTexture];
        [bird2 setScale:scale];
        bird2.position = CGPointMake(howToNode.size.width / 2, howToNode.size.height / 2 + 75 * scale);
        bird2.zRotation = 3.14 / 5.5f;
        
        howToNode.zPosition = 3;
        help.zPosition = 2;
        bird2.zPosition = 2;
        
        [howToNode addChild:help];
        [howToNode addChild:bird2];
        
        [self addChild:howToNode];
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:@selector(howToTapped)])
    {
        CGPoint contact = [[touches anyObject] locationInNode:self];
        
        if([self containsPoint:contact])
            [self.delegate howToTapped];
    }
    
}

@end
