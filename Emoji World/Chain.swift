//
//  Chain.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/16/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

class Chain: Hashable, CustomStringConvertible {
  var emojis = [Emoji]()  // used array to remember the order of emojis objects
  var score = 0
  
  enum ChainType: CustomStringConvertible {
    case horizontal
    case vertical
    
    var description: String {
      switch self {
      case .horizontal: return "Horizontal"
      case .vertical: return "Vertical"
      }
    }
  }
  
  var chainType: ChainType
  
  init(chainType: ChainType) {
    self.chainType = chainType
  }
  
  func addEmoji(_ emoji: Emoji) {
    emojis.append(emoji)
  }
  
  func firstEmoji() -> Emoji {
    return emojis[0]
  }
  
  func lastEmoji() -> Emoji {
    return emojis[emojis.count - 1]
  }
  
  var length: Int {
    return emojis.count
  }
  
  var description: String {
    return "type:\(chainType) emojis:\(emojis)"
    
  }
  var hashValue: Int {
    return emojis.reduce (0) { $0.hashValue ^ $1.hashValue }
  }
}

func ==(lhs:Chain, rhs: Chain) -> Bool {
  return lhs.emojis == rhs.emojis
}
