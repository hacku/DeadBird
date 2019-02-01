//
//  DBMyScene.m
//  DeadBird
//
//  Created by Philipp Hackbarth on 03.05.14.
//  Copyright (c) 2014 Hackbarth GFX. All rights reserved.
//

#import "DBMyScene.h"
#import "DBStartGameLayer.h"
#import "DBGameOver.h"
#import "DBHowToLayer.h"

@interface DBMyScene () <SKPhysicsContactDelegate, StartGameDelegate, GameOverDelegate, HowToDelegate>
{
    SKSpriteNode *bird;
    
    SKTexture *pipeTexture1;
    SKTexture *pipeTexture2;
    SKAction *moveAndRemovePipes;
    SKAction *spawnPipesForever;

    SKAction *flap;
    
    SKAction *flapSound;
    SKAction *scoreSound;
    SKAction *dieSound;
    
    SKNode *moving;
    SKNode *pipes;
    
    DBHowToLayer *howToNode;
    
    SKNode *scoreNode;
    SKLabelNode *scoreInGame;
    SKLabelNode *highScore;
    
    BOOL canRestart;
    BOOL gameIsRunning;
    BOOL gameIsPaused;
    BOOL gameOver;
    
    SKLabelNode *scoreLabel;
    
    DBStartGameLayer *startGameView;
    DBGameOver *gameOverView;
    
    NSUserDefaults *appSettings;
    NSInteger highscore;
    NSInteger score;
}

@end


static NSUInteger const verticalPipeGap = 100;

static const uint32_t birdCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t pipeCategory = 1 << 2;
static const uint32_t scoreCategory = 1 << 3;
static const uint32_t skyCategory = 1 << 4;


@implementation DBMyScene


CGFloat clamp(CGFloat min, CGFloat max, CGFloat value)
{
    if(value < min)
        return min;
    else if (value > max)
        return max;
    else
        return value;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        canRestart = NO;
        gameOver = NO;
        gameIsRunning = NO;
        gameIsPaused = NO;
        
        //Welteinstellungen
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        [self initWorld];
        
        [self initBird];
        
        [self initPipes];
        
        // Sounds
        flapSound = [SKAction playSoundFileNamed:@"air.wav" waitForCompletion:NO];
        scoreSound = [SKAction playSoundFileNamed:@"score.wav" waitForCompletion:NO];
        dieSound = [SKAction playSoundFileNamed:@"died.wav" waitForCompletion:NO];
        
        //Views
        startGameView = [[DBStartGameLayer alloc] initWithSize:self.frame.size andScale:1.0f];
        startGameView.delegate = self;
        startGameView.userInteractionEnabled = YES;
        
        gameOverView = [[DBGameOver alloc] initWithSize:self.frame.size andScale:1.0f];
        gameOverView.delegate = self;
        gameOverView.userInteractionEnabled = YES;
        
        howToNode = [[DBHowToLayer alloc] initWithSize:self.frame.size andScale:1.0f];
        howToNode.delegate = self;
        
        [self addChild:startGameView];
        
        //Höchste Punktzahl laden
        appSettings = [NSUserDefaults standardUserDefaults];
        highscore = [appSettings integerForKey:@"highscore"];
    }
    
    return self;
}

#pragma mark Initialization Methods

-(void) initBird
{
    // Vogel
    SKTexture *birdTexture1 = [SKTexture textureWithImageNamed:@"Bird1"];
    SKTexture *birdTexture2 = [SKTexture textureWithImageNamed:@"Bird2"];
    SKTexture *deadBirdTexture = [SKTexture textureWithImageNamed:@"Bird_dead"];

    birdTexture1.filteringMode = SKTextureFilteringNearest;
    birdTexture2.filteringMode = SKTextureFilteringNearest;
    deadBirdTexture.filteringMode = SKTextureFilteringNearest;
    
    flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[birdTexture1,birdTexture2] timePerFrame:.2f]];
    
    bird = [SKSpriteNode spriteNodeWithTexture:deadBirdTexture];
    
    bird.position = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 1.5f);
    [bird runAction:flap withKey:@"flapAction"];
    
    bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.width / 2.2f];
    bird.physicsBody.dynamic = YES;
    bird.physicsBody.allowsRotation = NO;
    
    //Kollisionen
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory | skyCategory;
    bird.physicsBody.collisionBitMask = worldCategory | pipeCategory | skyCategory;
    
    [self addChild:bird];
}

