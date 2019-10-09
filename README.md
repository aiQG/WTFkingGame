#  GameLearning

[youtube](https://www.youtube.com/watch?v=cJy61bOqQpg&list=PLY1P2_piiWEYjjumZztc_U4EYTpwx9mfe&index=8)

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
