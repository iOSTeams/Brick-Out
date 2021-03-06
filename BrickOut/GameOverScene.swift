//
//  GameOverScene.swift
//  BrickOut
//
//  Created by King Justin on 3/29/16.
//  Copyright © 2016 justinleesf. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {

    init (size:CGSize, playerWon: Bool) {
        super.init(size: size)
        
        
        let background = SKSpriteNode(imageNamed: "bg")
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        
        if playerWon {
            gameOverLabel.text = "You won"
        } else {
            gameOverLabel.text = "You lost"
            //gameOverLabel.text = "Total points: "
        }
        
        self.addChild(gameOverLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let breakOutGameScene = GameScene(size: self.size)
        self.view?.presentScene(breakOutGameScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
