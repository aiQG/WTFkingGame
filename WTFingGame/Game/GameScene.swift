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
    
	var livesArray:[SKSpriteNode]!
	
	
	var gameTimer:Timer!
	

	let motionManger = CMMotionManager()
	var xAcceleration:CGFloat = 0 //x轴的加速
	
	var pauseButton:SKSpriteNode!
	
    override func didMove(to view: SKView) {
		
		pauseButton = SKSpriteNode(color: .init(red: 1, green: 0, blue: 0, alpha: 0.5), size: CGSize(width: 100, height: 100))
		pauseButton.name = "Pause"
		pauseButton.position = CGPoint(x: 750-75, y: 1334-150)
		pauseButton.zPosition = 1
		self.addChild(pauseButton)
		
		
		addLives()
		
		starfield = SKEmitterNode(fileNamed: "Starfield")
		starfield.position = CGPoint(x: 750/2, y: 1334+100)
		starfield.advanceSimulationTime(10) //跳过前十秒
		self.addChild(starfield)
		
		starfield.zPosition = -1 //在所有东西下面
		
		player = SKSpriteNode(imageNamed: "shuttle")
		
		player.position = CGPoint(x: 750/2, y: 0+30)
		
		self.addChild(player)
		
		self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) //无重力世界
		self.physicsWorld.contactDelegate = self
		
		//初始化scoreLable
		scoreLable = SKLabelNode(text: "Score: 0")
		scoreLable.position = CGPoint(x: 100, y: 1334-70)
		scoreLable.zPosition = 1 //over everything
		scoreLable.fontSize = 36
		scoreLable.fontName = "AmericanTypewriter-Bold" //加粗版
		scoreLable.fontColor = .white
		score = 0
		
		self.addChild(scoreLable)
		
		var timeInterval = 0.75
		if UserDefaults.standard.bool(forKey: "difficultyHard") {
			timeInterval = 0.3
		}
		gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true) //生成alien
		
		
		motionManger.accelerometerUpdateInterval = 0.2 //加速度计更新间隔
		motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
			if let accelerometerData = data {
				let acceleration = accelerometerData.acceleration
				self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25 //这个加速度公式有点神奇
			}
		}
		
		
    }
    
	var possibleAlien = ["alien","alien2","alien3"]
    
	let alienCategory:UInt32 = 0x1 << 1
	let photonTonrpedoCategory:UInt32 = 0x1 << 0
	
	@objc func addAlien() {
		possibleAlien = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAlien) as! [String] //相当于随机排列
		
		let alien = SKSpriteNode(imageNamed: possibleAlien[0]) //选取一个
		
		let randomAlienPosition = GKRandomDistribution(lowestValue: 10, highestValue: 750-10) //随机的x轴位置
		
		let position = CGFloat(randomAlienPosition.nextInt())
		
		alien.position = CGPoint(x: position, y: 1334+10)
		//给予物理状态
		alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
		alien.physicsBody?.isDynamic = true
		
		alien.physicsBody?.categoryBitMask = alienCategory
		alien.physicsBody?.collisionBitMask = 0
		alien.physicsBody?.contactTestBitMask = photonTonrpedoCategory
		
		self.addChild(alien)
		//动画
		let animationDuration:TimeInterval = 6 //秒
		var actionArray = [SKAction]() //动画函数队列
		actionArray.append(SKAction.move(to: CGPoint(x: position, y: -10), duration: animationDuration))
		
		actionArray.append(SKAction.run {
			self.run(SKAction.playSoundFileNamed("lostLive.mp3", waitForCompletion: false))
			
			if self.livesArray.count > 0 {
				let liveNode = self.livesArray.first
				liveNode?.removeFromParent() //从画面中删除
				self.livesArray.removeFirst() //从数组中删除
				
				if self.livesArray.count == 0 {
					let transition = SKTransition.flipHorizontal(withDuration: 0.5)
					let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
					gameOver.score = self.score
					gameOver.size = self.size
					gameOver.scaleMode = .aspectFill //不设置无法显示scene
					self.view?.presentScene(gameOver, transition: transition)
					
				}
			}
		})
		
		actionArray.append(SKAction.removeFromParent())
		alien.run(SKAction.sequence(actionArray))
		
		
	}
	
	
	var pauseScene:SKSpriteNode!
	var pauseLabel:SKLabelNode!
	var backButton:SKSpriteNode!
	var restartButton:SKSpriteNode!
	var menuButton:SKSpriteNode!
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		if let location = touch?.location(in: self) {
			let node = self.nodes(at: location)
			if node[0].name == "Pause" {
				//pause game
				gameTimer.invalidate()
				self.isPaused = true
				
				pauseScene = SKSpriteNode(color: .init(red: 0.2578, green: 0.2578, blue: 0.2578, alpha: 0.75), size: CGSize(width: 760, height: 1344))
				pauseScene.position = CGPoint(x: 750/2-5, y: 1334/2-5)
				pauseScene.zPosition = 2 //over everything
				self.addChild(pauseScene)
				
				pauseLabel = SKLabelNode(text: "Pause")
				pauseLabel.fontSize = 100
				pauseLabel.fontName = "Cochin"
				pauseLabel.name = "pauseLabel"
				pauseLabel.position = CGPoint(x: 375, y: 1046)
				pauseLabel.zPosition = 2
				self.addChild(pauseLabel)
				
				backButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
				backButton.name = "Back"
				backButton.position = CGPoint(x: 750-75, y: 1334-150)
				backButton.zPosition = 2
				self.addChild(backButton)
				
				restartButton = SKSpriteNode(color: .red, size: CGSize(width: 480, height: 100))
				restartButton.name = "Restart"
				restartButton.position = CGPoint(x: 375, y: 769)
				restartButton.zPosition = 2
				self.addChild(restartButton)
				
				menuButton = SKSpriteNode(color: .red, size: CGSize(width: 480, height: 100))
				menuButton.name = "Menu"
				menuButton.position = CGPoint(x: 375, y: 590)
				menuButton.zPosition = 2
				self.addChild(menuButton)
			} else if node[0].name == "Back" {
				//remove Node
				menuButton.removeFromParent()
				restartButton.removeFromParent()
				backButton.removeFromParent()
				pauseLabel.removeFromParent()
				pauseScene.removeFromParent()
				
				//Back to game
				var timeInterval = 0.75
				if UserDefaults.standard.bool(forKey: "difficultyHard") {
					timeInterval = 0.3
				}
				gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true) //生成alien
				gameTimer.fire()
				self.isPaused = false
			} else if node[0].name == "Restart" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let gameScene = GameScene(size: self.size)  //.swift
				self.view?.presentScene(gameScene, transition: transition)
			} else if node[0].name == "Menu" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene //.sks
				menuScene.scaleMode = .aspectFill
				self.view?.presentScene(menuScene, transition: transition)
			}
		}
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
		

		torpedoNode.physicsBody?.categoryBitMask = photonTonrpedoCategory
		torpedoNode.physicsBody?.collisionBitMask = 0
		torpedoNode.physicsBody?.contactTestBitMask = alienCategory
		torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
		
		self.addChild(torpedoNode)
		//动画
		let animationDuration:TimeInterval = 0.3
		var actionArray = [SKAction]() //动画函数队列
		actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: 1334+10), duration: animationDuration))
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
		
		if player.position.x < -10 {
			player.position = CGPoint(x: 750+10, y: player.position.y)
		}else if player.position.x > 750+10 {
			player.position = CGPoint(x: -10, y: player.position.y)
		}
	}
	
	
	func addLives() {
		livesArray = [SKSpriteNode]()
		
		for live in 1...3 {
			let liveNode = SKSpriteNode(imageNamed: "shuttle")
			liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - live) * (liveNode.size.width + 3), y: self.frame.size.height - 60)
			liveNode.zPosition = 1 //over everything
			self.addChild(liveNode)
			livesArray.append(liveNode)
		}
	}
	
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
