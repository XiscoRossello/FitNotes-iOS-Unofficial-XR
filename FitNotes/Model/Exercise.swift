//
//  Exercise.swift
//  FitNotes
//
//  Created by xiscorossello on 26/12/2023.
//

import Foundation
import SwiftData

@Model
class Exercise {
    
    init(name: String, category: ExerciseCategory? = nil, uses_reps: Bool = true, uses_weight: Bool = true, weight_unit: WeightUnit = WeightUnit.default, weight_increment: Double? = nil, uses_distance: Bool = false, distance_unit: DistanceUnit = DistanceUnit.default, distance_increment: Double? = nil, uses_time: Bool = false, time_unit: TimeUnit = TimeUnit.default, time_increment: Double? = nil, notes: String = "", rest_time_second: Int? = nil, rest_alert_mode: RestAlertMode = .soundAndVibration) {
        self.name = name
        self.category = category
        self.uses_reps = uses_reps
        self.uses_weight = uses_weight
        self.weight_unit = weight_unit
        self.weight_increment = weight_increment
        self.uses_distance = uses_distance
        self.distance_unit = distance_unit
        self.distance_increment = distance_increment
        self.uses_time = uses_time
        self.time_unit = time_unit
        self.time_increment = time_increment
        self.notes = notes
        self.rest_time_second = rest_time_second
        self.rest_alert_mode = rest_alert_mode
        self.groups = []
    }
    
    @Attribute(.unique)
    var name: String
    
    var category: ExerciseCategory?
    
    // Reps
    var uses_reps: Bool
    
    // Weight
    var uses_weight: Bool
    var weight_unit: WeightUnit
    var weight_increment: Double?
    
    // Distance
    var uses_distance: Bool
    var distance_unit: DistanceUnit
    var distance_increment: Double?
    
    // Time
    var uses_time: Bool
    var time_unit: TimeUnit
    var time_increment: Double?
    
    var notes: String
    
    var rest_time_second: Int?
    var rest_alert_mode: RestAlertMode
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutGroup.exercise)
    var groups: [WorkoutGroup]
    
}