-(void) initWorld
{
    // Hintergrundfarbe
    [self setBackgroundColor:[SKColor colorWithRed:202.0f / 255.0f green:234.0f / 255.0f blue:92.0f / 255.0f alpha:1.0f]];
    
    moving = [SKNode node];
    [self addChild:moving];
    
    pipes = [SKNode node];
    [moving addChild:pipes];
    
    // Boden
    SKTexture *groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction *moveGroundAction = [SKAction moveByX:-groundTexture.size.width * 2 y:0 duration:.02f * groundTexture.size.width];
    SKAction *resetGroundAction = [SKAction moveByX:groundTexture.size.width * 2 y:0 duration:.0f];
    SKAction *moveGroundForever = [SKAction repeatActionForever:[SKAction sequence:[NSArray arrayWithObjects:moveGroundAction,resetGroundAction, nil]]];
    
    for (unsigned i = 0; i < 4 + self.frame.size.width / groundTexture.size.width; i++)
    {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
        [sprite runAction:moveGroundForever];
        
        [moving addChild:sprite];
    }
    
    // Dummy-Boden für Physik
    SKNode *dummyGround = [SKNode node];
    dummyGround.position = CGPointMake(0, groundTexture.size.height * .5f);
    dummyGround.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(self.frame.size.width * 2, groundTexture.size.height)];
    dummyGround.physicsBody.dynamic = NO;
    dummyGround.physicsBody.categoryBitMask = worldCategory;
    [self addChild:dummyGround];
    
    //Dummy-Himmel für Physik
    SKNode *dummySky = [SKNode node];
    dummySky.position = CGPointMake(0, self.frame.size.height);
    dummySky.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(self.frame.size.width * 2, 5 )];
    dummySky.physicsBody.dynamic = NO;
    dummySky.physicsBody.categoryBitMask = skyCategory;
    [self addChild:dummySky];
    
    // Himmel
    SKTexture *skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;

    
    SKAction *moveSkyAction = [SKAction moveByX:-skylineTexture.size.width * 2 y:0 duration:.1f * skylineTexture.size.width*2];
    SKAction *resetSkyAction = [SKAction moveByX:skylineTexture.size.width * 2 y:0 duration:.0f];
    SKAction *moveSkyForever = [SKAction repeatActionForever:[SKAction sequence:[NSArray arrayWithObjects:moveSkyAction,resetSkyAction, nil]]];
    
    for (unsigned i = 0; i < 2 + self.frame.size.width / skylineTexture.size.width; i++)
    {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        [sprite setScale: 2];
        [sprite runAction:moveSkyForever];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height * 1.5f);
        
        [moving addChild:sprite];
    }
    
    
    //Punkteanzeige
    score = 0;
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Munro"];
    scoreLabel.fontSize = 64;
    scoreLabel.fontColor = [UIColor colorWithRed:15.0f/255.0f green:56.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
    scoreLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height * .75f);
    scoreLabel.zPosition = 10;
    scoreLabel.text = [NSString stringWithFormat:@"%ld",(long)score];
    
    scoreNode = [SKNode node];
    
    SKTexture *infoTexture = [SKTexture textureWithImageNamed:@"infopanel"];
    infoTexture.filteringMode = SKTextureFilteringNearest;
    
    SKSpriteNode *infoPanel = [SKSpriteNode spriteNodeWithTexture:infoTexture];
    infoPanel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + infoPanel.size.height / 2 + 10);
    infoPanel.zPosition = 9;
    
    scoreInGame = [SKLabelNode labelNodeWithFontNamed:@"Munro"];
    scoreInGame.fontSize = 18;
    scoreInGame.fontColor = [UIColor colorWithRed:15.0f/255.0f green:56.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
    scoreInGame.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height * .60f);
    scoreInGame.zPosition = 10;


    highScore = [SKLabelNode labelNodeWithFontNamed:@"Munro"];
    highScore.fontSize = 18;
    highScore.fontColor = [UIColor colorWithRed:15.0f/255.0f green:56.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
    highScore.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height * .55f);
    highScore.zPosition = 10;

    [scoreNode addChild:infoPanel];
    [scoreNode addChild:scoreInGame];
    [scoreNode addChild:highScore];

}

-(void) initPipes
{
    // Röhren
    pipeTexture1 = [SKTexture textureWithImageNamed:@"pipe1"];
    pipeTexture1.filteringMode = SKTextureFilteringNearest;
    
    pipeTexture2 = [SKTexture textureWithImageNamed:@"pipe2"];
    pipeTexture2.filteringMode = SKTextureFilteringNearest;
    
    CGFloat distanceToMove = pipeTexture1.size.width * 2 + self.frame.size.width;
    
    SKAction *movePipes = [SKAction repeatActionForever:[SKAction moveByX:-distanceToMove y:0 duration:0.01f * distanceToMove]];
    SKAction *removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes,removePipes]];
    
    // neue Röhren erzeugen
    SKAction *spanwPipes = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction *spawnDelay = [SKAction waitForDuration:2.0f];
    SKAction *spawnAndDelay = [SKAction sequence:@[spanwPipes,spawnDelay]];
    spawnPipesForever = [SKAction repeatActionForever:spawnAndDelay];
    
}

#pragma mark Game Logic

