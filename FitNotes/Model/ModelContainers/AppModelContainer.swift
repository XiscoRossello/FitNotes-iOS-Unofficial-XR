//
//  SwiftDataModelContainer.swift
//  FitNotes
//
//  Created by xiscorossello on 27/12/2023.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
let AppModelContainer: ModelContainer = {
    do {
        
        @AppStorage("initialized") var initialised: Bool = false
        
        let container = try ModelContainer(
            for: ExerciseCategory.self,
            Exercise.self,
            WorkoutSet.self,
            WorkoutGroup.self,
            WorkoutTemplate.self,
            WorkoutTemplateItem.self,
            WorkoutTemplateSet.self
        )

        // Keep default category colors clearly separated for existing installs too.
        let paletteByName: [String: String] = [
            "Shoulders": "#1E88E5",
            "Triceps": "#E53935",
            "Biceps": "#43A047",
            "Chest": "#FB8C00",
            "Back": "#6D4C41",
            "Legs": "#00897B",
            "Abs": "#8E24AA",
            "Cardio": "#FDD835"
        ]
        if let existingCategories = try? container.mainContext.fetch(FetchDescriptor<ExerciseCategory>()) {
            for category in existingCategories {
                if let newColour = paletteByName[category.name], category.colour != newColour {
                    category.colour = newColour
                }
            }
            try? container.mainContext.save()
        }
        
        // If already initialised, return container
        guard !initialised else {
            return container
        }
        
        // Add default exercise categories
        container.mainContext.insert(ShoulderCategory)
        container.mainContext.insert(TricepCategory)
        container.mainContext.insert(BicepCategory)
        container.mainContext.insert(ChestCategory)
        container.mainContext.insert(BackCategory)
        container.mainContext.insert(LegsCategory)
        container.mainContext.insert(AbsCategory)
        container.mainContext.insert(CardioCategory)
  
        
        for exercise in ExerciseDefaultData {
            container.mainContext.insert(exercise)
        }
        
        return container
        
    } catch {
        
        fatalError("Failed to create container")
    }
}()


