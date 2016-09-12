//
//  Card.swift
//  ColourMemoryGame
//
//  Created by Shinoj Chadayan on 11/09/16.
//  Copyright © 2016 Shinoj Chadayan. All rights reserved.
//

import Foundation
import UIKit.UIImage

class Card : CustomStringConvertible {
    
    // MARK: - Properties

    var id:NSUUID = NSUUID.init()
    var shown:Bool = false
    var image:UIImage

    // MARK: - Lifecycle

    init(image:UIImage) {
        self.image = image
    }
    
    init(card:Card) {
        self.id = card.id.copy() as! NSUUID
        self.shown = card.shown
        self.image = card.image.copy() as! UIImage
    }
    
    // MARK: - Methods

    var description: String {
        return "\(id.UUIDString)"
    }
    
    func equals(card: Card) -> Bool {
        return card.id.isEqual(id)
    }
}