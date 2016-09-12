//
//  MemoryGameController.swift
//  ColourMemoryGame
//
//  Created by Shinoj Chadayan on 11/09/16.
//  Copyright © 2016 Shinoj Chadayan. All rights reserved.
//

import Foundation
import UIKit.UIImage

// MARK: - MemoryGameDelegate

protocol MemoryGameDelegate {
    func memoryGameDidStart(game: MemoryGame)
    func memoryGame(game: MemoryGame, showCards cards: [Card])
    func memoryGame(game: MemoryGame, hideCards cards: [Card])
    func memoryGameDidEnd(game: MemoryGame, points: intmax_t)
    func memoryGame(game: MemoryGame, count :intmax_t ,foundMatch : Bool)
    
}

// MARK: - MemoryGame

class MemoryGame {
    
    // MARK: - Properties
    
    static var defaultCardImages:[UIImage] = [
        UIImage(named: "colour1")!,
        UIImage(named: "colour2")!,
        UIImage(named: "colour3")!,
        UIImage(named: "colour4")!,
        UIImage(named: "colour5")!,
        UIImage(named: "colour6")!,
        UIImage(named: "colour7")!,
        UIImage(named: "colour8")!
    ];
    
    var cards:[Card] = [Card]()
    var delegate: MemoryGameDelegate?
    var isPlaying: Bool = false
    var numberOfMove : intmax_t = 0
    
    
    private var cardsShown:[Card] = [Card]()
    private var startTime:NSDate?
    
    var numberOfCards: Int {
        get {
            return cards.count
        }
    }
    
    // MARK: - Methods
    /**
     newGame
     
     - parameter cardsData: <#cardsData description#>
     */
    func newGame(cardsData:[UIImage]) {
        cards = randomCards(cardsData)
        startTime = NSDate.init()
        isPlaying = true
        delegate?.memoryGameDidStart(self)
    }
    /**
     stopGame
     */
    func stopGame() {
        isPlaying = false
        cards.removeAll()
        cardsShown.removeAll()
        startTime = nil
    }
    
    /**
     didSelectCard
     
     - parameter card: card description
     */
    func didSelectCard(card: Card?) {
        guard let card = card else { return }
        
        delegate?.memoryGame(self, showCards: [card])
        
        if unpairedCardShown() {
            let unpaired = unpairedCard()!
            if card.equals(unpaired) {
                cardsShown.append(card)
                self.delegate?.memoryGame(self,count: cardsShown.count , foundMatch: true)
            } else {
                numberOfMove = numberOfMove + -1;
                self.delegate?.memoryGame(self,count: numberOfMove , foundMatch: false )
                let unpairedCard = cardsShown.removeLast()
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.delegate?.memoryGame(self, hideCards:[card, unpairedCard])
                }
            }
        } else {
            cardsShown.append(card)
        }
        
        if cardsShown.count == cards.count {
            finishGame()
        }
    }
    
    func cardAtIndex(index: Int) -> Card? {
        if cards.count > index {
            return cards[index]
        } else {
            return nil
        }
    }
    
    func indexForCard(card: Card) -> Int? {
        for index in 0...cards.count-1 {
            if card === cards[index] {
                return index
            }
        }
        return nil
    }
    
    private func finishGame() {
        isPlaying = false
        delegate?.memoryGameDidEnd(self, points : cardsShown.count)
    }
    
    private func unpairedCardShown() -> Bool {
        return cardsShown.count % 2 != 0
    }
    
    private func unpairedCard() -> Card? {
        let unpairedCard = cardsShown.last
        return unpairedCard
    }
    
    private func randomCards(cardsData:[UIImage]) -> [Card] {
        var cards = [Card]()
        for i in 0...cardsData.count-1 {
            let card = Card.init(image: cardsData[i])
            cards.appendContentsOf([card, Card.init(card: card)])
        }
        cards.shuffle()
        return cards
    }
    
}