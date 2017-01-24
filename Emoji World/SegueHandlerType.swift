//
//  SegueHandlerType.swift
//  Emoji World
//
//  Created by Michael De La Cruz on 12/4/16.
//  Copyright © 2016 Michael De La Cruz. All rights reserved.
//

//import Foundation
//import UIKit


// Planning on using protocols to handle Segues better ;D

/*
 
 protocol SegueHandlerType {
 associatedtype SegueIdentifier: RawRepresentable
 }
 
 extension SegueHandlerType where Self: UIViewController,
 SegueIdentifier.RawValue == String
 {
 func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
 
 performSegueWithIdentifier(segueIdentifier.rawValue, sender: sender)
 }
 
 func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
 
 guard let identifier = segue.identifier,
 segueIdentifier = SegueIdentifier(rawValue: identifier) else {
 fatalError("Invalid segue identifier \(segue.identifier)")
 }
 return segueIdentifier
 }
 }
 
 */
