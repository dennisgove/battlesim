//
//  ContentView.swift
//  battlesim
//
//  Created by Dennis Gove on 11/19/22.
//

import SwiftUI

struct ContentView: View {
    
    let roller = Roller()
    
    var body: some View {
        VStack{
            Button("Play", action: calculate)
        }
    }
    
    func calculate(){
        let landBattle = LandBattle(
            attacker: LandAttacker(
                infantry: 19,
                tanks: 3,
                fighters: 2,
                bombers: 3,
                battleships: 1,
                hasHeavyBombers: true,
                prioritizeTakeover: false
            ),
            defender: LandDefender(
                infantry: 36,
                tanks: 2,
                fighters: 1,
                bombers: 3,
                aa: 1,
                hasJetPower: true
            )
        )
        
        let seaBattle = SeaBattle(
            attacker: SeaAttacker(
                fighters: 2,
                bombers: 1,
                transports: 5,
                submarines: 1,
                carriers: 1,
                battleships: 2,
                hasHeavyBombers: false,
                hasSuperSubmarines: false,
                prioritizeCarriers: false
            ),
            defender: SeaDefender(
                fighters: 3,
                bombers: 0,
                transports: 2,
                submarines: 3,
                carriers: 2,
                battleships: 0,
                hasJetPower: false
            )
        )
        
        print("Land:", landBattle.runSimulation(battles: 1000))
        print("Sea:", seaBattle.runSimulation(battles: 1000))
    }
    
}

