//
//  GameScene.swift
//  WTFingGame
//
//  Created by 周测 on 10/9/19.
//  Copyright © 2019 aiQG_. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
   
	var starfield:SKEmitterNode!
	var player:SKSpriteNode!
   
	var scoreLable:SKLabelNode!
	var score:Int = 0 {
		didSet {
			scoreLable.text = "Score: \(score)"
		}
	}
    
	var gameTimer:Timer!
	
	var possibleAlien = ["alien","alien2","alien3"]
	
	let alienCategory:UInt32 = 0x1 << 1
	let photoTonrpedoCategory:UInt32 = 0x1 << 0
	
	
    override func didMove(to view: SKView) {
		
		starfield = SKEmitterNode(fileNamed: "Starfield")
		starfield.position = CGPoint(x: 0, y: 1472)
		starfield.advanceSimulationTime(10) //跳过前十秒
		self.addChild(starfield)
		
		starfield.zPosition = -1 //在所有东西下面
		
		player = SKSpriteNode(imageNamed: "shuttle")
		
		player.position = CGPoint(x: 0, y: 0 - self.frame.size.height / 2 + player.size.height / 2 + 20) //原点在中间
		
		self.addChild(player)
		
		self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) //无重力世界
		self.physicsWorld.contactDelegate = self
		
		//初始化scoreLable
		scoreLable = SKLabelNode(text: "Score: 0")
		scoreLable.position = CGPoint(x: 0, y: self.frame.size.height / 2 - 100)
		scoreLable.fontSize = 36
		scoreLable.fontName = "AmericanTypewriter-Bold" //加粗版
		scoreLable.fontColor = .white
		score = 0
		
		self.addChild(scoreLable)
		
		
		gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
		
		
		
		
		
    }
    
    
	@objc func addAlien() {
		possibleAlien = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAlien) as! [String] //相当于随机排列
		
		let alien = SKSpriteNode(imageNamed: possibleAlien[0]) //选取一个
		
		let randomAlienPosition = GKRandomDistribution(lowestValue: Int(-UIScreen.main.bounds.width) + Int(alien.size.width / 2), highestValue: Int(UIScreen.main.bounds.width) - Int(alien.size.width / 2)) //随机的x轴位置
		
		let position = CGFloat(randomAlienPosition.nextInt())
		
		alien.position = CGPoint(x: position, y: self.frame.size.height / 2 + alien.size.height / 2)
		//给予物理状态
		alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
		alien.physicsBody?.isDynamic = true
		// MARK: Have a look
		alien.physicsBody?.categoryBitMask = alienCategory //同则不碰?
		alien.physicsBody?.contactTestBitMask = photoTonrpedoCategory //出则碰?
		alien.physicsBody?.collisionBitMask = 0 //同则碰?
		
		self.addChild(alien)
		//动画
		let animationDuration:TimeInterval = 6 //秒
		var actionArray = [SKAction]() //动画函数队列
		actionArray.append(SKAction.move(to: CGPoint(x: position, y: 0 - self.frame.size.height / 2 - alien.size.height), duration: animationDuration))
		actionArray.append(SKAction.removeFromParent())
		alien.run(SKAction.sequence(actionArray))
		
		
	}
	
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		fireTorpedo()
	}
	
	
	func fireTorpedo() {
		self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
		
		let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
		torpedoNode.position = player.position
		torpedoNode.position.y += 5
		
		torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
		torpedoNode.physicsBody?.isDynamic = true
		
		//MARK: Have a look
		torpedoNode.physicsBody?.categoryBitMask = photoTonrpedoCategory //(类型)//同则不碰?
		torpedoNode.physicsBody?.contactTestBitMask = alienCategory //出则碰?(边界?范围?)
		torpedoNode.physicsBody?.collisionBitMask = 0 //同则碰?
		torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
		
		self.addChild(torpedoNode)
		//动画
		let animationDuration:TimeInterval = 0.3
		var actionArray = [SKAction]() //动画函数队列
		actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height / 2), duration: animationDuration))
		actionArray.append(SKAction.removeFromParent())
		torpedoNode.run(SKAction.sequence(actionArray))
		
	}
	
	//两个物体开始碰撞
	func didBegin(_ contact: SKPhysicsContact) {
		var firstBody:SKPhysicsBody
		var secondBody:SKPhysicsBody
		
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		}else{
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		if (firstBody.categoryBitMask & photoTonrpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
			
		}
		
	}
	
	
	
	
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
