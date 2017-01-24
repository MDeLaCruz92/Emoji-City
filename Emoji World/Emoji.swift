//
//  Emoji.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

import SpriteKit

enum EmojiType: Int, CustomStringConvertible {
  case unknown = 0, smiley, smirky, slick, tearing, tired, laughy
  
  var spriteName: String {
    let spriteNames = [
      "Smiley",
      "Smirky",
      "Slick",
      "Tearing",
      "Tired",
      "Laughy"]
    
    return spriteNames[rawValue - 1]
  }
  
  var highlightedSpriteName: String {
    return spriteName + "-Highlighted"
  }
  
  static func random() -> EmojiType {
    return EmojiType(rawValue: Int(arc4random_uniform(6)) + 1)!
  }
  
  var description: String {
    return spriteName
  }
}

func ==(lhs: Emoji, rhs: Emoji) -> Bool {
  return lhs.column == rhs.column && lhs.row == rhs.row
}

class Emoji: CustomStringConvertible, Hashable  {
  
  var description: String {
    return "type:\(emojiType) square:(\(column),\(row))"
  }
  
  var column: Int
  var row: Int
  let emojiType: EmojiType
  var sprite: SKSpriteNode?
  
  init(column: Int, row: Int, emojiType: EmojiType) {
    self.column = column
    self.row = row
    self.emojiType = emojiType
  }
  
  var hashValue: Int {
    return row*10 + column
  }
  
}
