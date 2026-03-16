//
//  Entry.swift
//  FitNotes
//
//  Created by xiscorossello on 27/12/2023.
//

import Foundation
import SwiftData

@Model
class WorkoutSet {
    
    init(id: Int, group: WorkoutGroup? = nil, reps: Double = 0, weightKilograms: Double = 0, distanceMeters: Double = 0, timeSeconds: Double = 0, is_personal_record: Bool = false, is_complete: Bool? = nil) {
        
        self.id = id
        self.group = group
        self.reps = reps
        self.weightKilograms = weightKilograms
        self.distanceMeters = distanceMeters
        self.timeSeconds = timeSeconds
        self.is_personal_record = is_personal_record
        self.is_complete = is_complete
        
    }
    
    var id: Int
    
    var group: WorkoutGroup?

    
    var reps: Double
    var weightKilograms: Double
    var distanceMeters: Double
    var timeSeconds: Double
    
    var is_personal_record: Bool
    
    var is_complete: Bool?
    
}
