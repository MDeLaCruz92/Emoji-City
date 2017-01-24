//
//  GameScene.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright (c) 2016 Michael De La Cruz. All rights reserved.
//


import SpriteKit

class GameScene: SKScene {
  
  var swipeHandler: ((Swap) -> ())?
  
  var level: Level!
  
  var selectionSprite = SKSpriteNode()
  
  fileprivate var swipeFromColumn: Int?
  fileprivate var swipeFromRow: Int?
  
  let TileWidth: CGFloat = 32.0
  let TileHeight: CGFloat = 36.0
  
  let gameLayer = SKNode()
  let emojisLayer = SKNode()
  let tilesLayer = SKNode()
  let maskLayer = SKNode()
  let cropLayer = SKCropNode()
  
  
  let swapSound = SKAction.playSoundFileNamed("Brrr.wav", waitForCompletion: false)
  let invalidSwapSound = SKAction.playSoundFileNamed("Circuit.wav", waitForCompletion: false)
  let matchSound = SKAction.playSoundFileNamed("A Nine.wav", waitForCompletion: false)
  let fallingEmojiSound = SKAction.playSoundFileNamed("Laser Beam.wav", waitForCompletion: false)
  let addEmojiSound = SKAction.playSoundFileNamed("Bub.wav", waitForCompletion: false)
  //let playBtnSound = SKAction.playSoundFileNamed("Play.wav", waitForCompletion: false)
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }
  
  //MARK: init(size: size)
  override init(size: CGSize) {
    super.init(size: size)
    
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    let background = SKSpriteNode(imageNamed: "EmojiCityCV")
    background.size = size
    addChild(background)
    
    addChild(gameLayer)
    
    let layerPosition = CGPoint(
      x: -TileWidth * CGFloat(NumColumns) / 2,
      y: -TileHeight * CGFloat(NumRows) / 2)
    
    emojisLayer.position = layerPosition
    gameLayer.addChild(tilesLayer)
    
    tilesLayer.position = layerPosition
    gameLayer.addChild(emojisLayer)
    
    //gameLayer.addChild(cropLayer)
    
    //maskLayer.position = layerPosition
    //cropLayer.maskNode = maskLayer
    
    gameLayer.isHidden = true
    
    swipeFromColumn = nil
    swipeFromRow = nil
    
    let _ = SKLabelNode(fontNamed: "Bubblegum")
  }
  
  func addTiles() {
    for row in 0..<NumRows {
      for column in 0..<NumColumns {
        if level.tileAtColumn(column, row: row) != nil {
          let tileNode = SKSpriteNode(imageNamed: "Tile")
          tileNode.size = CGSize(width: TileWidth, height: TileHeight)
          tileNode.position = pointForColumn(column, row: row)
          tilesLayer.addChild(tileNode)
        }
      }
    }
    
    for row in 0...NumRows {
      for column in 0...NumColumns {
        let topLeft = (column > 0) && (row < NumRows)
          && level.emojiAtColumn(column - 1, row: row) != nil
        let bottomLeft = (column > 0) && (row > 0)
          && level.emojiAtColumn(column - 1, row: row - 1) != nil
        let topRight = (column < NumColumns) && (row < NumRows)
          && level.emojiAtColumn(column, row: row) != nil
        let bottomRight = (column < NumColumns) && (row > 0)
          && level.emojiAtColumn(column, row: row - 1) != nil
        
        // tiles are named from 0 to 15, according to the bitmask that is
        // made by combining these four values.
        let value =
          Int(topLeft.hashValue) |
            Int(topRight.hashValue) << 1 |
            Int(bottomLeft.hashValue) << 2 |
            Int(bottomRight.hashValue) << 3
        // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
        if value != 0 && value != 6 && value != 9 {
          let name = String(format: "Tile_%ld", value)
          let tileNode = SKSpriteNode(imageNamed: name)
          tileNode.size = CGSize(width: TileWidth, height: TileHeight)
          var point = pointForColumn(column, row: row)
          point.x -= TileWidth/2
          point.y -= TileHeight/2
          tileNode.position = point
          tilesLayer.addChild(tileNode)
        }
      }
    }
  }
  func addSpritesForEmojis(_ emojis: Set<Emoji>) {
    for emoji in emojis {
      let sprite = SKSpriteNode(imageNamed: emoji.emojiType.spriteName)
      sprite.size = CGSize(width: TileWidth, height: TileHeight)
      sprite.position = pointForColumn(emoji.column, row:emoji.row)
      emojisLayer.addChild(sprite)
      emoji.sprite = sprite
      
      // Gives the emojis sprites a faded in animation.
      sprite.alpha = 0
      sprite.xScale = 0.5
      sprite.yScale = 0.5
      
      sprite.run(
        SKAction.sequence([
          SKAction.wait(forDuration: 0.2, withRange: 0.5),
          SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
            ])
          ]))
    }
  }
  
  func pointForColumn(_ column: Int, row: Int) -> CGPoint {
    return CGPoint(
      x: CGFloat(column)*TileWidth + TileWidth/2,
      y: CGFloat(row)*TileHeight + TileHeight/2)
  }
  
  func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
    if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
      point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
      return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
    } else {
      return (false, 0, 0)  // invalid location
    }
  }
  // calls touchesBegan() whenever the user puts her finger on the screen.
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // s1 converts the touch location, if any, to a point relative to the emojisLayer.
    guard let touch = touches.first else { return }
    let location = touch.location(in: emojisLayer)
    // s2 it finds out if the touch is inside a sqaure on the level grid by calling a method you'll write in a moment.
    let (success, column, row) = convertPoint(location)
    if success {
      // s3 the method verifies that the touch is on a emoji rather than on an empty square.
      if let emoji = level.emojiAtColumn(column, row: row) {
        // s4 it records the column and row where the swipe started so you can compare them later to find the direction of the swipe.
        swipeFromColumn = column
        swipeFromRow = row
        showSelectionIndicatorForEmoji(emoji)
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    // s1 if swipeFromColumn is nil, then either the swipe began outside the valid area or the game has already swapped the emojis and you need to ignore the rest of the motion.
    guard swipeFromColumn != nil else { return }
    
    // s2 calculate the row and column numbers currently under the player's finger.
    guard let touch = touches.first else { return }
    let location = touch.location(in: emojisLayer)
    
    let (success, column, row) = convertPoint(location)
    if success {
      
      // s3 the method here figures out the direction of the player's swipe by simply comparing the new column and row numbers to the prev ones.
      var horzDelta = 0, vertDelta = 0
      if column < swipeFromColumn! {          // swipe left
        horzDelta = -1
      } else if column > swipeFromColumn! {   // swipe right
        horzDelta = 1
      } else if row < swipeFromRow! {         // swipe down
        vertDelta = -1
      } else if row > swipeFromRow! {         // swipe up
        vertDelta = 1
      }
      
      // s4 method only performs the swap if the player swiped out of the old square.
      if horzDelta != 0 || vertDelta != 0 {
        trySwapHorizontal(horzDelta, vertical: vertDelta)
        
        hideSelectionIndicator()
        // 5 By setting swipeFromColumn back to nil, the game will ignore the rest of this swipe motion.
        swipeFromColumn = nil
      }
    }
  }
  
  func trySwapHorizontal(_ horzDelta: Int, vertical vertDelta: Int) {
    // s1 calculate the column and row numbers of the emoji to swap with.
    let toColumn = swipeFromColumn! + horzDelta
    let toRow = swipeFromRow! + vertDelta
    // s2 using guard because it's possible that the toColumn and toRow is outside the 9x9 grid.
    guard toColumn >= 0 && toColumn < NumColumns else { return }
    guard toRow >= 0 && toRow < NumRows else { return }
    // s3 this checks to make sure that there is actually a emoji at the new position.
    if let toEmoji = level.emojiAtColumn(toColumn, row: toRow),
      let fromEmoji = level.emojiAtColumn(swipeFromColumn!, row: swipeFromRow!) {
      
      if let handler = swipeHandler {
        let swap = Swap(emojiA: fromEmoji, emojiB: toEmoji)
        handler(swap)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if selectionSprite.parent != nil && swipeFromColumn != nil {
      hideSelectionIndicator()
    }
    swipeFromColumn = nil
    swipeFromRow = nil
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    if let touches = touches {
      touchesEnded(touches, with: event)
    }
  }
  
  func animateSwap(_ swap: Swap, completion: @escaping () -> ()) {
    let spriteA = swap.emojiA.sprite!
    let spriteB = swap.emojiB.sprite!
    
    spriteA.zPosition = 100
    spriteB.zPosition = 90
    
    let Duration: TimeInterval = 0.3
    
    let moveA = SKAction.move(to: spriteB.position, duration: Duration)
    moveA.timingMode = .easeOut
    spriteA.run(moveA, completion: completion)
    
    let moveB = SKAction.move(to: spriteA.position, duration: Duration)
    moveB.timingMode = .easeOut
    spriteB.run(moveB)
    
    run(swapSound)
    
  }
  
  func showSelectionIndicatorForEmoji(_ emoji: Emoji) {
    if selectionSprite.parent != nil {
      selectionSprite.removeFromParent()
    }
    
    if let sprite = emoji.sprite {
      let texture = SKTexture(imageNamed: emoji.emojiType.highlightedSpriteName)
      selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
      selectionSprite.run(SKAction.setTexture(texture))
      
      sprite.addChild(selectionSprite)
      selectionSprite.alpha = 1.0
    }
  }
  
  func hideSelectionIndicator() {
    selectionSprite.run(SKAction.sequence([
      SKAction.fadeOut(withDuration: 0.3),
      SKAction.removeFromParent()]))
  }
  
  func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
    let spriteA = swap.emojiA.sprite!
    let spriteB = swap.emojiB.sprite!
    
    
    spriteA.zPosition = 100
    spriteB.zPosition = 90
    
    let Duration: TimeInterval = 0.2
    
    let moveA = SKAction.move(to: spriteB.position, duration: Duration)
    moveA.timingMode = .easeOut
    
    let moveB = SKAction.move(to: spriteA.position, duration: Duration)
    moveB.timingMode = .easeOut
    
    spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
    spriteB.run(SKAction.sequence([moveB, moveA]))
    
    run(invalidSwapSound)
    
  }
  // loops all chains and all emojis in each chain, triggering the animations
  func animateMatchedEmojis(_ chains: Set<Chain>, completion: @escaping () -> ()) {
    for chain in chains {
      animateScore(for: chain)
      for emoji in chain.emojis {
        if let sprite = emoji.sprite {
          if sprite.action(forKey: "removing") == nil {
            let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
            scaleAction.timingMode = .easeOut
            sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                       withKey: "removing")
          }
        }
      }
    }
    // ensures the game will only continue after the animations finish
    run(matchSound)
    run(SKAction.wait(forDuration: 0.3), completion: completion)
  }
  
  func animateFallingEmojis(_ columns: [[Emoji]], completion: @escaping () -> ()) {
    // s1 the number of falling emojis may vary, so have to compute it
    var longestDuration: TimeInterval = 0
    for array in columns {
      for (idx, emoji) in array.enumerated() {
        let newPosition = pointForColumn(emoji.column, row: emoji.row)
        // s2 this calculation works because fillHoles() guarantees that lower emojis are first in the array.
        let delay = 0.05 + 0.15*TimeInterval(idx)
        // s3 the duration of the animation is based on how far the emoji has to fall(0.1s per tile) but you can change it up
        let sprite = emoji.sprite!
        let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
        // s4 calculates which animation is the longest. This is where the game has to wait before it may continue
        longestDuration = max(longestDuration, duration + delay)
        // s5 performs the animation which consists of a delay, movement and a sound effect
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.run(
          SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([moveAction, fallingEmojiSound])]))
      }
    }
    // s6 wait until all the emojis have fallen down before allowing the gameplay to continue
    run(SKAction.wait(forDuration: longestDuration), completion: completion)
  }
  
  // emoji objects are now in reverse order in the array, top to bottom.
  func animateNewEmojis(_ columns: [[Emoji]], completion: @escaping () -> ()) {
    // The game is not allowed to continue until all the animations are complete.
    var longestDuration: TimeInterval = 0
    
    for array in columns {
      // The new emoji sprite should start out just above the first tile in the column.
      let startRow = array[0].row + 1
      
      for (idx, emoji) in array.enumerated() {
        // created a new sprite for the emoji
        let sprite = SKSpriteNode(imageNamed: emoji.emojiType.spriteName)
        sprite.size = CGSize(width: TileWidth, height: TileHeight)
        sprite.position = pointForColumn(emoji.column, row: startRow)
        emojisLayer.addChild(sprite)
        emoji.sprite = sprite
        
        let delay = 0.1 + 0.2 * TimeInterval(array.count - idx - 1)
        
        let duration = TimeInterval(startRow - emoji.row) * 0.1
        longestDuration = max(longestDuration, duration + delay)
        
        let newPosition = pointForColumn(emoji.column, row: emoji.row)
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.alpha = 0
        sprite.run(
          SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([
              SKAction.fadeIn(withDuration: 0.05),
              moveAction,
              addEmojiSound])
            ]))
      }
    }
    
    run(SKAction.wait(forDuration: longestDuration), completion: completion)
  }
  
  
  func animateScore(for chain: Chain) {
    // Figure out what the midpoint of the chain is.
    let firstSprite = chain.firstEmoji().sprite!
    let lastSprite = chain.lastEmoji().sprite!
    let centerPosition = CGPoint(
      x: (firstSprite.position.x + lastSprite.position.x)/2,
      y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
    
    // Added a label for the score that slowly floats up.
    let scoreLabel = SKLabelNode(fontNamed: "Bubblegum")
    scoreLabel.fontSize = 23
    scoreLabel.text = String(format: "%ld", chain.score)
    scoreLabel.position = centerPosition
    scoreLabel.zPosition = 300
    emojisLayer.addChild(scoreLabel)
    
    let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3), duration: 0.7)
    moveAction.timingMode = .easeOut
    scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
  }
  
  // animates the entire gameLayer out of the way.
  func animateGameOver(_ completion: @escaping () -> ()) {
    let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
    action.timingMode = .easeIn
    gameLayer.run(action, completion: completion)
  }
  
  // does the opposite and slides the gameLayer back in from the top of the screen.
  func animateBeginGame(_ completion: @escaping () -> ()) {
    gameLayer.isHidden = false
    gameLayer.position = CGPoint(x: 0, y: size.height)
    let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
    action.timingMode = .easeOut
    gameLayer.run(action, completion: completion)
  }
  
  func removeAllEmojiSprites() {
    emojisLayer.removeAllChildren()
  }
  
  
  
}









