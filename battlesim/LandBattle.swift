//
//  LandBattle.swift
//  battlesim
//
//  Created by Dennis Gove on 12/26/22.
//

import Foundation

struct LandBattle {
    private let roller: Roller
    private let attacker: LandAttacker
    private let defender: LandDefender
    
    init(attacker: LandAttacker, defender: LandDefender){
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
        
        // Run first shot kills
        let battleshipHits = attacker.calculateBattleshipHits(roller: roller)
        let aaHits = defender.calculateAAHits(roller: roller)
        attacker.applyAAKills(kills: aaHits)
        defender.applyBattleshipKills(kills: battleshipHits)
        
        while attacker.canAttack() && defender.canDefend() {
            let attackerHits = attacker.calculateHits(roller: roller)
            let defenderHits = defender.calculateHits(roller: roller)
            
            attacker.applyKills(kills: defenderHits)
            defender.applyKills(kills: attackerHits)
        }
        
        // attackers are dead, defenders are alive
        // result: failed attack
        if defender.canDefend() {
            return false
        }
        
        // attackers are alive, defenders are dead
        // result: successful attack
        if attacker.canAttack() {
            return true
        }
        
        // attackers are dead, defenders are dead, attacker prioritized takeover
        // result: failed attack
        if attacker.isPrioritizingTakeover() {
            return false
        }
        
        // attackers are dead, defenders are dead, attacker prioritized killing defenders
        // result: successful attack
        return true
    }
}

struct LandAttacker {
    private let hasHeavyBombers: Bool
    private let prioritizeTakeover: Bool
    
    // These are pre-round attackers and cannot be killed. But also don't count for liveness check.
    private let battleships: Int
    
    private var infantry = 0
    private var tanks = 0
    private var fighters = 0
    private var bombers = 0
    
    init(infantry: Int, tanks: Int, fighters: Int, bombers: Int, battleships: Int, hasHeavyBombers: Bool, prioritizeTakeover: Bool){
        self.infantry = infantry
        self.tanks = tanks
        self.fighters = fighters
        self.bombers = bombers
        self.battleships = battleships
        self.hasHeavyBombers = hasHeavyBombers
        self.prioritizeTakeover = prioritizeTakeover
    }
        
    /// Determines if this set can continue attacking
    func canAttack() -> Bool {
        return (infantry + tanks + fighters + bombers) > 0
    }
    
    func isPrioritizingTakeover() -> Bool {
        return prioritizeTakeover
    }
    
    func calculateBattleshipHits(roller: Roller) -> Int {
        return roller.rollForWins(rolls: battleships, atMost: 4)
    }
    
    func calculateHits(roller: Roller) -> Int {
        var hits = 0
        
        hits = hits + roller.rollForWins(rolls: infantry, atMost: 1)
        hits = hits + roller.rollForWins(rolls: tanks, atMost: 3)
        hits = hits + roller.rollForWins(rolls: fighters, atMost: 3)
        hits = hits + roller.rollForWins(rolls: bombers * (hasHeavyBombers ? 3 : 1), atMost: 4)
        
        return hits
    }
    
    mutating func applyAAKills(kills: Int){
        for _ in 0 ..< kills {
            if fighters > 0 {
                fighters = fighters - 1
            } else if bombers > 0 {
                bombers = bombers - 1
            }
        }
    }
    
    mutating func applyKills(kills: Int){
        // if we prioritize takeover, then save a tank or infantry for last death
        var takeoverInfantry = 0
        var takeoverTanks = 0
        if prioritizeTakeover {
            if tanks > 0 {
                takeoverTanks = 1
                tanks = tanks - 1
            } else if infantry > 0 {
                takeoverInfantry = 1
                infantry = infantry - 1
            }
        }
        
        for _ in 0 ..< kills {
            if infantry > 0 {
                infantry = infantry - 1
            } else if tanks > 0 {
                tanks = tanks - 1
            } else if fighters > 0 {
                fighters = fighters - 1
            } else if bombers > 0 {
                bombers = bombers - 1
            } else if takeoverTanks > 0 {
                takeoverTanks = takeoverTanks - 1
            } else if takeoverInfantry > 0 {
                takeoverInfantry = takeoverInfantry - 1
            }
        }
        
        // If there are either left then add them back to the full count
        infantry = infantry + takeoverInfantry
        tanks = tanks + takeoverTanks
    }
}

struct LandDefender {
    private let hasJetPower: Bool
    
    // These are pre-round defenders and cannot be killed. But also don't count for liveness check.
    private let aa: Int

    private var infantry = 0
    private var tanks = 0
    private var fighters = 0
    private var bombers = 0
        
    init(infantry: Int, tanks: Int, fighters: Int, bombers: Int, aa: Int, hasJetPower: Bool){
        self.infantry = infantry
        self.tanks = tanks
        self.fighters = fighters
        self.bombers = bombers
        self.aa = aa
        self.hasJetPower = hasJetPower
    }
        
    /// Determines if this set can continue defending
    func canDefend() -> Bool {
        return (infantry + tanks + fighters + bombers) > 0
    }
    
    func calculateAAHits(roller: Roller) -> Int {
        return roller.rollForWins(rolls: aa, atMost: 1)
    }
    
    func calculateHits(roller: Roller) -> Int {
        var hits = 0
        
        hits = hits + roller.rollForWins(rolls: bombers, atMost: 1)
        hits = hits + roller.rollForWins(rolls: infantry, atMost: 2)
        hits = hits + roller.rollForWins(rolls: tanks, atMost: 2)
        hits = hits + roller.rollForWins(rolls: fighters, atMost: hasJetPower ? 5 : 4)
        
        return hits
    }
    
    mutating func applyBattleshipKills(kills: Int){
        applyKills(kills: kills)
    }
    
    mutating func applyKills(kills: Int){
        for _ in 0 ..< kills {
            if infantry > 0 {
                infantry = infantry - 1
            } else if tanks > 0 {
                tanks = tanks - 1
            } else if fighters > 0 {
                fighters = fighters - 1
            } else if bombers > 0 {
                bombers = bombers - 1
            }
        }
    }
}
