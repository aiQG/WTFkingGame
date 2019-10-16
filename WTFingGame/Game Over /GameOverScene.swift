//
//  GameOverScene.swift
//  WTFingGame
//
//  Created by 周测 on 10/13/19.
//  Copyright © 2019 aiQG_. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {

	var score:Int = 0
	
	var scoreLable:SKLabelNode!
	var newGameButtonNode:SKSpriteNode!
	
	var menuButton:SKSpriteNode!
	
	override func didMove(to view: SKView) {
		scoreLable = (self.childNode(withName: "scoreLabel") as! SKLabelNode)
		scoreLable.text = "\(score)"
		
		newGameButtonNode = (self.childNode(withName: "newGameButton") as! SKSpriteNode)
		newGameButtonNode.texture = SKTexture(imageNamed: "button5")
		
		
		menuButton = (self.childNode(withName: "menuButton") as! SKSpriteNode)
		menuButton.texture = SKTexture(imageNamed: "button6")
		menuButton.scale(to: CGSize(width: 300, height: 100))
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		if let location = touch?.location(in: self) {
			let node = self.nodes(at: location)
			if node[0].name == "newGameButton" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let gameScene = GameScene(size: self.size)  //.swift
				self.view?.presentScene(gameScene, transition: transition)
			}else if node[0].name == "menuButton" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene //.sks
				menuScene.scaleMode = .aspectFill
				self.view?.presentScene(menuScene, transition: transition)

			}
		}
	}
}
