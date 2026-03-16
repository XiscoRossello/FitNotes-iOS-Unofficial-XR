//
//  Category.swift
//  FitNotes
//
//  Created by xiscorossello on 26/12/2023.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class ExerciseCategory {
    
    init(name: String, colour: String = "#FFFFFF") {
        self.name = name
        self.colour = colour
        self.exercises = [Exercise]()
    }
    
    
    @Attribute(.unique) var name: String
    var colour: String
    
    @Relationship(deleteRule: .nullify, inverse: \Exercise.category)
    var exercises: [Exercise]
    
}

// Default categories
var ShoulderCategory = ExerciseCategory(name: "Shoulders", colour: "#1E88E5") // blue
var TricepCategory = ExerciseCategory(name: "Triceps", colour: "#E53935") // red
var BicepCategory = ExerciseCategory(name: "Biceps", colour: "#43A047") // green
var ChestCategory = ExerciseCategory(name: "Chest", colour: "#FB8C00") // orange
var BackCategory = ExerciseCategory(name: "Back", colour: "#6D4C41") // brown
var LegsCategory = ExerciseCategory(name: "Legs", colour: "#00897B") // teal
var AbsCategory = ExerciseCategory(name: "Abs", colour: "#8E24AA") // purple
var CardioCategory = ExerciseCategory(name: "Cardio", colour: "#FDD835") // yellow
