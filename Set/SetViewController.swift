//
//  ViewController.swift
//  Set
//
//  Created by Alex Pirog on 05.05.2020.
//  Copyright © 2020 Alex Pirog. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, SetBotDelegate {

    private var botFaces: [SetGame.BotState:String] = [
        .angry : "😠", .thinking : "🤔", .aboutToAct : "😁", .madeIt : "😎",
        .initial : "✋", .noSet : "😮", .lost : "😢", .won : "😂", .off : "😴"
    ]
    
    // SetBotDelegate
    func botStateUpdated() {
        updateGame()
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var botLabel: UILabel!
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBOutlet weak var showHintButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var gridView: GridView!{
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealMoreCards))
            swipe.direction = [.up, .down, .left, .right]
            gridView.addGestureRecognizer(swipe)
            let rotation = UIRotationGestureRecognizer(target: self, action: #selector(shuffle))
            gridView.addGestureRecognizer(rotation)
        }
    }
    
    let includeBot = true
    lazy var game = SetGame(activateBot: includeBot)
    lazy var allCardViews = [SetCardView]()
    
    @IBAction func selectCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let point = sender.location(in: gridView)
            for view in allCardViews {
                if view.frame.contains(point) {
                    game.select(card: view.card!)
                    updateGame()
                }
            }
        default: break
        }
    }
    
    @IBAction func dealMoreCards(_ sender: UIButton) {
        game.deal(numberOfCards: 3, penaliseForAvailableSets: true)
        
        updateGame()
    }
    
    @IBAction func showHint(_ sender: UIButton) {
        game.getHintForSelection()
        
        updateGame()
    }
    
    @IBAction func startNewGame(_ sender: UIButton) {
        game = SetGame(activateBot: includeBot)
        game.delegate = self
        
        updateGame()
    }
    
    @objc private func shuffle() {
        game.shuffle()
        
        updateGame()
    }
    
    func updateGame() {
        // Update score
        scoreLabel.text = "SCORE: \(game.userScore) vs \(game.botScore)"
        
        // Update bot expression
        botLabel.text = botFaces[game.botState] ?? "?"
        
        
        // Update dealing more cards
        if !game.deck.isEmpty {
            // There are cards in deck
            if game.isMatched {
                // Selected match can be replaced
                dealCardsButton.isEnabled = true
                dealCardsButton.setTitle("REPLASE MATCH", for: .normal)
            } else {
                // No match selected yet
                if game.cardsInGame.count < game.maximumCardsInGame {
                    // We still can add more cards
                    dealCardsButton.isEnabled = true
                    dealCardsButton.setTitle("DEAL 3 MORE (\(game.deck.count))", for: .normal)
                } else {
                    // No place to deal more cards
                    dealCardsButton.isEnabled = false
                    dealCardsButton.setTitle("CANN'T DEAL", for: .normal)
                }
            }
        } else {
            // No more cards in deck
            dealCardsButton.isEnabled = false
            dealCardsButton.setTitle("CANN'T DEAL", for: .normal)
        }
        
        // Update hints
        if !game.getPossibleSetsInGame().isEmpty {
            // Provide hints
            showHintButton.isEnabled = true
            showHintButton.setTitle("💡", for: .normal)
        } else {
            // No possible sets
            showHintButton.isEnabled = false
            showHintButton.setTitle("⛔️", for: .normal)
        }
        
        // Remove all old views
        for view in allCardViews {
            view.removeFromSuperview()
        }
        allCardViews.removeAll()
        
        // Create new views for cards in game
        for card in game.cardsInGame {
            let cardView = SetCardView()
            cardView.card = card
            allCardViews.append(cardView)
            
            // Selected/Hint/Match update
            cardView.backgroundColor = UIColor.clear
            cardView.isSelected = game.selectedCards.contains(card)
            cardView.isHint = game.possibleHint.contains(card)
            cardView.isMatched = game.isMatched && game.selectedCards.contains(card)
        }
        
        // Show new cards
        gridView.showAspectRatioGrid(of: allCardViews, vertical: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.delegate = self
        gridView.backgroundColor = UIColor.clear
                
        // Customize game buttons
        dealCardsButton.layer.cornerRadius = 8.0
        showHintButton.layer.cornerRadius = 8.0
        newGameButton.layer.cornerRadius = 8.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGame()
    }

}
