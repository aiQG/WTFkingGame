//
//  PauseScene.swift
//  WTFingGame
//
//  Created by 周测 on 10/16/19.
//  Copyright © 2019 aiQG_. All rights reserved.
//

import SpriteKit

class PauseScene: SKScene {
	
	var restartButton:SKSpriteNode!
	var menuButton:SKSpriteNode!
	var backButton:SKSpriteNode!
	
	override func didMove(to view: SKView) {
		
		restartButton = (self.childNode(withName: "Restart") as! SKSpriteNode)
		
		menuButton = (self.childNode(withName: "Menu") as! SKSpriteNode)
		
		backButton = (self.childNode(withName: "Back") as! SKSpriteNode)
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		if let location = touch?.location(in: self) {
			let node = self.nodes(at: location)
			if node[0].name == "Restart" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let gameScene = GameScene(size: self.size)  //.swift
				self.view?.presentScene(gameScene, transition: transition)
			}else if node[0].name == "Menu" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene //.sks
				menuScene.scaleMode = .aspectFill
				self.view?.presentScene(menuScene, transition: transition)
			}else if node[0].name == "Back" {
				//继续游戏
			}
		}
	}
	
	
	
}
