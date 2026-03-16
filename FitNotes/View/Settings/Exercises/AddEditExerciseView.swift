//
//  AddExerciseView.swift
//  FitNotes
//
//  Created by xiscorossello on 15/04/2024.
//

import SwiftUI
import SwiftData

struct AddEditExerciseView: View {
    
    // Determines how to save
    var exercise: Exercise?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ExerciseCategory.name) var categories: [ExerciseCategory]
    
    
    @State var name: String = ""
    @State var category: ExerciseCategory?
    
    // Units
    /// Reps
    @State var usesReps: Bool = true
    /// Weight
    @State var usesWeight: Bool = true
    @State var weightUnit: WeightUnit = WeightUnit.default
    @State var weightIncrementInput: String = ""
    @State var weightIncrementValid: Bool = true
    /// Distance
    @State var usesDistance: Bool = false
    @State var distanceUnit: DistanceUnit = DistanceUnit.default
    @State var distanceIncrementInput: String = ""
    @State var distanceIncrementValid: Bool = true
    /// Time
    @State var usesTime: Bool = false
    @State var timeUnit: TimeUnit = TimeUnit.default
    @State var timeIncrementInput: String = ""
    @State var timeIncrementValid: Bool = true
    
    // Rest time
    @State var restTimeInput: String = ""
    @State var restTimeValid: Bool = true
    @State var restAlertMode: RestAlertMode = .soundAndVibration
    
    @State var notes: String = ""
    private let initialCategory: ExerciseCategory?
    
    
    var isSaveable: Bool {
        let isEdited = exercise != nil &&
                           (exercise?.name != name ||
                            exercise?.category != category ||
                            exercise?.uses_reps != usesReps ||
                            exercise?.uses_weight != usesWeight ||
                            exercise?.weight_unit != weightUnit ||
                            exercise?.weight_increment != Double(weightIncrementInput) ||
                            exercise?.uses_time != usesTime ||
                            exercise?.time_unit != timeUnit ||
                            exercise?.time_increment != Double(timeIncrementInput) ||
                            exercise?.uses_distance != usesDistance ||
                            exercise?.distance_unit != distanceUnit ||
                            exercise?.distance_increment != Double(distanceIncrementInput) ||
                            exercise?.rest_time_second != Int(restTimeInput) ||
                            exercise?.rest_alert_mode != restAlertMode ||
                            exercise?.notes != notes)
        
        return (
            name != "" &&
            category != nil &&
            // Must have at least one unit to measure
            (usesReps || usesWeight || usesDistance || usesTime) &&
            // Validate that increment inputs are either empty or floats
            (!usesWeight || weightIncrementValid) &&
            (!usesDistance || distanceIncrementValid) &&
            (!usesTime || timeIncrementValid) &&
            restTimeValid &&
            // In case of editing
            (exercise == nil || isEdited)
        )
        
    }
    
    init(exercise: Exercise? = nil, initialCategory: ExerciseCategory? = nil) {
        self.initialCategory = initialCategory
        if (exercise != nil) {
            self.exercise = exercise
            
            _name = State<String>(initialValue: exercise!.name)
            _category = State<ExerciseCategory?>(initialValue: exercise!.category)
            _usesReps = State<Bool>(initialValue: exercise!.uses_reps)
            _usesWeight = State<Bool>(initialValue: exercise!.uses_weight)
            _weightUnit = State<WeightUnit>(initialValue: exercise!.weight_unit)
            _weightIncrementInput = State<String>(initialValue: exercise!.weight_increment?.formatted() ?? "")
            _usesDistance = State<Bool>(initialValue: exercise!.uses_distance)
            _distanceUnit = State<DistanceUnit>(initialValue: exercise!.distance_unit)
            _distanceIncrementInput = State<String>(initialValue: exercise!.distance_increment?.formatted() ?? "")
            _usesTime = State<Bool>(initialValue: exercise!.uses_time)
            _timeUnit = State<TimeUnit>(initialValue: exercise!.time_unit)
            _timeIncrementInput = State<String>(initialValue: exercise!.time_increment?.formatted() ?? "")
            _restTimeInput = State<String>(initialValue: exercise!.rest_time_second?.formatted() ?? "")
            _restAlertMode = State<RestAlertMode>(initialValue: exercise!.rest_alert_mode)
            _notes = State<String>(initialValue: exercise!.notes)
        } else {
            _category = State<ExerciseCategory?>(initialValue: initialCategory)
            let storedDefaultRest = UserDefaults.standard.integer(forKey: "defaultRestTime")
            _restTimeInput = State<String>(initialValue: String(storedDefaultRest == 0 ? 90 : storedDefaultRest))
        }
    }
    
    var body: some View {
        
        List {
            Section("Details") {
                
                TextField("Name", text: $name)
                
                Picker("Category", selection: $category) {
                    if (category == nil) {
                        Text("Select Category").tag(nil as ExerciseCategory?)
                    }
                    ForEach(categories) { pickerCategory in
                        Text(pickerCategory.name)
                            .tag(pickerCategory as ExerciseCategory?)
                    }
                }
            }
        
            Section("Units") {
                Toggle("Track Reps", isOn: $usesReps)

                Toggle("Track Weight", isOn: $usesWeight)
                if (usesWeight) {
                    UnitAndIncrement(selection: $weightUnit, incrementInput: $weightIncrementInput, incrementValid: $weightIncrementValid)
                }
            
                Toggle("Track Distance", isOn: $usesDistance)
                if (usesDistance) {
                    UnitAndIncrement(selection: $distanceUnit, incrementInput: $distanceIncrementInput, incrementValid: $distanceIncrementValid)
                }
            
            
        
                Toggle("Track Time", isOn: $usesTime)
                if (usesTime) {
                    UnitAndIncrement(selection: $timeUnit, incrementInput: $timeIncrementInput, incrementValid: $timeIncrementValid)
                }
            }
                   
            
            Section("Rest Time") {
                ValidatedNumericInput(label: "Rest Time (Sec)", input: $restTimeInput, isValid: $restTimeValid)
                Picker("Rest Alert", selection: $restAlertMode) {
                    ForEach(RestAlertMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
            }
            
            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(15)
            }
            
        }
        .listSectionSpacing(0)
        .navigationBarItems(
            leading: Button("Cancel", action: {
                presentationMode.wrappedValue.dismiss()
            }),
            trailing: Button("Save",action: {
                if (exercise != nil) {
                    
                    // Update data
                    exercise!.name = name
                    exercise!.category = category
                    exercise!.uses_reps = usesReps
                    exercise!.uses_weight = usesWeight
                    exercise!.weight_unit = weightUnit
                    exercise!.weight_increment = Double(weightIncrementInput)
                    exercise!.uses_time = usesTime
                    exercise!.time_unit = timeUnit
                    exercise!.time_increment = Double(timeIncrementInput)
                    exercise!.uses_distance = usesDistance
                    exercise!.distance_unit = distanceUnit
                    exercise!.distance_increment = Double(distanceIncrementInput)
                    exercise!.rest_time_second = Int(restTimeInput)
                    exercise!.rest_alert_mode = restAlertMode
                    exercise!.notes = notes
                    
                    try! modelContext.save()
                    
                    presentationMode.wrappedValue.dismiss()
                    
                } else {
                    
                    modelContext.insert(Exercise(name: name,
                                                 category: category,
                                                 uses_reps: usesReps,
                                                 uses_weight: usesWeight,
                                                 weight_unit: weightUnit,
                                                 weight_increment: Double(weightIncrementInput),
                                                 uses_distance: usesDistance,
                                                 distance_unit: distanceUnit,
                                                 distance_increment: Double(distanceIncrementInput),
                                                 uses_time: usesTime,
                                                 time_unit: timeUnit,
                                                 time_increment: Double(timeIncrementInput),
                                                 notes: notes,
                                                 rest_time_second: Int(restTimeInput),
                                                 rest_alert_mode: restAlertMode))
                }
                
                presentationMode.wrappedValue.dismiss()

            }).disabled(!isSaveable)
        )
        .navigationBarBackButtonHidden()
    }
}

struct UnitAndIncrement<EnumType: PickerEnum> : View  {
    
    @Binding var selection: EnumType
    @Binding var incrementInput: String
    @Binding var incrementValid: Bool
    
    var body: some View {
        HStack {
            Picker("Unit", selection: $selection) {
                ForEach(Array(EnumType.allCases), id: \.self) { unit in
                    Text(unit.rawValue)
                        .tag(unit)
                }
            }
            Divider()
            ValidatedNumericInput(label: "Increment", input: $incrementInput, isValid: $incrementValid)
        }
    }
}

struct ValidatedNumericInput: View {
    
    var label: String
    @Binding var input: String
    @Binding var isValid: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(isValid ? Color.primary : Color.red)
            Spacer()
            TextField("Default", text: $input)
                .frame(width: 60)
                .multilineTextAlignment(.center)
                .foregroundStyle(isValid ? Color.primary : Color.red)
                .onChange(of: input) {
                    isValid = (input == "" || Float(input) != nil)
                }
        }
    }
}


struct AddEditExercisePreview: View {
    var body: some View {
        AddEditExerciseView(exercise: nil)
    }
}

#Preview {
    AddEditExercisePreview()
        .modelContainer(previewContainer)
}
