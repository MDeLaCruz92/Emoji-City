//
//  HowToPlayVC.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 11/29/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

import UIKit
import AVFoundation

class HowToPlayVC: UIViewController {
  
  lazy var readySound: AVAudioPlayer? = {
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
  
  @IBAction func ReadyGoTapped(_: AnyObject) {
    readySound?.play()
    self.performSegue(withIdentifier: "ReadyGo", sender: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ReadyGo" {
      segue.destination as! GameViewController
    }
  }
  
  
  
}
