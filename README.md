#  GameLearning

[youtube](https://www.youtube.com/watch?v=cJy61bOqQpg&list=PLY1P2_piiWEYjjumZztc_U4EYTpwx9mfe&index=8)
[youtube](https://www.youtube.com/watch?v=hirL1eDbum8&list=PLY1P2_piiWEYjjumZztc_U4EYTpwx9mfe&index=7)

一个物体有三个属性
```
collisionBitMask
categoryBitMask
contactTestBitMask
```

A与B接触时: 
1.计算: A.collisionBitMask & B.categoryBitMask
若不为0, 则A受影响; 若为0, 则A不受影响
2.计算: B.collisionBitMask & A.categoryBitMask
若不为0, 则B受影响; 若为0, 则B不受影响

A, B 覆盖时, 可能发生接触:
1.计算: A.contactTestBitMask & B.categoryBitMask
若不为0, 则发送接触通知(->A碰B); 若为0, 则不发送碰撞通知
1.计算: B.contactTestBitMask & A.categoryBitMask
若不为0, 则发送接触通知(->B碰A); 若为0, 则不发送碰撞通知
> ios9之后好像不需要指定这个参数了


---

iOS设备的屏幕坐标
原点在中间//锚点问题
UIScreen.main.bounds.width 获得的宽度的一半? 

---

最好是每个scene锚点相同 否则可能需要特殊操作

如果用代码初始化Scene: 
```swift
let gameScene = GameScene(size: self.size)
view?.presentScene(gameScene, transition: ...)
```
如果用.sks文件:
```swift
guard let gameScene = SKScene(fileNamed: "GameScene") else { return } 
view?.presentScene(gameScene, transition: ...)
```

presentScene后旧Scene的引用被删除

---

guard let v = str else {  } //失败则进入{}
if let v = str {}					//成功则进入{}

---

2019.10.13
TODO:
优化初始化
音频优化





