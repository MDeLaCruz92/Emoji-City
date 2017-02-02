//
//  GameViewController.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 8/4/16.
//  Copyright (c) 2016 Michael De La Cruz. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
  var scene: GameScene!
  var level: Level!
  var currentLevelNum = 0
  var remainderMoves = 0
  var score = 0
  var tapGestureRecognizer: UITapGestureRecognizer!
  var countDown = Timer()
  var musicBackGround: AVAudioPlayer!
  
  @IBAction func musicBGButtonPressed(_ sender: UIButton) {
    if (musicBackGround.isPlaying) {
      musicBackGround.pause()
      sender.alpha = 0.2
    } else {
      musicBackGround.play()
      sender.alpha = 1.0
    }
  }
  
  @IBOutlet weak var labelMoves: UILabel!
  @IBOutlet weak var labelScore: UILabel!
  @IBOutlet weak var labelGoal: UILabel!
  @IBOutlet weak var labelTimer: UILabel!
  @IBOutlet weak var gameOverImg: UIImageView!
  @IBOutlet weak var shamblesBtn: UIButton!
  
  @IBAction func shambleBtnTapped(_: AnyObject) {
    shuffle()
    decrementMoves()
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  override var shouldAutorotate : Bool {
    return true
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLevel(currentLevelNum) // Setup view with levels
    initAudio()
  }
  
  // MARK: Configure the view/scene
  func setupLevel(_ levelNum: Int) {
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    level = Level(filename: "Level_\(levelNum)")
    scene.level = level
    scene.swipeHandler = handleSwipe
    scene.addTiles()
    gameOverImg.isHidden = true
    skView.presentScene(scene)
    
    beginGame()
  }
  
  // MARK: shuffle and begin game method
  func beginGame() {
    score = 0
    remainderMoves = level.maximumMoves
    labelUpdate()
    level.resetComboMultiplier()
    startTimer()
    
    scene.animateBeginGame() {
      self.shamblesBtn.isUserInteractionEnabled = true
    }
    
    shuffle()
  }
  
  func shuffle() {
    scene.removeAllEmojiSprites()
    let newEmojis = level.shuffle()
    scene.addSpritesForEmojis(newEmojis)
  }
  
  // MARK: Handles the swipes and matches
  func handleSwipe(_ swap: Swap) {
    view.isUserInteractionEnabled = false
    
    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animateSwap(swap, completion: handleMatches)
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
      }
    }
  }
  
  func handleMatches() {
    stopTimer()
    let chains = level.removeMatches()
    if chains.count == 0 {      // stopping the recursion if no matches
      beginNextTurn()
      return
    }
    scene.animateMatchedEmojis(chains) {
      for chain in chains {
        self.score += chain.score
      }
      self.labelUpdate()
      
      let columns = self.level.fillHoles()
      self.scene.animateFallingEmojis(columns) {
        let columns = self.level.topUpEmojis()
        self.scene.animateNewEmojis(columns) {
          self.handleMatches() // recursion
        }
      }
    }
  }
  
  func beginNextTurn() {
    level.resetComboMultiplier()
    level.detectPossibleSwaps()
    view.isUserInteractionEnabled = true
    decrementMoves()
  }
  
  func labelUpdate() {
    labelScore.text = String(format: "%ld", score)
    labelMoves.text = String(format: "%ld", remainderMoves)
    labelGoal.text = String(format: "%ld", level.goalScore)
    labelTimer.text = String(format: "%ld", level.timer)
  }
  
  // MARK: Determines if the player win or losses
  func decrementMoves() {
    remainderMoves -= 1
    labelUpdate()
    
    if score >= level.goalScore && level.timer != 0 {
      countDown.invalidate()
      gameOverImg.image = UIImage(named: "NiceWork")
      currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum+1 : 0
      showGameOver()
    } else if remainderMoves == 0 {
      countDown.invalidate()
      gameOverImg.image = UIImage(named: "GameOver")
      showGameOver()
    }
  }
  
  // MARK: GameOver show/hide
  func showGameOver() {
    shamblesBtn.isUserInteractionEnabled = false
    gameOverImg.isHidden = false
    scene.isUserInteractionEnabled = false
    
    scene.animateGameOver() {
      self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
      self.view.addGestureRecognizer(self.tapGestureRecognizer)
    }
  }
  
  func hideGameOver() {
    view.removeGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer = nil
    gameOverImg.isHidden = true
    scene.isUserInteractionEnabled = true
    setupLevel(currentLevelNum)
  }
  
  // MARK: Audio
  func initAudio() {
    let path = Bundle.main.url(forResource: "George Street Shuffle", withExtension: "mp3")
    
    do {
      musicBackGround = try AVAudioPlayer(contentsOf: path!)
      musicBackGround.prepareToPlay()
      musicBackGround.numberOfLoops = -1
      musicBackGround.play()
    } catch let err as NSError {
      print(err.debugDescription)
    }
  }
  
  // MARK: Timer Methods
  func startTimer() {
    countDown = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: false)
    level.timer -= 1
    labelTimer.text = "\(level.timer)"
    
    if level.timer == 0 {
      countDown.invalidate()
      gameOverImg.image = UIImage(named: "GameOver")
      showGameOver()
    }
  }
  
  func stopTimer() {
    if score >= level.goalScore {
      countDown.invalidate()
    }
  }
}
