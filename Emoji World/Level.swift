//
//  Level.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    private var emojis = Array2D<Emoji>(columns: NumColumns, rows: NumRows)
    
    private var tiles = Array2D<Surface>(columns: NumColumns, rows: NumRows)

    
    init(filename: String) {
        // 1
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) else { return }
        // 2
        guard let spotsArray = dictionary["tiles"] as? [[Int]] else { return }
        // 3
        for (row, rowArray) in spotsArray.enumerate() {
            // 4
            let titleRow = NumRows - row - 1
            // 5
            for (column, value) in rowArray.enumerate() {
                if value == 1 {
                    tiles[column, titleRow] = Surface()
                }
            }
        }
    }


func emojiAtColumn(column: Int, row: Int) -> Emoji? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return emojis[column, row]
}
    
    func shuffle() -> Set<Emoji> {
        return createInitialEmoji()
    }
    
    private func createInitialEmoji() -> Set<Emoji> {
        var set = Set<Emoji>()
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                // 2
                if tiles[column, row] != nil {
                var emojiType = EmojiType.random()
                
                // 3
                let emoji = Emoji(column: column, row: row, emojiType: emojiType)
                emojis[column, row] = emoji
                
                // 4
                set.insert(emoji)
                }
            }
        }
        return set
        }
    
    func tileAtColumn(column: Int, row: Int) -> Surface? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func performSwap(swap: Swap) {
        let columnA = swap.emojiA.column
        let rowA = swap.emojiA.row
        let columnB = swap.emojiB.column
        let rowB = swap.emojiB.row
        
        emojis[columnA, rowA] = swap.emojiB
        swap.emojiB.column = columnA
        swap.emojiB.row = rowA
        
        emojis[columnB, rowB] = swap.emojiA
        swap.emojiA.column = columnB
        swap.emojiA.row = rowB
    }
    
    

}










