//
//  MetricsViews.swift
//  FitNotes
//
//  Created by xiscorossello on 06/01/2024.
//

import SwiftUI

var doubleFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    formatter.nilSymbol = "-"
    return formatter
}


struct MetricsRow: View {
    
    var set: WorkoutSet
    var exercise: Exercise? {
        self.set.group?.exercise
    }
    
    var numActive: Int {
        guard let exercise else { return 1 }
        let active = exercise.uses_reps.intValue
            + exercise.uses_weight.intValue
            + exercise.uses_distance.intValue
            + exercise.uses_time.intValue
        return max(1, active)
    }
    
    var body: some View {
        Group {
            if let exercise {
                GeometryReader { geometry in
                    HStack {
                        RepsMetricView(set: set, exercise: exercise)
                            .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                            .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)

                        WeightMetricView(set: set, exercise: exercise)
                            .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                            .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)

                        DistanceMetricView(set: set, exercise: exercise)
                            .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                            .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)

                        TimeMetricView(set: set, exercise: exercise)
                            .textScale(Text.Scale.secondary, isEnabled: numActive > 2)
                            .frame(maxWidth: geometry.size.width / CGFloat(numActive), maxHeight: geometry.size.height, alignment: .center)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
}

struct RepsMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise
    
    var body: some View {
        MetricView(value: doubleFormatter.string(from: set.reps as NSNumber) ?? "Error",
                   visible: exercise.uses_reps,
                   label: "Reps")
        
    }
}

struct WeightMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise
    
    @AppStorage("defaultWeightUnit") var defaultWeightUnit: WeightUnitSetting = WeightUnitSetting.kg
    
    var weight: String {
        doubleFormatter.string(from: exercise.weight_unit.fromMetric(weight: set.weightKilograms, defaultUnit: defaultWeightUnit) as NSNumber) ?? "Error"}
        
    var body: some View {
        MetricView(value: weight,
                   visible: exercise.uses_weight,
                   label: exercise.weight_unit.resolve(defaultUnit: defaultWeightUnit))
        
    }
}

struct DistanceMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise
    
    @AppStorage("defaultDistanceUnit") var defaultDistanceUnit: DistanceUnitSetting = DistanceUnitSetting.kilometers
    
    var distance: String {
        doubleFormatter.string(from: exercise.distance_unit.fromMetric(distance: set.distanceMeters, defaultUnit: defaultDistanceUnit) as NSNumber) ?? "Error"
    }
    
    var body: some View {
        MetricView(value: distance,
                   visible: exercise.uses_distance,
                   label: exercise.distance_unit.resolve(defaultUnit: defaultDistanceUnit))
    }
}

struct TimeMetricView: View {

    var set: WorkoutSet
    var exercise: Exercise
    
    @AppStorage("defaultTimeUnit") var defaultTimeUnit: TimeUnitSetting = TimeUnitSetting.seconds
    
    var time: String {
        doubleFormatter.string(from: exercise.time_unit.fromMetric(time: set.timeSeconds, defaultUnit: defaultTimeUnit) as NSNumber) ?? "Error"
    }
    
    var body: some View {
        MetricView(value: time,
                   visible: exercise.uses_time,
                   label: exercise.time_unit.resolve(defaultUnit: defaultTimeUnit))
    }
}


struct MetricView: View {
    
    var value: String
    var visible: Bool
    var label: String
    
    var body: some View {
        if (visible) {
            HStack {
                Text(value)
                    .font(.title2)
                    .bold()
                
                Text(label)
                    .font(.system(size: 14))
            }
        }
        
        
    }
    
}
