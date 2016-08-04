//
//  GameViewController.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright (c) 2016 Michael De La Cruz. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        level = Level(filename: "Level_3")
        scene.level = level
        scene.addTiles()

        beginGame()
    }
    
    var level: Level!
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newEmojis = level.shuffle()
        scene.addSpritesForEmojis(newEmojis)
    }
    
}