var ExerciseDefaultData: [Exercise] = [
    Exercise( name: "Overhead Press", category: ShoulderCategory ),
    Exercise( name: "Seated Dumbbell Press", category: ShoulderCategory ),
    Exercise( name: "Lateral Dumbbell Raise", category: ShoulderCategory ),
    Exercise( name: "Front Dumbbell Raise", category: ShoulderCategory ),
    Exercise( name: "Push Press", category: ShoulderCategory ),
    Exercise( name: "Behind The Neck Barbell Press", category: ShoulderCategory ),
    Exercise( name: "Hammer Strength Shoulder Press", category: ShoulderCategory ),
    Exercise( name: "Seated Dumbbell Lateral Raise", category: ShoulderCategory ),
    Exercise( name: "Lateral Machine Raise", category: ShoulderCategory ),
    Exercise( name: "Rear Delt Dumbbell Raise", category: ShoulderCategory ),
    Exercise( name: "Rear Delt Machine Fly", category: ShoulderCategory ),
    Exercise( name: "Arnold Dumbbell Press", category: ShoulderCategory ),
    Exercise( name: "One-Arm Standing Dumbbell Press", category: ShoulderCategory ),
    Exercise( name: "Cable Face Pull", category: ShoulderCategory ),
    Exercise( name: "Log Press", category: ShoulderCategory ),
    Exercise( name: "Smith Machine Overhead Press", category: ShoulderCategory ),
    Exercise( name: "Close Grip Barbell Bench Press", category: TricepCategory ),
    Exercise( name: "V-Bar Push Down", category: TricepCategory ),
    Exercise( name: "Parallel Bar Triceps Dip", category: TricepCategory ),
    Exercise( name: "Lying Triceps Extension", category: TricepCategory ),
    Exercise( name: "Rope Push Down", category: TricepCategory ),
    Exercise( name: "Cable Overhead Triceps Extension", category: TricepCategory ),
    Exercise( name: "EZ-Bar Skullcrusher", category: TricepCategory ),
    Exercise( name: "Dumbbell Overhead Triceps Extension", category: TricepCategory ),
    Exercise( name: "Ring Dip", category: TricepCategory ),
    Exercise( name: "Smith Machine Close Grip Bench Press", category: TricepCategory ),
    Exercise( name: "Barbell Curl", category: BicepCategory ),
    Exercise( name: "EZ-Bar Curl", category: BicepCategory ),
    Exercise( name: "Dumbbell Curl", category: BicepCategory ),
    Exercise( name: "Seated Incline Dumbbell Curl", category: BicepCategory ),
    Exercise( name: "Seated Machine Curl", category: BicepCategory ),
    Exercise( name: "Dumbbell Hammer Curl", category: BicepCategory ),
    Exercise( name: "Cable Curl", category: BicepCategory ),
    Exercise( name: "EZ-Bar Preacher Curl", category: BicepCategory ),
    Exercise( name: "Dumbbell Concentration Curl", category: BicepCategory ),
    Exercise( name: "Dumbbell Preacher Curl", category: BicepCategory ),
    Exercise( name: "Flat Barbell Bench Press", category: ChestCategory ),
    Exercise( name: "Flat Dumbbell Bench Press", category: ChestCategory ),
    Exercise( name: "Incline Barbell Bench Press", category: ChestCategory ),
    Exercise( name: "Decline Barbell Bench Press", category: ChestCategory ),
    Exercise( name: "Incline Dumbbell Bench Press", category: ChestCategory ),
    Exercise( name: "Flat Dumbbell Fly", category: ChestCategory ),
    Exercise( name: "Incline Dumbbell Fly", category: ChestCategory ),
    Exercise( name: "Cable Crossover", category: ChestCategory ),
    Exercise( name: "Incline Hammer Strength Chest Press", category: ChestCategory ),
    Exercise( name: "Decline Hammer Strength Chest Press", category: ChestCategory ),
    Exercise( name: "Seated Machine Fly", category: ChestCategory ),
    Exercise( name: "Deadlift", category: BackCategory ),
    Exercise( name: "Pull Up", category: BackCategory ),
    Exercise( name: "Chin Up", category: BackCategory ),
    Exercise( name: "Neutral Chin Up", category: BackCategory ),
    Exercise( name: "Dumbbell Row", category: BackCategory ),
    Exercise( name: "Barbell Row", category: BackCategory ),
    Exercise( name: "Pendlay Row", category: BackCategory ),
    Exercise( name: "Lat Pulldown", category: BackCategory ),
    Exercise( name: "Hammer Strength Row", category: BackCategory ),
    Exercise( name: "Seated Cable Row", category: BackCategory ),
    Exercise( name: "T-Bar Row", category: BackCategory ),
    Exercise( name: "Barbell Shrug", category: BackCategory ),
    Exercise( name: "Machine Shrug", category: BackCategory ),
    Exercise( name: "Straight-Arm Cable Pushdown", category: BackCategory ),
    Exercise( name: "Rack Pull", category: BackCategory ),
    Exercise( name: "Good Morning", category: BackCategory ),
    Exercise( name: "Barbell Squat", category: LegsCategory ),
    Exercise( name: "Barbell Front Squat", category: LegsCategory ),
    Exercise( name: "Leg Press", category: LegsCategory ),
    Exercise( name: "Leg Extension Machine", category: LegsCategory ),
    Exercise( name: "Seated Leg Curl Machine", category: LegsCategory ),
    Exercise( name: "Standing Calf Raise Machine", category: LegsCategory ),
    Exercise( name: "Donkey Calf Raise", category: LegsCategory ),
    Exercise( name: "Barbell Calf Raise", category: LegsCategory ),
    Exercise( name: "Barbell Glute Bridge", category: LegsCategory ),
    Exercise( name: "Glute-Ham Raise", category: LegsCategory ),
    Exercise( name: "Lying Leg Curl Machine", category: LegsCategory ),
    Exercise( name: "Romanian Deadlift", category: LegsCategory ),
    Exercise( name: "Stiff-Legged Deadlift", category: LegsCategory ),
    Exercise( name: "Sumo Deadlift", category: LegsCategory ),
    Exercise( name: "Seated Calf Raise Machine", category: LegsCategory ),
    Exercise( name: "Ab-Wheel Rollout", category: AbsCategory ),
    Exercise( name: "Cable Crunch", category: AbsCategory ),
    Exercise( name: "Crunch", category: AbsCategory ),
    Exercise( name: "Crunch Machine", category: AbsCategory ),
    Exercise( name: "Decline Crunch", category: AbsCategory ),
    Exercise( name: "Dragon Flag", category: AbsCategory ),
    Exercise( name: "Hanging Knee Raise", category: AbsCategory ),
    Exercise( name: "Hanging Leg Raise", category: AbsCategory ),
    Exercise( name: "Plank", category: AbsCategory ),
    Exercise( name: "Side Plank", category: AbsCategory ),
    Exercise( name: "Cycling", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Walking", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Rowing Machine", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Stationary Bike", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Swimming", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Running (Treadmill)", category: CardioCategory, uses_distance: true, uses_time: true),
    Exercise( name: "Running (Outdoor)", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Elliptical Trainer", category: CardioCategory, uses_distance: true, uses_time: true ),
    Exercise( name: "Machine Row", category: BackCategory ),
    Exercise( name: "Chest Press (Machine)", category: ChestCategory ),
    Exercise( name: "Rope Tricep Extension", category: TricepCategory ),
    Exercise( name: "Shoulder Press Machine", category: ShoulderCategory ),
    Exercise( name: "Lateral Cable Raise", category: ShoulderCategory ),
    Exercise( name: "Front Cable Raise", category: ShoulderCategory ),
    Exercise( name: "Pectoral Machine", category: ChestCategory ),
    Exercise( name: "Machine Low Row", category: BackCategory ),
    Exercise( name: "Shoulder Press", category: ShoulderCategory ),
    Exercise( name: "Assited Chest Dip", category: ChestCategory ),
    Exercise( name: "Seates Bicep Curl (Machine)", category: BicepCategory ),
    Exercise( name: "EZ-Curl Front Raise", category: ShoulderCategory ),
    Exercise( name: "Dumbbell Shrug", category: ShoulderCategory ),
    Exercise( name: "Decline Leg Press", category: LegsCategory ),
    Exercise( name: "Standing Leg Curl", category: LegsCategory ),
    Exercise( name: "Rear Delt Row", category: BackCategory ),
]
