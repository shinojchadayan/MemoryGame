//
//  Array+Shuffle.swift
//  ColourMemoryGame
//
//  Created by Shinoj Chadayan on 11/09/16.
//  Copyright © 2016 Shinoj Chadayan. All rights reserved.
//

import Foundation

extension Array {
    //Randomizes the order of the array elements
    mutating func shuffle() {
        for _ in 1...self.count {
            self.sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}