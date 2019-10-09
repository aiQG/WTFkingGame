//
//  GameScene.swift
//  WTFingGame
//
//  Created by 周测 on 10/9/19.
//  Copyright © 2019 aiQG_. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion //硬件的运动信息


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
	let photonTonrpedoCategory:UInt32 = 0x1 << 0
	
	let motionManger = CMMotionManager()
	var xAcceleration:CGFloat = 0 //x轴的加速
	
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
		
		
		gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true) //生成alien
		
		
		motionManger.accelerometerUpdateInterval = 0.2 //加速度计更新间隔
		motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
			if let accelerometerData = data {
				let acceleration = accelerometerData.acceleration
				self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25 //这个加速度公式有点神奇
			}
		}
		
		
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
		alien.physicsBody?.categoryBitMask = alienCategory
		alien.physicsBody?.collisionBitMask = 0
		alien.physicsBody?.contactTestBitMask = photonTonrpedoCategory
		
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
		torpedoNode.physicsBody?.categoryBitMask = photonTonrpedoCategory
		torpedoNode.physicsBody?.collisionBitMask = 0
		torpedoNode.physicsBody?.contactTestBitMask = alienCategory
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
		
		//由于存在A碰B和B碰A的情况所以要如下判断, 选择需要remove哪个 (categoryBitMask大的是alien)
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		}else{
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		//判断firstBody是torpedo, secondBody是alien
		if (firstBody.categoryBitMask & photonTonrpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
			torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
		}
		
	}
	
	func torpedoDidCollideWithAlien(torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
		
		//添加粒子
		let explosion = SKEmitterNode(fileNamed: "Explosion")!
		explosion.position = alienNode.position
		self.addChild(explosion)
		//播放声音
		self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
		//移除Sprite
		torpedoNode.removeFromParent()
		alienNode.removeFromParent()
		self.run(SKAction.wait(forDuration: 2)){
			explosion.removeFromParent()
		}
		
		score += 5
	}
	
	//物理状态更新执行
	override func didSimulatePhysics() {
		player.position.x += xAcceleration * 50
		
		if player.position.x < -UIScreen.main.bounds.width {
			player.position = CGPoint(x: UIScreen.main.bounds.width, y: player.position.y)
		}else if player.position.x > UIScreen.main.bounds.width {
			player.position = CGPoint(x: -UIScreen.main.bounds.width, y: player.position.y)
		}
	}
	
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
