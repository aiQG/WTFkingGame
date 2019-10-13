//
//  MenuScene.swift
//  WTFingGame
//
//  Created by 周测 on 10/13/19.
//  Copyright © 2019 aiQG_. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {

	var starField:SKEmitterNode!
	
	var newGameButtonNode:SKSpriteNode!
	var difficultyButtonNode:SKSpriteNode!
	var difficultyLabelNode:SKLabelNode!
	
	override func didMove(to view: SKView) {
		
		starField = self.childNode(withName: "starField") as! SKEmitterNode //参数: .sks中的Node
		starField.advanceSimulationTime(10)
		
		newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
		difficultyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
		//手动加纹理
		difficultyButtonNode.texture = SKTexture(imageNamed: "spark")
		
		
		difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
		
		
	}
	
	//创建触摸点
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let touch = touches.first //首先触碰点?
		if let location = touch?.location(in: self) {
			let nodesArray = self.nodes(at: location) //触碰点下的nodes(注意排序)
			
			if nodesArray.first?.name == "newGameButton" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5) //过场动画
				let gameScene = GameScene(size: self.size)
				self.view?.presentScene(gameScene, transition: transition)
			}
		}
		
	}
	

	
	
	
}
