//
//  SeaBattle.swift
//  battlesim
//
//  Created by Dennis Gove on 12/26/22.
//

import Foundation


struct SeaBattle {
    private let roller: Roller
    private let attacker: SeaAttacker
    private let defender: SeaDefender
    
    init(attacker: SeaAttacker, defender: SeaDefender){
        self.roller = Roller()
        self.attacker = attacker
        self.defender = defender
    }
    
    func runSimulation(battles: Int) -> Double {
        var attackerWins = 0
        
        for _ in 0 ..< battles {
            if runBattle() {
                attackerWins = attackerWins + 1
            }
        }

        let percent = Double(attackerWins) / Double(battles)
        return round(percent * 100.0)
    }
    
    private func runBattle() -> Bool {
        // Create local copies of attacker and defender
        var attacker = self.attacker
        var defender = self.defender
        
        while attacker.canAttack() && defender.canDefend() {
            let attackerSubmarineHits = attacker.calculateSubmarineHits(roller: roller)
            defender.applySubmarineKills(kills: attackerSubmarineHits)
            
            let defenderSubmarineHits = defender.calculateSubmarineHits(roller: roller)
            let defenderHits = defender.calculateHits(roller: roller)
            let attackerHits = attacker.calculateHits(roller: roller)
            
            attacker.applySubmarineKills(kills: defenderSubmarineHits)
            attacker.applyKills(kills: defenderHits)
            defender.applyKills(kills: attackerHits)
        }
        
        // attackers are alive, defenders are dead
        // result: successful attack
        if attacker.canAttack() {
            return true
        }
        
        // attackers are dead, defenders are alive or dead
        // result: failed attack
        return false
    }
}

struct SeaAttacker {
    private let hasHeavyBombers: Bool
    private let hasSuperSubmarines: Bool
    private let prioritizeCarriers: Bool
    
    private var fighters = 0
    private var bombers = 0
    private var transports = 0
    private var submarines = 0
    private var carriers = 0
    private var battleships = 0
    
    init(fighters: Int, bombers: Int, transports: Int, submarines: Int, carriers: Int, battleships: Int, hasHeavyBombers: Bool, hasSuperSubmarines: Bool, prioritizeCarriers: Bool){
        self.fighters = fighters
        self.bombers = bombers
        self.transports = transports
        self.submarines = submarines
        self.carriers = carriers
        self.battleships = battleships
        self.hasHeavyBombers = hasHeavyBombers
        self.hasSuperSubmarines = hasSuperSubmarines
        self.prioritizeCarriers = prioritizeCarriers
    }
        
    /// Determines if this set can continue attacking
    func canAttack() -> Bool {
        return (fighters + bombers + submarines + carriers + battleships) > 0
    }
    
    func calculateSubmarineHits(roller: Roller) -> Int {
        return roller.rollForWins(rolls: submarines, atMost: hasSuperSubmarines ? 3 : 2)
    }
    
    func calculateHits(roller: Roller) -> Int {
        var hits = 0
        
        hits = hits + roller.rollForWins(rolls: fighters, atMost: 3)
        hits = hits + roller.rollForWins(rolls: bombers * (hasHeavyBombers ? 3 : 1), atMost: 4)
        hits = hits + roller.rollForWins(rolls: carriers, atMost: 1)
        hits = hits + roller.rollForWins(rolls: battleships, atMost: 4)
        
        return hits
    }
    
    mutating func applySubmarineKills(kills: Int){
        for _ in 0 ..< kills {
            if transports > 0 {
                transports = transports - 1
            } else if !prioritizeCarriers && carriers > 0 {
                carriers = carriers - 1
            } else if submarines > 0 {
                submarines = submarines - 1
            } else if battleships > 0 {
                battleships = battleships - 1
            } else if prioritizeCarriers && carriers > 0 {
                carriers = carriers - 1
            }
        }
    }
    
    mutating func applyKills(kills: Int){
        for _ in 0 ..< kills {
            if transports > 0 {
                transports = transports - 1
            } else if !prioritizeCarriers && carriers > 0 {
                carriers = carriers - 1
            } else if submarines > 0 {
                submarines = submarines - 1
            } else if fighters > 0 {
                fighters = fighters - 1
            } else if bombers > 0 {
                bombers = bombers - 1
            } else if battleships > 0 {
                battleships = battleships - 1
            } else if prioritizeCarriers && carriers > 0 {
                carriers = carriers - 1
            }
        }
    }
}

struct SeaDefender {
    private let hasJetPower: Bool

    private var fighters = 0
    private var bombers = 0
    private var transports = 0
    private var submarines = 0
    private var carriers = 0
    private var battleships = 0
        
    init(fighters: Int, bombers: Int, transports: Int, submarines: Int, carriers: Int, battleships: Int, hasJetPower: Bool){
        self.fighters = fighters
        self.bombers = bombers
        self.transports = transports
        self.submarines = submarines
        self.carriers = carriers
        self.battleships = battleships
        self.hasJetPower = hasJetPower
    }
        
    /// Determines if this set can continue defending
    func canDefend() -> Bool {
        return (fighters + bombers + transports + submarines + carriers + battleships) > 0
    }
    
    func calculateSubmarineHits(roller: Roller) -> Int {
        return roller.rollForWins(rolls: submarines, atMost: 2)
    }
    
    func calculateHits(roller: Roller) -> Int {
        var hits = 0
        
        hits = hits + roller.rollForWins(rolls: fighters, atMost: hasJetPower ? 5 : 4)
        hits = hits + roller.rollForWins(rolls: bombers, atMost: 1)
        hits = hits + roller.rollForWins(rolls: carriers, atMost: 3)
        hits = hits + roller.rollForWins(rolls: battleships, atMost: 4)
        
        return hits
    }
    
    mutating func applySubmarineKills(kills: Int){
        for _ in 0 ..< kills {
            if transports > 0 {
                transports = transports - 1
            } else if carriers > 0 {
                carriers = carriers - 1
            } else if submarines > 0 {
                submarines = submarines - 1
            } else if battleships > 0 {
                battleships = battleships - 1
            }
        }
    }
    
    mutating func applyKills(kills: Int){
        for _ in 0 ..< kills {
            if transports > 0 {
                transports = transports - 1
            } else if bombers > 0 {
                bombers = bombers - 1
            } else if submarines > 0 {
                submarines = submarines - 1
            } else if carriers > 0 {
                carriers = carriers - 1
            } else if fighters > 0 {
                fighters = fighters - 1
            } else if battleships > 0 {
                battleships = battleships - 1
            }
        }
    }
}
