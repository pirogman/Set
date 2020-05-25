//
//  SetGame.swift
//  Set
//
//  Created by Alex Pirog on 05.05.2020.
//  Copyright © 2020 Alex Pirog. All rights reserved.
//

import Foundation

protocol SetBotDelegate {
    
    func botStateUpdated()
    
}

class SetGame {
    
    enum BotState {
        // Game states
        case angry
        case thinking
        case aboutToAct
        case madeIt
        case noSet
        
        // Other states
        case initial
        case lost
        case won
        case off
        
        func nextState() -> BotState {
            switch self {
            case .angry: return .thinking
            case .thinking: return .aboutToAct
            case .aboutToAct: return .madeIt
            case .madeIt: return .thinking
            case .noSet: return .thinking
            case .initial: return .thinking
            default: return self
            }
        }
    }
    
    let initialDeal = 12
    let maximumCardsInGame = 81
    
    var delegate: SetBotDelegate?
    
    private(set) var deck = [Card]()
    private(set) var cardsInGame = [Card]()
    private(set) var selectedCards = [Card]()
    private(set) var matchedCards = [Card]()
    private(set) var possibleHint = [Card]()
    
    private(set) var userScore = 0
    private(set) var botScore = 0
    
    private(set) var botState = BotState.initial
    
    private var botTimer = Timer()
    
    private var lastActionTime = Date.init()
    
    var isMatched: Bool {
        return (selectedCards.count == 3)
            ? Card.match(selectedCards[0], selectedCards[1], selectedCards[2]) : false
    }
    
    init(activateBot: Bool) {
        for c in Card.Color.all {
            for n in Card.Number.all {
                for p in Card.Shape.all {
                    for s in Card.Shading.all {
                        deck.append(Card(color: c, number: n, shape: p, shading: s))
                    }
                }
            }
        }
        deck.shuffle()
        deal(numberOfCards: initialDeal, penaliseForAvailableSets: false)
        botState = activateBot ? .initial : .off
        updateBotState()
    }
    
    func shuffle() {
        cardsInGame.shuffle()
    }
    
    func select(card: Card) {
        if cardsInGame.contains(card) {
            if selectedCards.count == 3 {
                matchCards()
                
                // Select new card
                if !matchedCards.contains(card) {
                    selectedCards.append(card)
                }
            } else {
                if let index = selectedCards.firstIndex(of: card) {
                    // Deselect
                    selectedCards.remove(at: index)
                    userScore -= (cardsInGame.count / 12)
                } else {
                    // Select
                    selectedCards.append(card)
                }
            }
        }
    }
    
    func deal(numberOfCards cardsToDeal: Int, penaliseForAvailableSets: Bool) {
        if isMatched {
            // Match -> replace cards
            matchCards()
        } else {
            if penaliseForAvailableSets, !getPossibleSetsInGame().isEmpty {
                // There were possible sets and we are dealing new cards -> apply penalty
                userScore -= (cardsInGame.count + 1) / 12
            }
            // Deal new cards if possible
            if cardsToDeal > 0 {
                for _ in 1...cardsToDeal {
                    if deck.count > 0 && cardsInGame.count < maximumCardsInGame {
                        cardsInGame.append(deck.remove(at: 0))
                    }
                }
            }
        }
    }
    
    func completeSelectedSet() {
        let possibleSets = getPossibleSetsInGame()
        
        if !possibleSets.isEmpty {
            // There IS possible set
            switch selectedCards.count {
            case 3: // All 3 selected
                if !isMatched {
                    // Selected mismatch -> apply penalty & select possible set
                    matchCards()
                    selectedCards = possibleSets.first!
                } else {
                    // Selected match -> go with regular match
                    matchCards()
                }
            case 2: // Need one more card
                fallthrough
            case 1: // Single card selected
                for possibleSet in possibleSets {
                    // Checking twice for single selection though
                    if possibleSet.contains(selectedCards.first!) && possibleSet.contains(selectedCards.last!) {
                        selectedCards = possibleSet
                    }
                }
                
                // Unable to find card to complete match -> get all new cards
                if !(selectedCards.count == 3) { selectedCards = possibleSets.first! }
                
                // Hint successful -> apply penalty
                userScore -= 1 + (cardsInGame.count / 8)
            case 0: // Nothing selected -> select any available set
                selectedCards = possibleSets.first!
                
                // Hint successful -> apply penalty
                userScore -= 1 + (cardsInGame.count / 8)
            default: // unapropriate selection
                break
            }
        }
    }
    
    func getHintForSelection() {
        if !getPossibleSetsInGame().isEmpty {
            // There is a SET to suggest
            if selectedCards.count == 1 {
                // Find 2 cards to match selected one
                for firstIndex in 0..<cardsInGame.count - 1 {
                    if !selectedCards.contains(cardsInGame[firstIndex]) {
                        for secondIndex in firstIndex+1..<cardsInGame.count {
                            if !selectedCards.contains(cardsInGame[secondIndex]) {
                                if Card.match(selectedCards.first!, cardsInGame[firstIndex], cardsInGame[secondIndex]) {
                                    // Found 2 cards to match selected one -> get hint
                                    possibleHint = [selectedCards.first!, cardsInGame[firstIndex], cardsInGame[secondIndex]]
                                }
                            }
                        }
                    }
                }
            } else if selectedCards.count == 2 {
                // Find 3rd card to match
                for card in cardsInGame {
                    if !selectedCards.contains(card) {
                        if Card.match(selectedCards.first!, selectedCards.last!, card) {
                            // Found card to match selected 2 -> get hint
                            possibleHint = [selectedCards.first!, selectedCards.last!, card]
                        }
                    }
                }
            } else {
                // Nothing selected or full selection -> get random hint
                possibleHint = getPossibleSetsInGame().first!
            }
            
            // Apply penalty for providing a hint
            userScore -= 1 + (cardsInGame.count / 6)
        } else {
            // Nothing to suggest -> clear hint
            possibleHint.removeAll()
        }
    }
    
