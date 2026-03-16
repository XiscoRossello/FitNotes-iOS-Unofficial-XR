//
//  ImportFromAndroidView.swift
//  FitNotes
//
//  Created by xiscorossello on 14/01/2024.
//

import SwiftUI
import SwiftData

import UniformTypeIdentifiers
import SQLite3

struct ImportFromAndroidView: View {

    let showImportActions: Bool
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExerciseCategory.name) private var allCategories: [ExerciseCategory]
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    @Query(sort: [SortDescriptor(\WorkoutGroup.date), SortDescriptor(\WorkoutGroup.dayGroupId)]) private var allGroups: [WorkoutGroup]
    @Query(sort: \WorkoutTemplate.name) private var allTemplates: [WorkoutTemplate]
    
    @Binding var path: NavigationPath
    
    @State private var importedSets: [WorkoutSet] = []
    @State private var importedGroups: [WorkoutGroup] = []
    @State private var importedCategories: [ExerciseCategory] = []
    
    @State private var importing = false
    @State private var importingAppBackup = false
    @State private var exportingAppBackup = false
    @State private var importFinished = false
    @State private var errorMsg: String? = nil
    @State private var backupDocument: FitNotesBackupDocument?

    init(path: Binding<NavigationPath>, showImportActions: Bool = true) {
        _path = path
        self.showImportActions = showImportActions
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            if (!importFinished) {
                
                VStack(spacing: 14) {
                    Text(showImportActions ? "Restore Data" : "Backup & Restore")
                        .font(.headline)

                    Text(showImportActions
                         ? "Restore from iOS or Android"
                         : "Create a full backup of this iOS app and restore it later on this or another device.")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .padding(.horizontal, 20)

                    if showImportActions {
                        Text("Choose what you want to restore")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .padding(.horizontal, 20)

                        Button {
                            errorMsg = nil
                            importingAppBackup = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.doc")
                                Text("Restore from iOS backup")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 20)

                        Text("Select the FitNotes_backup.fitnotes file from FitNotes Android.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)

                        Button {
                            importing = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import from Android backup")
                            }
                        }
                        .fileImporter(
                            isPresented: $importing,
                            allowedContentTypes: [UTType("com.verdoncreative.FitNotes-androidDB")!]
                        ) { result in
                            importing = false
                            switch result {
                            case .success(let file):
                                let hasAccess = file.startAccessingSecurityScopedResource()
                                defer {
                                    if hasAccess {
                                        file.stopAccessingSecurityScopedResource()
                                    }
                                }

                                parseDatabase(filePath: file.path)
                                importFinished = errorMsg == nil
                            case .failure(let error):
                                errorMsg = error.localizedDescription
                            }
                        }
                        .padding(.bottom)
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            errorMsg = nil
                            backupDocument = FitNotesBackupDocument(backup: buildAppBackup())
                            exportingAppBackup = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export app backup")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 20)
                    }
                }
                .fileExporter(
                    isPresented: $exportingAppBackup,
                    document: backupDocument,
                    contentType: .json,
                    defaultFilename: "FitNotes-iOS-Backup"
                ) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        errorMsg = error.localizedDescription
                    }
                }
                .fileImporter(
                    isPresented: $importingAppBackup,
                    allowedContentTypes: [.json]
                ) { result in
                    switch result {
                    case .success(let file):
                        let hasAccess = file.startAccessingSecurityScopedResource()
                        defer {
                            if hasAccess {
                                file.stopAccessingSecurityScopedResource()
                            }
                        }

                        do {
                            let data = try Data(contentsOf: file)
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            let backup = try decoder.decode(FitNotesBackup.self, from: data)
                            restoreAppBackup(backup)
                            importFinished = true
                        } catch {
                            errorMsg = "Invalid iOS backup file: \(error.localizedDescription)"
                        }
                    case .failure(let error):
                        errorMsg = error.localizedDescription
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
            }
            
            if (errorMsg != nil) {
                Label(
                    title: { Text(errorMsg ?? "-") },
                    icon: { Image(systemName: "exclamationmark.triangle") }
                )
                .foregroundStyle(.red)
                .padding(.vertical, 40)
                
            } else if (importedCategories.count > 0) {
                NavigationView {
                    VStack {
                        Text("Import successful!")
                        List(importedCategories) { category in
                            Section {
                                ForEach(category.exercises) { exercise in
                                    
                                    let sets = exercise.groups.flatMap({ $0.entries }).count
                                    
                                    HStack {
                                        Text(exercise.name)
                                        Spacer()
                                        Text(String(sets))
                                    }
                                }
                            } header: {
                                HStack {
                                    Circle()
                                        .fill(Color.init(hex: category.colour))
                                        .frame(width: 10, height: 10)
                                    Text(category.name)
                                    Spacer()
                                    Text("Sets")
                                }
                            }
                        }
                    }
                }
            }
            
            
            Spacer()
        }
        .navigationTitle(showImportActions ? "Import Android Data" : "Export Data")
    }
    
    private func buildAppBackup() -> FitNotesBackup {
        let categories = allCategories.map {
            FitNotesBackupCategory(name: $0.name, colour: $0.colour)
        }

        let exercises = allExercises.map {
            FitNotesBackupExercise(
                name: $0.name,
                categoryName: $0.category?.name,
                usesReps: $0.uses_reps,
                usesWeight: $0.uses_weight,
                weightUnit: $0.weight_unit,
                weightIncrement: $0.weight_increment,
                usesDistance: $0.uses_distance,
                distanceUnit: $0.distance_unit,
                distanceIncrement: $0.distance_increment,
                usesTime: $0.uses_time,
                timeUnit: $0.time_unit,
                timeIncrement: $0.time_increment,
                notes: $0.notes,
                restTimeSecond: $0.rest_time_second,
                restAlertMode: $0.rest_alert_mode
            )
        }

        let groups = allGroups
            .sorted { lhs, rhs in
                if lhs.date != rhs.date { return lhs.date < rhs.date }
                return lhs.dayGroupId < rhs.dayGroupId
            }
            .map { group in
                FitNotesBackupWorkoutGroup(
                    dayGroupId: group.dayGroupId,
                    date: group.date,
                    exerciseName: group.exercise?.name,
                    notes: group.notes,
                    sets: group.entries
                        .sorted { $0.id < $1.id }
                        .map {
                            FitNotesBackupWorkoutSet(
                                id: $0.id,
                                reps: $0.reps,
                                weightKilograms: $0.weightKilograms,
                                distanceMeters: $0.distanceMeters,
                                timeSeconds: $0.timeSeconds,
                                isPersonalRecord: $0.is_personal_record,
                                isComplete: $0.is_complete
                            )
                        }
                )
            }

        let templates = allTemplates
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { template in
                FitNotesBackupTemplate(
                    name: template.name,
                    createdAt: template.createdAt,
                    items: template.items
                        .sorted { $0.orderIndex < $1.orderIndex }
                        .map { item in
                            FitNotesBackupTemplateItem(
                                orderIndex: item.orderIndex,
                                exerciseName: item.exercise?.name,
                                sets: item.sets
                                    .sorted { $0.id < $1.id }
                                    .map {
                                        FitNotesBackupTemplateSet(
                                            id: $0.id,
                                            reps: $0.reps,
                                            weightKilograms: $0.weightKilograms,
                                            distanceMeters: $0.distanceMeters,
                                            timeSeconds: $0.timeSeconds
                                        )
                                    }
                            )
                        }
                )
            }

        return FitNotesBackup(
            appVersion: "1",
            createdAt: Date(),
            categories: categories,
            exercises: exercises,
            workoutGroups: groups,
            templates: templates
        )
    }

    private func restoreAppBackup(_ backup: FitNotesBackup) {
        errorMsg = nil
        importFinished = false

        importedSets.removeAll()
        importedGroups.removeAll()
        importedCategories.removeAll()

        // Full restore: replace current app data with backup content.
        for template in allTemplates { modelContext.delete(template) }
        for group in allGroups { modelContext.delete(group) }
        for exercise in allExercises { modelContext.delete(exercise) }
        for category in allCategories { modelContext.delete(category) }
        try? modelContext.save()

        var categoriesByName: [String: ExerciseCategory] = [:]
        for categoryDTO in backup.categories {
            let category = ExerciseCategory(name: categoryDTO.name, colour: categoryDTO.colour)
            modelContext.insert(category)
            importedCategories.append(category)
            categoriesByName[categoryDTO.name] = category
        }

        var exercisesByName: [String: Exercise] = [:]
        for exerciseDTO in backup.exercises {
            let exercise = Exercise(
                name: exerciseDTO.name,
                category: exerciseDTO.categoryName.flatMap { categoriesByName[$0] },
                uses_reps: exerciseDTO.usesReps,
                uses_weight: exerciseDTO.usesWeight,
                weight_unit: exerciseDTO.weightUnit,
                weight_increment: exerciseDTO.weightIncrement,
                uses_distance: exerciseDTO.usesDistance,
                distance_unit: exerciseDTO.distanceUnit,
                distance_increment: exerciseDTO.distanceIncrement,
                uses_time: exerciseDTO.usesTime,
                time_unit: exerciseDTO.timeUnit,
                time_increment: exerciseDTO.timeIncrement,
                notes: exerciseDTO.notes,
                rest_time_second: exerciseDTO.restTimeSecond,
                rest_alert_mode: exerciseDTO.restAlertMode
            )
            modelContext.insert(exercise)
            exercisesByName[exercise.name] = exercise
        }

        for groupDTO in backup.workoutGroups {
            let group = WorkoutGroup(dayGroupId: groupDTO.dayGroupId, date: groupDTO.date, notes: groupDTO.notes)
            group.exercise = groupDTO.exerciseName.flatMap { exercisesByName[$0] }

            for setDTO in groupDTO.sets {
                let set = WorkoutSet(
                    id: setDTO.id,
                    reps: setDTO.reps,
                    weightKilograms: setDTO.weightKilograms,
                    distanceMeters: setDTO.distanceMeters,
                    timeSeconds: setDTO.timeSeconds,
                    is_personal_record: setDTO.isPersonalRecord,
                    is_complete: setDTO.isComplete
                )
                group.entries.append(set)
                importedSets.append(set)
            }

            modelContext.insert(group)
            importedGroups.append(group)
        }

        for templateDTO in backup.templates {
            let template = WorkoutTemplate(name: templateDTO.name)
            template.createdAt = templateDTO.createdAt

            for itemDTO in templateDTO.items {
                let item = WorkoutTemplateItem(orderIndex: itemDTO.orderIndex, exercise: itemDTO.exerciseName.flatMap { exercisesByName[$0] })

                for setDTO in itemDTO.sets {
                    let set = WorkoutTemplateSet(
                        id: setDTO.id,
                        reps: setDTO.reps,
                        weightKilograms: setDTO.weightKilograms,
                        distanceMeters: setDTO.distanceMeters,
                        timeSeconds: setDTO.timeSeconds
                    )
                    item.sets.append(set)
                }

                template.items.append(item)
            }

            modelContext.insert(template)
        }

        do {
            try modelContext.save()
            importFinished = true
        } catch {
            errorMsg = "Failed to restore backup: \(error.localizedDescription)"
        }
    }

    func parseDatabase(filePath: String) {
        
        var db: OpaquePointer?
        
        guard sqlite3_open(filePath, &db) == SQLITE_OK else {
            sqlite3_close(db)
            db = nil
            errorMsg = "Unable to open backup file"
            return
        }

        defer {
            sqlite3_close(db)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Match the format of your date string
        importedSets.removeAll()
        importedGroups.removeAll()
        importedCategories.removeAll()

        struct ImportedGroupData {
            var firstLogId: Int
            var sets: [WorkoutSet]
        }

        var categoriesById: [Int32: ExerciseCategory] = [:]
        var exercisesById: [Int32: Exercise] = [:]
        var dayByKey: [String: Date] = [:]
        var groupedByDayAndExercise: [String: [Int32: ImportedGroupData]] = [:]

        func columnIndex(_ statement: OpaquePointer?, named columnName: String) -> Int32? {
            guard let statement else { return nil }
            let count = sqlite3_column_count(statement)
            for index in 0..<count {
                guard let rawName = sqlite3_column_name(statement, index) else { continue }
                let currentName = String(cString: rawName)
                if currentName.caseInsensitiveCompare(columnName) == .orderedSame {
                    return index
                }
            }
            return nil
        }

        // ============ Import categories =============
        let categoryQueryString = "SELECT _id, name, colour FROM Category ORDER BY sort_order, _id"
        var categoryQueryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, categoryQueryString, -1, &categoryQueryStatement, nil) == SQLITE_OK {
            defer { sqlite3_finalize(categoryQueryStatement) }

            while (sqlite3_step(categoryQueryStatement) == SQLITE_ROW) {
                let categoryId = sqlite3_column_int(categoryQueryStatement, 0)
                let colour = sqlite3_column_int(categoryQueryStatement, 2)
                guard let name = sqlite3_column_text(categoryQueryStatement, 1) else {
                    errorMsg = "Error reading name of category"
                    return
                }
                let category = ExerciseCategory(name: String(cString: name),
                                                colour: hexStringFromColor(rgb: Int(colour)))
                modelContext.insert(category)
                importedCategories.append(category)
                categoriesById[categoryId] = category
            }
        } else {
            errorMsg = String(cString: sqlite3_errmsg(db))
            return
        }

        // ============ Import exercises =============
        let exerciseQueryString = "SELECT _id, name, category_id FROM exercise ORDER BY _id"
        var exerciseQueryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, exerciseQueryString, -1, &exerciseQueryStatement, nil) == SQLITE_OK {
            defer { sqlite3_finalize(exerciseQueryStatement) }

            while (sqlite3_step(exerciseQueryStatement) == SQLITE_ROW) {
                let exerciseId = sqlite3_column_int(exerciseQueryStatement, 0)
                let categoryId = sqlite3_column_int(exerciseQueryStatement, 2)
                guard let exerciseName = sqlite3_column_text(exerciseQueryStatement, 1) else {
                    errorMsg = "Error reading exercise name"
                    return
                }

                let category = categoriesById[categoryId]
                let newExercise = Exercise(name: String(cString: exerciseName), category: category)
                if let category {
                    category.exercises.append(newExercise)
                } else {
                    modelContext.insert(newExercise)
                }
                exercisesById[exerciseId] = newExercise
            }
        } else {
            errorMsg = String(cString: sqlite3_errmsg(db))
            return
        }

        // ============ Import sets / preserve exercise order by log sequence =============
        let setsQueryString = "SELECT _id, exercise_id, date, metric_weight, reps, distance, duration_seconds FROM training_log ORDER BY date, _id"
        var setsQueryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, setsQueryString, -1, &setsQueryStatement, nil) == SQLITE_OK {
            defer { sqlite3_finalize(setsQueryStatement) }

            guard let idColumn = columnIndex(setsQueryStatement, named: "_id"),
                  let exerciseIdColumn = columnIndex(setsQueryStatement, named: "exercise_id"),
                  let dateColumn = columnIndex(setsQueryStatement, named: "date"),
                  let weightColumn = columnIndex(setsQueryStatement, named: "metric_weight"),
                  let repsColumn = columnIndex(setsQueryStatement, named: "reps"),
                  let distanceColumn = columnIndex(setsQueryStatement, named: "distance"),
                  let durationColumn = columnIndex(setsQueryStatement, named: "duration_seconds") else {
                errorMsg = "Unsupported training_log schema in backup file"
                return
            }

            while sqlite3_step(setsQueryStatement) == SQLITE_ROW {
                let rowId = Int(sqlite3_column_int(setsQueryStatement, idColumn))
                let exerciseId = sqlite3_column_int(setsQueryStatement, exerciseIdColumn)

                guard let dateRaw = sqlite3_column_text(setsQueryStatement, dateColumn),
                      let parsedDate = dateFormatter.date(from: String(cString: dateRaw)) else {
                    continue
                }

                guard exercisesById[exerciseId] != nil else { continue }

                let metricWeight = sqlite3_column_double(setsQueryStatement, weightColumn)
                let reps = sqlite3_column_double(setsQueryStatement, repsColumn)
                let distance = sqlite3_column_double(setsQueryStatement, distanceColumn)
                let duration = sqlite3_column_double(setsQueryStatement, durationColumn)

                let dayKey = String(cString: dateRaw)
                dayByKey[dayKey] = parsedDate

                var dayGroups = groupedByDayAndExercise[dayKey] ?? [:]
                var groupData = dayGroups[exerciseId] ?? ImportedGroupData(firstLogId: rowId, sets: [])
                groupData.firstLogId = min(groupData.firstLogId, rowId)

                let set = WorkoutSet(
                    id: groupData.sets.count + 1,
                    reps: reps,
                    weightKilograms: metricWeight,
                    distanceMeters: distance,
                    timeSeconds: duration
                )
                groupData.sets.append(set)

                dayGroups[exerciseId] = groupData
                groupedByDayAndExercise[dayKey] = dayGroups
            }
        } else {
            errorMsg = String(cString: sqlite3_errmsg(db))
            return
        }

        // Materialize WorkoutGroup with dayGroupId preserving original per-day exercise order.
        for (dayKey, exerciseGroups) in groupedByDayAndExercise {
            guard let dayDate = dayByKey[dayKey] else { continue }

            let ordered = exerciseGroups.sorted { lhs, rhs in
                lhs.value.firstLogId < rhs.value.firstLogId
            }

            for (index, pair) in ordered.enumerated() {
                let exerciseId = pair.key
                let groupData = pair.value
                guard let exercise = exercisesById[exerciseId] else { continue }

                let newGroup = WorkoutGroup(dayGroupId: index, date: dayDate)
                exercise.groups.append(newGroup)
                groupData.sets.forEach { newGroup.entries.append($0) }
                importedGroups.append(newGroup)
                importedSets.append(contentsOf: groupData.sets)
            }
        }

        try? modelContext.save()
        
        func hexStringFromColor(rgb: Int) -> String {
            let red = (rgb >> 16) & 0xFF
            let green = (rgb >> 8) & 0xFF
            let blue = rgb & 0xFF
            
            return String(format: "%02X%02X%02X", red, green, blue)
        }
        
        
        #Preview {
            @State var path = NavigationPath(["ImportFromAndroid"])
            
            return NavigationStack(path: $path) {
                EmptyView()
                    .navigationDestination(for: String.self) { dest in
                        switch dest {
                        case "ImportFromAndroid":
                            ImportFromAndroidView(path: $path)
                                .navigationBarTitleDisplayMode(.inline)
                        default:
                            Text("no view found")
                        }
                    }
            }
        }
        
    }
}
