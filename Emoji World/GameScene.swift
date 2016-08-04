//
//  GameScene.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright (c) 2016 Michael De La Cruz. All rights reserved.
//


import SpriteKit

class GameScene: SKScene {
    
    var level: Level!
    
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let emojisLayer = SKNode()
    
    let tilesLayer = SKNode()

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
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
    }
    
    func addSpritesForEmojis(emojis: Set<Emoji>) {
        for emoji in emojis {
            let sprite = SKSpriteNode(imageNamed: emoji.emojiType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointForColumn(emoji.column, row:emoji.row)
            emojisLayer.addChild(sprite)
            emoji.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
  
    
}

