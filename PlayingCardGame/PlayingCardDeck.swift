//
//  PlayingCardDeck.swift
//  PlayingCardGame
//
//  Created by 김동환 on 21/02/2020.
//  Copyright © 2020 김동환. All rights reserved.
//

import Foundation

struct PlayingCardDeck{
    
    init(){
        for suit in PlayingCard.Suit.all{
            for rank in PlayingCard.Rank.all{
                cards.append(PlayingCard(suit:suit, rank : rank))
            }
        }
    }
    
    //set 만 private 하고 get은 internal 하다.
    private(set) var cards = [PlayingCard]()
    
    mutating func draw() -> PlayingCard?{
        if cards.count > 0 {
            return cards.remove(at : cards.count.arc4random)
        }
        return nil
    }
    
    
}

extension Int{
    var arc4random:Int{
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        }
        else{
            return 0
        }
    }
}
