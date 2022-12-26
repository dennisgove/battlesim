//
//  Roller.swift
//  battlesim
//
//  Created by Dennis Gove on 12/26/22.
//

import Foundation

struct Roller {
    /// Calculates the number of rolls of a six-sided dice which have a value of at most the provided value.
    ///
    /// ```
    /// rollForWins(rolls: 10, atMost: 4) // roll 10 times, return number of rolls <= 4
    /// ```
    ///
    /// - Parameters:
    ///  - rolls: total number of dice rolls to make
    ///  - atMost: maximum dice roll value to count as a win
    ///
    /// - Returns: Total number of rolls which were at most the required value
    func rollForWins(rolls: Int, atMost: Int) -> Int {
        var wins = 0
        for _ in 0 ..< rolls {
            if rollIsAtMost(value: atMost) {
                wins = wins + 1
            }
        }
        
        return wins
    }
    
    /// Determines if the value of a single roll of a six-sided dice is at most the provided value
    ///
    /// ```
    /// print(rollIsAtMost(value: 3)) // true
    /// ```
    ///
    /// - Parameters:
    ///  - value: The maximum acceptable dice roll value
    ///
    /// - Returns: true if the dice roll is at most the provided `value`
    func rollIsAtMost(value: Int) -> Bool {
        return roll() <= value
    }
        
    /// Produce a single roll-value from a six-sided dice piece
    ///
    /// ```
    /// print(roll()) // 3
    /// ```
    ///
    /// - Returns: The calculated dice value from a single roll of a six-sided dice
    func roll() -> Int {
        return rollOf(sides: 6)
    }
    
    /// Procuce a single roll-value from a single dice with `sides` number of sides
    ///
    /// ```
    /// print(rollOf(sides:6)) // 3
    /// ```
    ///
    /// - Parameters:
    ///   - sides: Number of sides on the single dice
    ///
    /// - Returns: The calculated dice value from a single roll of a `sides`-sided dice
    func rollOf(sides: Int) -> Int {
        return Int.random(in: 1...sides)
    }
}
