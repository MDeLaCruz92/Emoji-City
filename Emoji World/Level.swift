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
let NumLevels = 30

class Level {
  
  var maximumMoves = 0
  var goalScore = 0
  var timer = 0
  
  fileprivate var emojis = Array2D<Emoji>(columns: NumColumns, rows: NumRows)
  fileprivate var tiles = Array2D<Surface>(columns: NumColumns, rows: NumRows)
  fileprivate var possibleSwaps = Set<Swap>()
  fileprivate var comboMultiplier = 0
  
  init(filename: String) {
    // 1
    guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) else { return }
    // 2
    guard let spotsArray = dictionary["tiles"] as? [[Int]] else { return }
    // 3
    for (row, rowArray) in spotsArray.enumerated() {
      // 4
      let titleRow = NumRows - row - 1
      // 5
      for (column, value) in rowArray.enumerated() {
        if value == 1 {
          tiles[column, titleRow] = Surface()
        }
      }
    }
    // Parsed the JSON into a dictionary and grabbed the value and stored it.
    maximumMoves = dictionary["moves"] as! Int
    goalScore = dictionary["goal"] as! Int
    timer = dictionary["timer"] as! Int
  }
  
  func emojiAtColumn(_ column: Int, row: Int) -> Emoji? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return emojis[column, row]
  }
  
  func shuffle() -> Set<Emoji> {
    var set: Set<Emoji>
    repeat {
      set = createInitialEmojis()
      detectPossibleSwaps()
      print("possible swaps: \(possibleSwaps)")
    } while possibleSwaps.count == 0
    return set
  }
  fileprivate func hasChainAtColumn(_ column: Int, row: Int) -> Bool {
    let emojiType = emojis[column, row]!.emojiType
    // Horizontal Chain Check
    var horzLength = 1
    // Left
    var i = column - 1
    while i >= 0 && emojis[i, row]?.emojiType == emojiType {
      i -= 1
      horzLength += 1
    }
    // Right
    i = column + 1
    while i < NumColumns && emojis[i, row]?.emojiType == emojiType {
      i += 1
      horzLength += 1
    }
    if horzLength >= 3 { return true }
    // Vertical Chain Check
    var vertLength = 1
    // Down
    i = row - 1
    while i >= 0 && emojis[column, i]?.emojiType == emojiType {
      i -= 1
      vertLength += 1
    }
    // Up
    i = row + 1
    while i < NumRows && emojis[column, i]?.emojiType == emojiType {
      i += 1
      vertLength += 1
    }
    return vertLength >= 3
  }
  
  func detectPossibleSwaps() {
    var set = Set<Swap>()
    
    for row in 0..<NumRows {
      for column in 0..<NumColumns {
        if let emoji = emojis[column, row] {
          
          if column < NumColumns - 1 {
            // If there is no tile, there is no emoji.
            if let other = emojis[column + 1, row] {
              // Swap them
              emojis[column, row] = other
              emojis[column + 1, row] = emoji
              
              // Is either emoji now part of a chain?
              if hasChainAtColumn(column + 1, row: row) ||
                hasChainAtColumn(column, row: row) {
                set.insert(Swap(emojiA: emoji, emojiB: other))
              }
              // Swap them back
              emojis[column, row] = emoji
              emojis[column + 1, row] = other
            }
          }
          
          if row < NumRows - 1 {
            if let other = emojis[column, row + 1] {
              emojis[column, row] = other
              emojis[column, row + 1] = emoji
              
              // Is either emoji now part of a chain?
              if hasChainAtColumn(column, row: row + 1) ||
                hasChainAtColumn(column, row: row) {
                set.insert(Swap(emojiA: emoji, emojiB: other))
              }
              // Swap them back
              emojis[column, row] = emoji
              emojis[column, row + 1] = other
            }
          }
        }
      }
    }
    possibleSwaps = set
  }
  
  fileprivate func createInitialEmojis() -> Set<Emoji> {
    var set = Set<Emoji>()
    // 1
    for row in 0..<NumRows {
      for column in 0..<NumColumns {
        
        // 2
        if tiles[column, row] != nil {
          var emojiType: EmojiType
          repeat {
            emojiType = EmojiType.random()
          } while (column >= 2 &&
            emojis[column - 1, row]?.emojiType == emojiType &&
            emojis[column - 2, row]?.emojiType == emojiType)
            || (row >= 2 &&
              emojis[column, row - 1]?.emojiType == emojiType &&
              emojis[column, row - 2]?.emojiType == emojiType)
          
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
  
  func tileAtColumn(_ column: Int, row: Int) -> Surface? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return tiles[column, row]
  }
  
  func performSwap(_ swap: Swap) {
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
  
  func isPossibleSwap(_ swap: Swap) -> Bool {
    return possibleSwaps.contains(swap)
  }
  
  fileprivate func dectectHorizontalMatches() -> Set<Chain> {
    // Creating a set to hold the horz chains (Chain objects)
    var set = Set<Chain>()
    // Loop through the rows and columns.
    for row in 0..<NumRows {
      var column = 0
      while column < NumColumns-2 {
        // Skip over any gaps in the level design.
        if let emoji = emojis[column, row] {
          let matchType = emoji.emojiType
          // Checking whether the next two columns have the same emoji type.
          if emojis[column + 1, row]?.emojiType == matchType &&
            emojis[column + 2, row]?.emojiType == matchType {
            // Steps through all matching emojis until it finds a emoji that breaks the chain or it reaches the end of the grid. Then adds all the matching emojis to a new Chain object. Incrementing column for each match.
            let chain = Chain(chainType: .horizontal)
            repeat {
              chain.addEmoji(emojis[column, row]!)
              column += 1
            } while column < NumColumns && emojis[column, row]?.emojiType == matchType
            
            set.insert(chain)
            continue
          }
        }
        // if the next two emojis don't match the current one or if there is an empty tile, then there is no chain, so skip over the emoji.
        column += 1
      }
    }
    return set
  }
  
  // method to scan for vertical emoji matches. same kind of logic as horz, but loops by column in the outer while loop and by row in the inner loop.
  fileprivate func dectectVerticalMatches() -> Set<Chain> {
    var set = Set<Chain>()
    
    for column in 0..<NumColumns {
      var row = 0
      while row < NumRows-2 {
        if let emoji = emojis[column, row] {
          let matchType = emoji.emojiType
          
          if emojis[column, row + 1]?.emojiType == matchType &&
            emojis[column, row + 2]?.emojiType == matchType {
            let chain = Chain(chainType: .vertical)
            repeat {
              chain.addEmoji(emojis[column, row]!)
              row += 1
            } while row < NumRows && emojis[column, row]?.emojiType == matchType
            
            set.insert(chain)
            continue
          }
        }
        row += 1
      }
    }
    return set
  }
  
  func removeMatches() -> Set<Chain> {
    let horizontalChains = dectectHorizontalMatches()
    let verticalChains = dectectVerticalMatches()
    
    removeEmojis(horizontalChains)
    removeEmojis(verticalChains)
    
    calculateScores(for: horizontalChains)
    calculateScores(for: verticalChains)
    
    return horizontalChains.union(verticalChains)
  }
  
  fileprivate func removeEmojis(_ chains: Set<Chain>) {
    for chain in chains {
      for emoji in chain.emojis {
        emojis[emoji.column, emoji.row] = nil
      }
    }
  }
  // this method detects where there are empty tiles and shifts any emojis down to fill up those tiles
  func fillHoles() -> [[Emoji]] {
    var columns = [[Emoji]]()
    // 1
    for column in 0..<NumColumns {
      var array = [Emoji]()
      for row in 0..<NumRows {
        // 2
        if tiles[column, row] != nil && emojis[column, row] == nil {
          // 3
          for lookup in (row + 1)..<NumRows {
            if let emoji = emojis[column, lookup] {
              // 4
              emojis[column, lookup] = nil
              emojis[column, row] = emoji
              emoji.row = row
              // 5
              array.append(emoji)
              // 6
              break
            }
          }
        }
      }
      // 7
      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }
  // returns contains a sub-array for each column that had holes. the emoji objects in these arrrays are ordered from top to bottom.
  func topUpEmojis() -> [[Emoji]] {
    var columns = [[Emoji]]()
    var emojiType: EmojiType = .unknown
    
    for column in 0..<NumColumns {
      var array = [Emoji]()
      
      // loop through the column from top to bottom. The while loop ends when emojis[column, row] is not nil.
      var row = NumRows - 1
      while row >= 0 && emojis[column, row] == nil {
        // ignore gaps in the level, because you only need to fill up grid squares that have a tile.
        if tiles[column, row] != nil {
          // randomly create a new emoji type. It can't be equal to the type of the last new emoji, to prevent too many "freebie" matches.
          var newEmojiType: EmojiType
          repeat {
            newEmojiType = EmojiType.random()
          } while newEmojiType == emojiType
          emojiType = newEmojiType
          // 4 create the new emoji object and add it to the array for this column.
          let emoji = Emoji(column: column, row: row, emojiType: emojiType)
          emojis[column, row] = emoji
          array.append(emoji)
        }
        row -= 1
      }
      // if a column does not have any holes, don't add it to the final array.
      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }
  
  fileprivate func calculateScores(for chains: Set<Chain>) {
    // 3 match combo is 80 pts, 4 match combo is 160, etc.
    for chain in chains {
      chain.score = 50 * (chain.length - 2)
      comboMultiplier += 1
    }
  }
  
  func resetComboMultiplier() {
    comboMultiplier = 1
  }
}

