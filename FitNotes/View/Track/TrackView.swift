//
//  SwiftUIView.swift
//  FitNotes
//
//  Created by xiscorossello on 27/12/2023.
//

import SwiftUI
import SwiftData

struct TrackView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var restTimerManager: RestTimerManager
    
    @Binding var path: NavigationPath
    var group: WorkoutGroup
    
    @AppStorage("defaultWeightUnit") var defaultWeightUnit: WeightUnitSetting = WeightUnitSetting.kg
    @AppStorage("defaultDistanceUnit") var defaultDistanceUnit: DistanceUnitSetting = DistanceUnitSetting.kilometers
    @AppStorage("defaultTimeUnit") var defaultTimeUnit: TimeUnitSetting = TimeUnitSetting.seconds
    @AppStorage("defaultRestTime") var defaultRestTime: Int = 90
    
    @State var reps: Double? = 0
    @State var weight: Double? = 0
    @State var distance: Double? = 0
    @State var time: Double? = 0
    
    @State var selectedSet: WorkoutSet? = nil
    
    @State var isEditExerciseSheetOpen: Bool = false
    @State private var isPersonalRecordsSheetOpen = false
    @State private var isRestTimerSheetOpen = false
    
    @Query var sets: [WorkoutSet]
    
    var exercise: Exercise
    
    init(path: Binding<NavigationPath>, group: WorkoutGroup) {
        
        if (group.exercise == nil) {
            path.wrappedValue.removeLast()
        }
        self.exercise = group.exercise!
        
        _path = path
        
        self.group = group
        let groupID = group.persistentModelID
        self._sets = Query(filter: #Predicate<WorkoutSet> { set in
            set.group?.persistentModelID == groupID
        }, sort: \WorkoutSet.id)
        
        
    }
    
    private func save() {
        let newSet = WorkoutSet(id: sets.count + 1,
                                reps: reps ?? 0,
                                weightKilograms: exercise.weight_unit.toMetric(weight: weight ?? 0, defaultUnit: defaultWeightUnit),
                                distanceMeters: exercise.distance_unit.toMetric(distance: distance ?? 0, defaultUnit: defaultDistanceUnit),
                                timeSeconds: exercise.time_unit.toMetric(time: time ?? 0, defaultUnit: defaultTimeUnit),
                                is_personal_record: false)
        group.entries.append(newSet)
        autocompleteFromSet(newSet)
        recomputePersonalRecords()
        startRestTimerIfNeeded()
        
    }
    
    private func update() {
        
        if (selectedSet == nil) { return }
        
        // Update values if used by exercise
        selectedSet!.reps = exercise.uses_reps ? reps ?? 0 : selectedSet!.reps
        selectedSet!.weightKilograms = exercise.uses_weight ? exercise.weight_unit.toMetric(weight: weight ?? 0, defaultUnit: defaultWeightUnit) : selectedSet!.weightKilograms
        selectedSet!.distanceMeters = exercise.uses_distance ? exercise.distance_unit.toMetric(distance: distance ?? 0, defaultUnit: defaultDistanceUnit) : selectedSet!.distanceMeters
        selectedSet!.timeSeconds = exercise.uses_time ? exercise.time_unit.toMetric(time: time ?? 0, defaultUnit: defaultTimeUnit) : selectedSet!.timeSeconds
        
        recomputePersonalRecords()
        selectedSet = nil
    }
    
    private func delete() {
        hideKeyboard()
        if (selectedSet != nil) {
            var i = 1
            for set in sets {
                if (set != selectedSet) {
                    set.id = i
                    i += 1
                }
            }
            modelContext.delete(selectedSet!)
            recomputePersonalRecords()
            selectedSet = nil
        }
    }

    private var personalRecordSets: [WorkoutSet] {
        exercise.groups
            .flatMap(\.entries)
            .filter { $0.is_personal_record }
            .sorted {
                if $0.reps != $1.reps {
                    return $0.reps > $1.reps
                }
                return $0.weightKilograms > $1.weightKilograms
            }
    }

    private func startRestTimerIfNeeded() {
        let restSeconds = exercise.rest_time_second ?? defaultRestTime
        guard restSeconds > 0 else { return }
        restTimerManager.start(seconds: restSeconds, exerciseName: exercise.name, alertMode: exercise.rest_alert_mode)
    }

    private func autocompleteFromSet(_ set: WorkoutSet) {
        reps = exercise.uses_reps ? set.reps : reps
        weight = exercise.uses_weight ? exercise.weight_unit.fromMetric(weight: set.weightKilograms, defaultUnit: defaultWeightUnit) : weight
        distance = exercise.uses_distance ? exercise.distance_unit.fromMetric(distance: set.distanceMeters, defaultUnit: defaultDistanceUnit) : distance
        time = exercise.uses_time ? exercise.time_unit.fromMetric(time: set.timeSeconds, defaultUnit: defaultTimeUnit) : time
    }

    private func autocompleteFromLastSet() {
        guard let lastSet = sets.last else { return }
        autocompleteFromSet(lastSet)
    }

    private func recomputePersonalRecords() {
        let allSets = exercise.groups.flatMap(\.entries)
        guard !allSets.isEmpty else { return }

        var bestWeightByReps: [Double: Double] = [:]

        for set in allSets {
            let currentBest = bestWeightByReps[set.reps] ?? -.greatestFiniteMagnitude
            if set.weightKilograms > currentBest {
                bestWeightByReps[set.reps] = set.weightKilograms
            }
        }

        for set in allSets {
            let bestWeight = bestWeightByReps[set.reps] ?? .greatestFiniteMagnitude
            set.is_personal_record = set.weightKilograms > 0 && set.weightKilograms >= bestWeight
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack {
                    if restTimerManager.isRunning {
                        HStack {
                            Image(systemName: "timer")
                            Text("Rest: \(restTimerManager.formattedTime)")
                                .bold()
                            Spacer()
                            Button("Stop") {
                                restTimerManager.stop()
                            }
                        }
                        .padding(10)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 4)
                    }
                    
                    HStack {
                        if (exercise.uses_reps) {
                            NumericInputView(value: $reps, title: "Reps", incrementAmount: 1)
                        }
                        if (exercise.uses_distance) {
                            NumericInputView(value: $distance, title: "Distance", incrementAmount: exercise.distance_increment ?? 2.5)
                        }
                    }
                    
                    HStack {
                        if (exercise.uses_weight) {
                            NumericInputView(value: $weight, title: "Weight", incrementAmount: exercise.weight_increment ?? 2.5)
                        }
                        if (exercise.uses_time) {
                            NumericInputView(value: $time, title: "Time", incrementAmount: exercise.time_increment ?? 2.5)
                        }
                    }
                    
                    // Action buttons
                    HStack {
                        if (selectedSet != nil) {
                            Button(action: delete) {
                                Text("Delete")
                                    .frame(width: 125, height: 40)
                                    .background(.purple)
                                    .cornerRadius(8)
                            }
                            Button(action: {
                                hideKeyboard()
                                update()
                            }) {
                                Text("Update")
                                    .frame(width: 125, height: 40)
                                    .background(.blue)
                                    .cornerRadius(8)
                                    .disabled(reps == nil || weight == nil || distance == nil || time == nil)
                            }
                            
                        } else {
                            Button(action: {
                                hideKeyboard()
                                save()
                            }) {
                                Text("Save")
                                    .frame(width: 200, height: 40)
                                    .background(.green)
                                    .cornerRadius(8)
                                    .disabled(reps == nil || weight == nil || distance == nil || time == nil)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                
                // List of sets complete (todo: upcoming)
                SetListView(group: group, sets: sets, selectedSet: $selectedSet)
                    .onChange(of: selectedSet) { _, set in
                        if (selectedSet != nil) {
                            reps = set!.reps
                            weight = exercise.weight_unit.fromMetric(weight: set!.weightKilograms, defaultUnit: defaultWeightUnit)
                            distance = exercise.distance_unit.fromMetric(distance: set!.distanceMeters, defaultUnit: defaultDistanceUnit)
                            time = exercise.time_unit.fromMetric(time: set!.timeSeconds, defaultUnit: defaultTimeUnit)
                        }
                    }
            }
            .onAppear {
                autocompleteFromLastSet()
            }
            .frame(width: geometry.size.width)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar() {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if (group.entries.isEmpty) {
                            modelContext.delete(group)
                        }
                        path = NavigationPath()
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                            Text("Workout")
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(exercise.name)
                        .bold()
                        .onTapGesture {
                            isEditExerciseSheetOpen.toggle()
                        }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isRestTimerSheetOpen = true
                    } label: {
                        Image(systemName: "clock")
                    }

                    Button {
                        isPersonalRecordsSheetOpen = true
                    } label: {
                        Image(systemName: "trophy")
                    }
                }
                //                ToolbarItemGroup(placement: .keyboard) {
                //                    Spacer()
                //                    Button("Done") {
                //                        hideKeyboard()
                //                    }
                //                }
                
            }
            .sheet(isPresented: $isEditExerciseSheetOpen, content: {
                ManageExerciseView()
            })
            .sheet(isPresented: $isPersonalRecordsSheetOpen) {
                NavigationStack {
                    PersonalRecordHistoryView(
                        exerciseName: exercise.name,
                        sets: personalRecordSets,
                        weightUnit: exercise.weight_unit,
                        defaultWeightUnit: defaultWeightUnit
                    )
                }
            }
            .sheet(isPresented: $isRestTimerSheetOpen) {
                NavigationStack {
                    RestTimerControlView(
                        exercise: exercise,
                        defaultRestTime: defaultRestTime
                    )
                }
            }
            .background(
                Rectangle()
                    .fill(.black.opacity(0))
                    .contentShape(.rect)
                    .frame(width: geometry.size.width)
                    .onTapGesture {
                        hideKeyboard()
                        selectedSet = nil
                    })
        }
    }
}

