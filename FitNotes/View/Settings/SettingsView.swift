//
//  Settings.swift
//  FitNotes
//
//  Created by xiscorossello on 30/12/2023.
//

import SwiftUI

enum WeightUnitSetting: String, CaseIterable, PickerEnum {
    case kg = "Kg"
    case lb = "Lb"
}

enum DistanceUnitSetting: String, CaseIterable, PickerEnum {
    case miles = "Miles"
    case kilometers = "Km"
    case meters = "Meters"
}

enum TimeUnitSetting: String, CaseIterable, PickerEnum {
    case seconds = "Seconds"
    case minutes = "Minutes"
}

struct SettingsView: View {
    @AppStorage("defaultWeightIncrement") var defaultWeightIncrement: Double = 2.5
    @AppStorage("defaultDistanceIncrement") var defaultDistanceIncrement: Double = 1
    @AppStorage("defaultTimeIncrement") var defaultTimeIncrement: Double = 1
    
    @State var defaultWeightIncrementInput: String = "2.5"
    @State var defaultDistanceIncrementInput: String = "1"
    @State var defaultTimeIncrementInput: String = "1"
    @State var defaultWeightIncrementInputValid: Bool = true
    @State var defaultDistanceIncrementInputValid: Bool = true
    @State var defaultTimeIncrementInputValid: Bool = true
    
    
    @AppStorage("defaultWeightUnit") var defaultWeightUnit: WeightUnitSetting = WeightUnitSetting.kg
    @AppStorage("defaultDistanceUnit") var defaultDistanceUnit: DistanceUnitSetting = DistanceUnitSetting.kilometers
    @AppStorage("defaultTimeUnit") var defaultTimeUnit: TimeUnitSetting = TimeUnitSetting.seconds
    
    @AppStorage("defaultRestTime") var defaultRestTime: Int = 90
    
    @State private var isManagingExercisesPresented = false
    @State private var isManagingCategoriesPresented = false
    
    var body: some View {
        NavigationView {
            List {
                
                Section("") {
                    HStack {
                        NavigationLink(value: "ImportFromAndroid") {
                            Text("Import Data")
                        }
                    }
                    HStack {
                        NavigationLink(value: "ExportData") {
                            Text("Export Data")
                        }
                    }
                }
                
                Section("") {
                    HStack {
                        NavigationLink(destination: ManageExerciseView()) {
                            Text("Manage Exercises")
                        }
                    }
                    HStack {
                        NavigationLink(value: "EditCategoriesView") {
                            Text("Manage Categories")
                        }
                    }
                }
                
                
                
                Section("Weight") {
                    UnitAndIncrement<WeightUnitSetting>(selection: $defaultWeightUnit, incrementInput: $defaultWeightIncrementInput, incrementValid: $defaultWeightIncrementInputValid)
                }
                
                Section("Distance") {
                    UnitAndIncrement<DistanceUnitSetting>(selection: $defaultDistanceUnit, incrementInput: $defaultDistanceIncrementInput, incrementValid: $defaultDistanceIncrementInputValid)
                }
                    
                Section("Time") {
                    UnitAndIncrement<TimeUnitSetting>(selection: $defaultTimeUnit, incrementInput: $defaultTimeIncrementInput, incrementValid: $defaultTimeIncrementInputValid)
                }
                
                Section(header: Text("Rest Time")) {
                    Stepper(value: $defaultRestTime, in: 0...300, step: 5) {
                        Text("Rest Time: \(defaultRestTime) seconds")
                    }
                }
                
            }
            .listSectionSpacing(0)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}


#Preview {
    
    NavigationStack {
        SettingsView()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
    
}
