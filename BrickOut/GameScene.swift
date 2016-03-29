//
//  GameScene.swift
//  BrickOut
//
//  Created by King Justin on 3/28/16.
//  Copyright (c) 2016 justinleesf. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    
    var fingerIsOnPaddle = false
    
//    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        
//        self.addChild(myLabel)
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//       /* Called when a touch begins */
//        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
//    }
//   
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    var backgroundMusicPlayer = AVAudioPlayer()
    
    override init(size: CGSize) {
        super.init(size:size)
        
        //Set Background Music
        let bgMusicURL: NSURL = NSBundle.mainBundle().URLForResource("bgMusic", withExtension: "mp3")!
        backgroundMusicPlayer = try! AVAudioPlayer(contentsOfURL: bgMusicURL)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        
        //Set Background Image
        let backgroundImage = SKSpriteNode(imageNamed: "bg")
        backgroundImage.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.addChild(backgroundImage)
        
        //Set Border Physics
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        //Set Ball Physics
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = ballCategoryName
        ball.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        ball.color = SKColor.blackColor()
        self.addChild(ball)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.applyImpulse(CGVectorMake(2, -2))
        
        //Set paddle Physics
        let paddle = SKSpriteNode(imageNamed: "paddle")
        paddle.name = paddleCategoryName
        paddle.position = CGPointMake(self.frame.width/2, paddle.size.height * 2)
        //paddle.position = CGPointMake(self.frame.width/2, paddle.frame.size.height * 2)
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.dynamic = false
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body: SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        
        if body?.node?.name == paddleCategoryName {
            print("paddle touched")
            fingerIsOnPaddle = true
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if fingerIsOnPaddle {
            let touch = touches.first! as UITouch
            let touchLocation = touch.locationInNode(self)
            let prevTouchLocation = touch.previousLocationInNode(self)
            let paddle = self.childNodeWithName(paddleCategoryName) as! SKSpriteNode
            
            //Move paddle horizontally
            var newPosX = paddle.position.x + (touchLocation.x - prevTouchLocation.x)
            
            
            
            paddle.position = CGPointMake(newPosX, paddle.position.y)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
