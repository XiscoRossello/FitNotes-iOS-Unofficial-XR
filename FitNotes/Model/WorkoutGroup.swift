//
//  Set.swift
//  FitNotes
//
//  Created by xiscorossello on 30/12/2023.
//

import Foundation
import SwiftData

@Model
class WorkoutGroup {
    
    init(dayGroupId: Int, date: Date = .now, notes: String? = nil) {
        self.dayGroupId = dayGroupId
        self.date = date
        self.notes = notes
        self.entries = []
    }
    
    var dayGroupId: Int
    
    var date: Date
    
    var exercise: Exercise?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.group)
    var entries: [WorkoutSet]

    var notes: String?
    
}

@Model
class WorkoutTemplate {
    init(name: String) {
        self.name = name
        self.createdAt = .now
        self.items = []
    }

    @Attribute(.unique)
    var name: String

    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplateItem.template)
    var items: [WorkoutTemplateItem]
}

@Model
class WorkoutTemplateItem {
    init(orderIndex: Int, exercise: Exercise? = nil) {
        self.orderIndex = orderIndex
        self.exercise = exercise
        self.template = nil
        self.sets = []
    }

    var orderIndex: Int

    var exercise: Exercise?

    var template: WorkoutTemplate?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplateSet.item)
    var sets: [WorkoutTemplateSet]
}

@Model
class WorkoutTemplateSet {
    init(id: Int, reps: Double = 0, weightKilograms: Double = 0, distanceMeters: Double = 0, timeSeconds: Double = 0) {
        self.id = id
        self.reps = reps
        self.weightKilograms = weightKilograms
        self.distanceMeters = distanceMeters
        self.timeSeconds = timeSeconds
        self.item = nil
    }

    var id: Int
    var reps: Double
    var weightKilograms: Double
    var distanceMeters: Double
    var timeSeconds: Double

    var item: WorkoutTemplateItem?
}