struct RestTimerControlView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var restTimerManager: RestTimerManager

    let exercise: Exercise
    let defaultRestTime: Int
    @State private var defaultRestSecondsInput: String
    @FocusState private var isTimeInputFocused: Bool

    init(exercise: Exercise, defaultRestTime: Int) {
        self.exercise = exercise
        self.defaultRestTime = defaultRestTime
        _defaultRestSecondsInput = State(initialValue: String(exercise.rest_time_second ?? defaultRestTime))
    }

    private var startSeconds: Int {
        Int(defaultRestSecondsInput) ?? (exercise.rest_time_second ?? defaultRestTime)
    }

    private var displayTime: String {
        if restTimerManager.isRunning || restTimerManager.isPaused {
            return restTimerManager.formattedTime
        }

        let seconds = max(0, startSeconds)
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(displayTime)
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .onTapGesture {
                    isTimeInputFocused = true
                }

            VStack(spacing: 8) {
                HStack {
                    Text("Default after each set")
                    Spacer()
                    TextField("90", text: $defaultRestSecondsInput)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72)
                        .focused($isTimeInputFocused)
                }

                Button("Save default") {
                    exercise.rest_time_second = startSeconds
                    try? modelContext.save()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                if restTimerManager.isRunning {
                    Button("Pause") {
                        restTimerManager.pause()
                    }
                    .buttonStyle(.borderedProminent)
                } else if restTimerManager.isPaused {
                    Button("Resume") {
                        restTimerManager.resume()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Start") {
                        exercise.rest_time_second = startSeconds
                        try? modelContext.save()
                        restTimerManager.start(seconds: startSeconds, exerciseName: exercise.name, alertMode: exercise.rest_alert_mode)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button("Stop") {
                    restTimerManager.stop()
                }
                .buttonStyle(.bordered)
            }

            if restTimerManager.isPaused {
                HStack(spacing: 12) {
                    Button("-10s") {
                        restTimerManager.adjust(by: -10)
                    }
                    .buttonStyle(.bordered)

                    Button("+10s") {
                        restTimerManager.adjust(by: 10)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Rest Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

struct PersonalRecordHistoryView: View {
    @Environment(\.dismiss) private var dismiss

    let exerciseName: String
    let sets: [WorkoutSet]
    let weightUnit: WeightUnit
    let defaultWeightUnit: WeightUnitSetting

    var body: some View {
        List {
            if sets.isEmpty {
                ContentUnavailableView("No PRs yet", systemImage: "trophy", description: Text("Save heavier sets to build your PR history."))
            } else {
                ForEach(sets) { set in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(format(set.reps)) reps x \(formatWeight(set.weightKilograms))")
                                .bold()
                            if let date = set.group?.date {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
        .navigationTitle("\(exerciseName) PR")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") { dismiss() }
            }
        }
    }

    private func formatWeight(_ kilograms: Double) -> String {
        let converted = weightUnit.fromMetric(weight: kilograms, defaultUnit: defaultWeightUnit)
        return "\(format(converted)) \(weightUnit.resolve(defaultUnit: defaultWeightUnit))"
    }

    private func format(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
}
