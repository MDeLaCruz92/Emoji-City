//
//  IntroVC.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 11/29/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

import UIKit
import AVFoundation

class IntroVC: UIViewController {
  
  lazy var playSound: AVAudioPlayer? = {
    guard let url = Bundle.main.url(forResource: "Play", withExtension: "wav") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      return player
    } catch {
      return nil
    }
  } ()
  
  @IBAction func startGameTapped(_: AnyObject) {
    playSound?.play()
    self.performSegue(withIdentifier: "PressPlay", sender: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PressPlay" {
      _ = segue.destination as! HowToPlayVC
    }
  }

}
