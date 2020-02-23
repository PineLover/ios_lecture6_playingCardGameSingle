//
//  ViewController.swift
//  PlayingCardGame
//
//  Created by 김동환 on 21/02/2020.
//  Copyright © 2020 김동환. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    

    @IBOutlet weak var playingCardView: PlayingCardView!{
        didSet{setupGestureRecognizers()}
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended{
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        }
    }
    
    @objc private func nextCard(){
        if let card = deck.draw(){
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    private func setupGestureRecognizers(){
        let swipe = UISwipeGestureRecognizer(target : self,
                                             action : #selector(nextCard))
        swipe.direction = [.left,.right]
        playingCardView.addGestureRecognizer(swipe)
        
        let pinch = UIPinchGestureRecognizer(
            target: playingCardView, action: #selector(playingCardView.adjustableCardScale(gestureRecognizer:)))
        
        playingCardView.addGestureRecognizer(pinch)
    }
    
}

