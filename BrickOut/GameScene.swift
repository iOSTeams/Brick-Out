//
//  GameScene.swift
//  BrickOut
//
//  Created by King Justin on 3/28/16.
//  Copyright (c) 2016 justinleesf. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var point : Int = Int()
    
    var fingerIsOnPaddle = false
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    let ballCategory:UInt32 = 0x1 << 0
    let paddleCategory:UInt32 = 0x1 << 1
    let brickCategory:UInt32 = 0x1 << 2
    let bottomCategory:UInt32 = 0x1 << 3
    
    var backgroundMusicPlayer = AVAudioPlayer()
    
    override init(size: CGSize) {
        super.init(size:size)
        
        self.physicsWorld.contactDelegate = self
        
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
        
        //Bottom
        let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        
        self.addChild(bottom)
        
        //Collision
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory
        
        
        
        //Create bricks
        let numberOfRows = 3
        let numberOfBricks = 6
        let brickWidth = SKSpriteNode(imageNamed: "brick").size.width
        let padding:Float = 20
        
        //offset = frame - (brick * 6 + padding * 6) / 2
        
        //let offset:Float = Float(self.frame.size.width) - Float(brickWidth * 6) + Float(padding * 6  / 2)
        let offset:Float = (Float(self.frame.size.width) - (Float(brickWidth) * Float(numberOfBricks) + padding * (Float(numberOfBricks) - 1 ) ) ) / 2
        
        //Create rows of bricks
        
        for index in 1 ... numberOfRows {
            
            var yOffset:CGFloat {
                switch index {
                case 1:
                    return self.frame.height * 0.8
                case 2:
                    return self.frame.height * 0.6
                case 3:
                    return self.frame.height * 0.4
                default:
                    return 0
                }
            }
            
            for index in 1 ... numberOfBricks {
                let brick = SKSpriteNode(imageNamed: "brick")
                
                let calc1:Float = Float(index) - 0.5
                let calc2:Float = Float(index) - 1
                
                brick.position = CGPointMake(CGFloat(calc1 * Float(brick.frame.size.width) + calc2 * padding + offset), yOffset)
                
                brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.frame.size)
                brick.physicsBody?.allowsRotation = false
                brick.physicsBody?.friction = 0
                brick.name = brickCategoryName
                //brick.physicsBody?.dynamic = false
                brick.physicsBody?.affectedByGravity = false
                brick.physicsBody?.categoryBitMask = brickCategory
                self.addChild(brick)
            }
            
        }
        
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
            var newXPos = paddle.position.x + (touchLocation.x - prevTouchLocation.x)
            
            newXPos = max(newXPos, paddle.size.width/2)
            newXPos = min(newXPos, self.size.width - paddle.size.width/2)
            
            paddle.position = CGPointMake(newXPos, paddle.position.y)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        fingerIsOnPaddle = false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        //Always make first body the smallest 
        //Smallest will always be the ball
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            print ("You lost")
            let lossScene = GameOverScene(size: self.size, playerWon: false)
            self.view?.presentScene(lossScene)
            
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory {
            secondBody.node?.removeFromParent()
            //Doesnt work if you turn dynamic off
            
            if isGameWon() {
                let winScene = GameOverScene(size: self.size, playerWon: true)
                self.view?.presentScene(winScene)
            }
        }
        
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        
        for nodeObject in self.children{
            let node = nodeObject as SKNode
            if node.name == brickCategoryName {
                numberOfBricks += 1
                point += 1
            }
        }
        return numberOfBricks <= 0
    }
    
    func getPoint() -> Int {
        return point
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