    func getPossibleSetsInGame() -> [[Card]] {
        var all = [[Card]]()
        
        for firstIndex in 0..<cardsInGame.count - 2 {
            for secondIndex in firstIndex+1..<cardsInGame.count - 1 {
                for thirdIndex in secondIndex+1..<cardsInGame.count {
                    if Card.match(cardsInGame[firstIndex], cardsInGame[secondIndex], cardsInGame[thirdIndex]) {
                        // Possible match -> save set
                        all.append([cardsInGame[firstIndex], cardsInGame[secondIndex], cardsInGame[thirdIndex]])
                    }
                }
            }
        }
        
        // Shuffle if any
        if !all.isEmpty { all.shuffle() }
        
        return all
    }
    
    private func matchCards() {
        // Update hint if any
        if !possibleHint.isEmpty {
            for card in possibleHint {
                // Card in hint left the game -> clear hint
                if !cardsInGame.contains(card) {
                    possibleHint.removeAll()
                }
            }
        }
        
        // Do the math
        if isMatched {
            // Time-based score (-1 point for every 5 seconds)
            // But not more than -6 total (30 seconds)
            let newTime = Date.init()
            let penalty = Int(Double(newTime.timeIntervalSince(lastActionTime) / 5).rounded())
            userScore -= min(penalty, 6)
            lastActionTime = newTime
            
            // Match
            userScore += 12 - (cardsInGame.count / 6)
            cardsInGame = cardsInGame.filter { !selectedCards.contains($0) }
            matchedCards.append(contentsOf: selectedCards)
            selectedCards.removeAll()
            
            // There was a match -> add 3 new cards
            deal(numberOfCards: 3, penaliseForAvailableSets: false)
            
            // No more possible SETs to match -> end game
            if deck.isEmpty && getPossibleSetsInGame().isEmpty {
                // Update bot state one last time
                botState = (botScore > userScore) ? .won : .lost
            } else if botState != .off {
                // Bot is getting angry!
                botState = .angry
                botTimer.invalidate()
                botTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateBotState), userInfo: nil, repeats: false)
            }
        } else {
            // Mismatch
            userScore -= 1 + (cardsInGame.count / 8)
            selectedCards.removeAll()
        }
    }
    
    @objc private func updateBotState() {
        // Stop timer, just in case game ended
        botTimer.invalidate()
        
        // Check if bot is active
        if botState != .off {
            if botState != .won && botState != .lost {
                // Game goes on -> update winner
                botState = botState.nextState()
                
                var waitTime: TimeInterval = 0.0
                
                switch botState {
                case .angry, .initial: waitTime = TimeInterval(3.0)
                case .thinking: waitTime = TimeInterval(Double.getRandom(from: 4.0, to: 8.0))
                case .aboutToAct: waitTime = TimeInterval(Double.getRandom(from: 2.0, to: 4.0))
                case .madeIt:
                    waitTime = TimeInterval(3.0)
                    if let set = getPossibleSetsInGame().last {
                        // There is a SET to complete
                        botScore += 12 - (cardsInGame.count / 3)
                        selectedCards.remove(allFrom: set)
                        cardsInGame.remove(allFrom: set)
                        matchedCards.append(contentsOf: set)
                        deal(numberOfCards: 3, penaliseForAvailableSets: false)
                    } else {
                        // No SET available -> deal more cards
                        botState = .noSet
                        deal(numberOfCards: 3, penaliseForAvailableSets: false)
                    }
                default: break // Won or lost -> timer should be off by this time
                }
                
                // Bot is losing it -> make him move 30% faster
                if botScore < userScore {
                    waitTime = waitTime * 0.7
                }
                
                botTimer = Timer.scheduledTimer(timeInterval: waitTime, target: self, selector: #selector(updateBotState), userInfo: nil, repeats: false)
            }
        }
        
        // Inform delegate if any
        delegate?.botStateUpdated()
    }
    
}

extension Array where Element: Hashable {
    
    mutating func remove(_ element: Element) {
        var newArray = [Element]()
        
        for index in 0..<self.count {
            if self[index] != element {
                newArray.append(self[index])
            }
        }
        
        self = newArray
    }
    
    mutating func remove(allFrom array: Array<Element>) {
        for element in array {
            self.remove(element)
        }
    }
    
}

extension Double {
    
    static func getRandom(from fromValue: Double, to toValue: Double) -> Double {
        let minValue = min(fromValue, toValue)
        let maxValue = max(fromValue, toValue)
        let diference = maxValue - minValue
        let random = Double(arc4random()) / Double(UINT32_MAX)
        
        return minValue + diference * random
    }
    
}