-(void) startGame
{
    [startGameView removeFromParent];
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, -10.0f);
    
    [gameOverView removeFromParent];
    [scoreNode removeFromParent];
    
    // Move bird to original position and reset velocity
    bird.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
    bird.physicsBody.velocity = CGVectorMake( 0, 0 );
    bird.physicsBody.collisionBitMask = worldCategory | pipeCategory | skyCategory;
    bird.speed = 1.0;
    bird.zRotation = 0.0;
    
    [bird runAction:flap withKey:@"flapAction"];
    
    // Remove all existing pipes
    [pipes removeAllChildren];
    
    // Reset _canRestart
    canRestart = NO;
    
    [self addChild:scoreLabel];
    
    // Restart animation
    moving.speed = 1;
    
    score = 0;
    scoreLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)score];
    
    [self runAction:spawnPipesForever withKey:@"spawnPipes"];
    
    gameIsRunning = YES;
    gameOver = NO;
    
    bird.physicsBody.velocity = CGVectorMake(0.0f, 250.0f);
    
    //iAd-Banner verstecken
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
}

-(void) pauseGame
{
    gameIsPaused = !gameIsPaused;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(gameIsRunning)
    {
        if(moving.speed > 0)
            bird.physicsBody.velocity = CGVectorMake(0.0f, 350.0f);

    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!gameOver)
        [self runAction:flapSound];
}

-(void)update:(CFTimeInterval)currentTime
{
    if(moving.speed > 0)
        bird.zRotation = clamp(-1, .5, bird.physicsBody.velocity.dy * ( bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
}

-(void) didBeginContact:(SKPhysicsContact *)contact
{
    if(moving.speed > 0)
    {
        if((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory)
        {
            score++;
            scoreLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)score];
            [self runAction:scoreSound];
        }
        else if((contact.bodyA.categoryBitMask & skyCategory) == skyCategory || (contact.bodyB.categoryBitMask & skyCategory) == skyCategory)
            return;
        else
            [self gameOver];
    }
    
}

-(void) spawnPipes
{
    SKNode *pipePair = [SKNode node];
    pipePair.position = CGPointMake(pipeTexture1.size.width + self.frame.size.width, 0);
    pipePair.zPosition = -10;
    
    CGFloat y = arc4random() % (NSUInteger) (self.frame.size.height / 3);
    
    SKSpriteNode *pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTexture1];
    pipe1.position = CGPointMake(0, y);
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    pipe1.physicsBody.categoryBitMask = pipeCategory;
    pipe1.physicsBody.contactTestBitMask = birdCategory;
    
    [pipePair addChild:pipe1];
    
    SKSpriteNode *pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTexture2];
    pipe2.position = CGPointMake(0, y + pipe1.size.height + verticalPipeGap);
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    pipe2.physicsBody.categoryBitMask = pipeCategory;
    pipe2.physicsBody.contactTestBitMask = birdCategory;
    
    [pipePair addChild:pipe2];
    [pipePair runAction:moveAndRemovePipes];
    
    SKNode *contactNode = [SKNode node];
    contactNode.position = CGPointMake(pipe1.size.width + bird.size.width / 2, self.frame.size.height / 2);
    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake( pipe2.size.width, self.frame.size.height )];
    contactNode.physicsBody.dynamic = NO;
    contactNode.physicsBody.categoryBitMask = scoreCategory;
    contactNode.physicsBody.contactTestBitMask = birdCategory;
    
    [pipePair addChild:contactNode];
    
    [pipes addChild:pipePair];
}

-(void) gameOver
{
    [bird removeActionForKey:@"flapAction"];
    [self runAction:dieSound];
    
    moving.speed = 0;
    gameOver = YES;
    
    [scoreLabel removeFromParent];
    
    [self removeActionForKey:@"spawnPipes"];
    
    //! Game Over anzeigen
    SKAction *gameOverDelay = [SKAction waitForDuration:.5f];
    SKAction *loadGameOverView = [SKAction performSelector:@selector(showGameOverView) onTarget:self];
    SKAction *displayGameOverView = [SKAction sequence:@[gameOverDelay,loadGameOverView]];
    
    [self runAction:displayGameOverView withKey:@"showGameOverView"];
    
    if(score > highscore)
    {
        highscore = score;
        [appSettings setInteger:highscore forKey:@"highscore"];
        [appSettings synchronize];
    }
    
    scoreInGame.text = [NSString stringWithFormat:@"Your score: %ld",(long)score];
    highScore.text = [NSString stringWithFormat:@"Your best: %ld",(long)highscore];
    [self addChild:scoreNode];
}

#pragma mark Delegates

-(void) startGameButtonTapped
{
    [startGameView removeFromParent];
    [bird removeFromParent];
    [self addChild:howToNode];
    
    //iAd-Banner verstecken
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
}

-(void) gameOverButtonTapped
{
    [self startGame];
}

-(void) gameCenterButtonTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeaderboard" object:nil];
}

-(void) howToTapped
{
    [howToNode removeFromParent];
    [self addChild:bird];
    [self startGame];
}

#pragma mark View Handling

-(void) showGameOverView
{
    [self removeActionForKey:@"showGameOverView"];
    [self addChild:gameOverView];
    
    //iAd-Banner zeigen
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
}

@end
