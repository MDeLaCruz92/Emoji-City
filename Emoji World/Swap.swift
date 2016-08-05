//
//  Swap.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

struct Swap: CustomStringConvertible {
    let emojiA: Emoji
    let emojiB: Emoji
    
    init(emojiA: Emoji, emojiB: Emoji) {
        self.emojiA = emojiA
        self.emojiB = emojiB
    }
    
    var description: String {
        return "swap \(emojiA) with \(emojiB)"
    }
}