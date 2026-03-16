//
//  SwiftUIView.swift
//  FitNotes
//
//  Created by xiscorossello on 22/12/2023.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var restTimerManager: RestTimerManager

    @Binding var date: Date
    
    @State private var isCalendarPresented = false
    @State private var isCopyWorkoutPresented = false
    @State private var isSaveTemplatePresented = false
    @State private var isApplyTemplatePresented = false
    @State private var groupToReplace: WorkoutGroup?

    @Query(sort: [SortDescriptor(\WorkoutGroup.date), SortDescriptor(\WorkoutGroup.dayGroupId)])
    private var queriedGroups: [WorkoutGroup]
    @Query(sort: [SortDescriptor(\WorkoutTemplate.createdAt, order: .reverse), SortDescriptor(\WorkoutTemplate.name)])
    private var templates: [WorkoutTemplate]

    private func dayKey(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    private var dayCategoryColorHexes: [String: [String]] {
        var map: [String: [String]] = [:]
        for group in queriedGroups {
            let day = dayKey(group.date)
            guard let hex = group.exercise?.category?.colour else { continue }
            if map[day] == nil {
                map[day] = []
            }
            if !(map[day]?.contains(hex) ?? false) {
                map[day]?.append(hex)
            }
        }
        return map
    }

    private var categoriesInDay: [ExerciseCategory] {
        let dayGroups = queriedGroups.filter {
            Calendar.current.compare($0.date, to: date, toGranularity: .day) == .orderedSame
        }

        var seen = Set<String>()
        var result: [ExerciseCategory] = []
        for group in dayGroups {
            guard let category = group.exercise?.category else { continue }
            if seen.insert(category.name).inserted {
                result.append(category)
            }
        }
        return result
    }
    
    //    @AppStorage("initialized") var initialized: Bool = false
    
    var body: some View {
        VStack {
            if restTimerManager.isRunning {
                HStack(spacing: 10) {
                    Image(systemName: "timer")
                    Text("\(restTimerManager.exerciseName): \(restTimerManager.formattedTime)")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Button("Stop") {
                        restTimerManager.stop()
                    }
                    .font(.caption)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 6)
            }
            
            if (isCalendarPresented) {
                WorkoutMonthCalendarView(
                    selectedDate: $date,
                    dayCategoryColorHexes: dayCategoryColorHexes,
                    maxDate: nil
                )
            }
            
            // Date left/right
            HStack {
                Button(action: {
                    date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? .now
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(dateFormatter.string(from: date))
                    .onTapGesture {
                        date = .now
                    }
                Spacer()
                Button(action: {
                    date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? .now
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            if !categoriesInDay.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categoriesInDay, id: \.name) { category in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: category.colour))
                                    .frame(width: 8, height: 8)
                                Text(category.name)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
                        }
                    }
                    .padding(.horizontal)
                }
            }

            ScrollView {
                ExerciseGroupListView(
                    date: date,
                    onDeleteGroup: deleteGroup,
                    onReplaceGroup: { group in
                        groupToReplace = group
                    }
                )
                Spacer()
            }
            Spacer()
            
            // Track exercise button
            NavigationLink(value: "SelectExercise", label: {
                HStack {
                    Text("Track Exercise").foregroundStyle(Color.white)
                    Image(systemName: "plus").foregroundStyle(Color.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            })
        }
        .navigationBarTitle("Workout", displayMode: .inline)
        .navigationBarItems(
            leading: NavigationLink(value: "Settings")  {
                Image(systemName: "gear")
            },
            trailing: HStack(spacing: 14) {
                Button(action: {
                    isCalendarPresented.toggle()
                }) {
                    Image(systemName: "calendar")
                }

                Menu {
                    Button {
                        isCopyWorkoutPresented = true
                    } label: {
                        Label("Add from previous day", systemImage: "calendar.badge.plus")
                    }

                    Button {
                        isApplyTemplatePresented = true
                    } label: {
                        Label("Add from template", systemImage: "list.bullet.rectangle")
                    }

                    Button {
                        isSaveTemplatePresented = true
                    } label: {
                        Label("Save day as template", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        )
        .sheet(isPresented: $isCopyWorkoutPresented) {
            NavigationStack {
                CopyWorkoutFromPreviousDayView(targetDate: date)
            }
        }
        .sheet(isPresented: $isSaveTemplatePresented) {
            NavigationStack {
                SaveWorkoutTemplateView(targetDate: date)
            }
        }
        .sheet(isPresented: $isApplyTemplatePresented) {
            NavigationStack {
                ApplyWorkoutTemplateView(targetDate: date, templates: templates)
            }
        }
        .sheet(item: $groupToReplace) { group in
            NavigationStack {
                ReplaceExercisePickerView { replacement in
                    group.exercise = replacement
                    try? modelContext.save()
                    groupToReplace = nil
                }
            }
        }
    }

    private func deleteGroup(_ group: WorkoutGroup) {
        let sameDayGroups = queriedGroups
            .filter { Calendar.current.compare($0.date, to: group.date, toGranularity: .day) == .orderedSame }
            .sorted { $0.dayGroupId < $1.dayGroupId }

        // Delete child sets explicitly before deleting the group to avoid invalid relationship state.
        for entry in group.entries {
            modelContext.delete(entry)
        }

        modelContext.delete(group)

        var nextId = 0
        for dayGroup in sameDayGroups where dayGroup.persistentModelID != group.persistentModelID {
            dayGroup.dayGroupId = nextId
            nextId += 1
        }

        try? modelContext.save()
    }
}


private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE d MMM YYYY"
    return formatter
}


func compareDatesIgnoringTime(date1: Date, date2: Date) -> ComparisonResult {
    let calendar = Calendar.current
    
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    
    guard let newDate1 = calendar.date(from: components1),
          let newDate2 = calendar.date(from: components2) else {
        return .orderedSame
    }
    
    return newDate1.compare(newDate2)
}

struct CopyWorkoutFromPreviousDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var targetDate: Date

    @Query(sort: [SortDescriptor(\WorkoutGroup.date), SortDescriptor(\WorkoutGroup.dayGroupId)])
    private var queriedGroups: [WorkoutGroup]

    @State private var sourceDate: Date = .now

    private func dayKey(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    private var availableDates: [Date] {
        var uniqueDates: [Date] = []
        var seen = Set<Date>()
        let calendar = Calendar.current

        for group in queriedGroups {
            guard calendar.compare(group.date, to: targetDate, toGranularity: .day) == .orderedAscending else { continue }
            let dayStart = calendar.startOfDay(for: group.date)
            if seen.insert(dayStart).inserted {
                uniqueDates.append(dayStart)
            }
        }

        return uniqueDates.sorted(by: >)
    }

    private var dayCategoryColorHexes: [String: [String]] {
        var map: [String: [String]] = [:]
        for group in queriedGroups {
            guard Calendar.current.compare(group.date, to: targetDate, toGranularity: .day) == .orderedAscending else { continue }
            let day = dayKey(group.date)
            guard let hex = group.exercise?.category?.colour else { continue }
            if map[day] == nil {
                map[day] = []
            }
            if !(map[day]?.contains(hex) ?? false) {
                map[day]?.append(hex)
            }
        }
        return map
    }

    private var sourceGroups: [WorkoutGroup] {
        queriedGroups
            .filter { Calendar.current.compare($0.date, to: sourceDate, toGranularity: .day) == .orderedSame }
            .sorted { $0.dayGroupId < $1.dayGroupId }
    }

    init(targetDate: Date) {
        self.targetDate = targetDate
        let defaultSource = Calendar.current.date(byAdding: .day, value: -1, to: targetDate) ?? targetDate
        _sourceDate = State(initialValue: defaultSource)
    }

    var body: some View {
        VStack(spacing: 12) {
            if availableDates.isEmpty {
                ContentUnavailableView(
                    "No previous workouts",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Create workouts in earlier dates first.")
                )
            } else {
                WorkoutMonthCalendarView(
                    selectedDate: $sourceDate,
                    dayCategoryColorHexes: dayCategoryColorHexes,
                    maxDate: Calendar.current.date(byAdding: .day, value: -1, to: targetDate)
                )
                .padding(.horizontal)
                .onChange(of: sourceDate) { _, newDate in
                    sourceDate = closestAvailableDate(to: newDate)
                }
                .onAppear {
                    sourceDate = closestAvailableDate(to: sourceDate)
                }

                List(sourceGroups) { group in
                    HStack {
                        Circle()
                            .fill(Color(hex: group.exercise?.category?.colour ?? "FFFFFF"))
                            .frame(width: 10, height: 10)
                        Text(group.exercise?.name ?? "Unknown exercise")
                        Spacer()
                        Text("\(group.entries.count) sets")
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    copyWorkout()
                    dismiss()
                } label: {
                    Text("Copy Workout")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(sourceGroups.isEmpty)
            }
        }
        .navigationTitle("Add from Previous Day")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
        }
    }

    private func closestAvailableDate(to date: Date) -> Date {
        guard !availableDates.isEmpty else { return date }
        let start = Calendar.current.startOfDay(for: date)
        if availableDates.contains(start) {
            return start
        }
        return availableDates.first ?? start
    }

    private func copyWorkout() {
        let existingTargetGroups = queriedGroups.filter {
            Calendar.current.compare($0.date, to: targetDate, toGranularity: .day) == .orderedSame
        }

        var nextGroupId = (existingTargetGroups.map(\.dayGroupId).max() ?? -1) + 1

        for sourceGroup in sourceGroups {
            let newGroup = WorkoutGroup(dayGroupId: nextGroupId, date: targetDate)
            newGroup.exercise = sourceGroup.exercise

            for sourceSet in sourceGroup.entries.sorted(by: { $0.id < $1.id }) {
                let copiedSet = WorkoutSet(
                    id: sourceSet.id,
                    reps: sourceSet.reps,
                    weightKilograms: sourceSet.weightKilograms,
                    distanceMeters: sourceSet.distanceMeters,
                    timeSeconds: sourceSet.timeSeconds,
                    is_personal_record: sourceSet.is_personal_record,
                    is_complete: sourceSet.is_complete
                )
                newGroup.entries.append(copiedSet)
            }

            modelContext.insert(newGroup)
            nextGroupId += 1
        }

        try? modelContext.save()
    }
}

struct WorkoutMonthCalendarView: View {
    @Binding var selectedDate: Date
    let dayCategoryColorHexes: [String: [String]]
    let maxDate: Date?

    @State private var displayedMonth: Date

    private let calendar = Calendar.current

    init(selectedDate: Binding<Date>, dayCategoryColorHexes: [String: [String]], maxDate: Date?) {
        _selectedDate = selectedDate
        self.dayCategoryColorHexes = dayCategoryColorHexes
        self.maxDate = maxDate
        _displayedMonth = State(initialValue: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate.wrappedValue)) ?? selectedDate.wrappedValue)
    }

    private func dayKey(_ date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    private var monthDays: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstDay = interval.start
        let dayCount = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7

        var values: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in 0..<dayCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                values.append(date)
            }
        }
        return values
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)

                Spacer()

                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                } label: {
                    Image(systemName: "chevron.right")
                }
            }

            let weekdaySymbols = calendar.shortStandaloneWeekdaySymbols
            let startIndex = max(0, calendar.firstWeekday - 1)
            let reorderedSymbols = (0..<weekdaySymbols.count).map { offset in
                weekdaySymbols[(startIndex + offset) % weekdaySymbols.count]
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(reorderedSymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let dayStart = calendar.startOfDay(for: date)
                        let key = dayKey(dayStart)
                        let isSelected = calendar.isDate(dayStart, inSameDayAs: selectedDate)
                        let dotHexes = dayCategoryColorHexes[key] ?? []
                        let isAllowed = maxDate.map { dayStart <= Calendar.current.startOfDay(for: $0) } ?? true

                        Button {
                            guard isAllowed else { return }
                            selectedDate = dayStart
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: dayStart))")
                                    .frame(maxWidth: .infinity, minHeight: 24)
                                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                                    .background(
                                        Group {
                                            if isSelected {
                                                Circle().fill(Color.green)
                                            } else {
                                                Circle().fill(Color.clear)
                                            }
                                        }
                                    )

                                HStack(spacing: 3) {
                                    ForEach(Array(dotHexes.prefix(4)), id: \.self) { hex in
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 5, height: 5)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .opacity(isAllowed ? 1 : 0.35)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isAllowed)
                    } else {
                        Color.clear
                            .frame(height: 34)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ReplaceExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Query(sort: \ExerciseCategory.name) private var categories: [ExerciseCategory]

    @State private var selectedCategory: ExerciseCategory?
    @State private var searchText = ""

    let onSelect: (Exercise) -> Void

    private var categoryResults: [ExerciseCategory] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var exerciseResults: [Exercise] {
        guard let selectedCategory else { return [] }
        let scoped = exercises.filter { $0.category?.persistentModelID == selectedCategory.persistentModelID }
        if searchText.isEmpty {
            return scoped
        }
        return scoped.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            if selectedCategory == nil {
                ForEach(categoryResults) { category in
                    Button {
                        selectedCategory = category
                        searchText = ""
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: category.colour))
                                .frame(width: 10, height: 10)
                            Text(category.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                ForEach(exerciseResults) { exercise in
                    Button {
                        onSelect(exercise)
                        dismiss()
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: selectedCategory?.colour ?? "FFFFFF"))
                                .frame(width: 10, height: 10)
                            Text(exercise.name)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: selectedCategory == nil ? "Search category" : "Search exercise")
        .navigationTitle(selectedCategory?.name ?? "Replace Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if selectedCategory != nil {
                    Button {
                        selectedCategory = nil
                        searchText = ""
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                            Text("Categories")
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") { dismiss() }
            }
        }
    }
}

struct SaveWorkoutTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var targetDate: Date

    @Query(sort: [SortDescriptor(\WorkoutGroup.date), SortDescriptor(\WorkoutGroup.dayGroupId)])
    private var queriedGroups: [WorkoutGroup]
    @Query(sort: \WorkoutTemplate.name)
    private var templates: [WorkoutTemplate]

    @State private var templateName = ""

    private var groupsForDate: [WorkoutGroup] {
        queriedGroups
            .filter { Calendar.current.compare($0.date, to: targetDate, toGranularity: .day) == .orderedSame }
            .sorted { $0.dayGroupId < $1.dayGroupId }
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Template name", text: $templateName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if groupsForDate.isEmpty {
                ContentUnavailableView("No workout to save", systemImage: "square.stack", description: Text("Add exercises to this day before creating a template."))
            } else {
                List(groupsForDate) { group in
                    HStack {
                        Circle()
                            .fill(Color(hex: group.exercise?.category?.colour ?? "FFFFFF"))
                            .frame(width: 10, height: 10)
                        Text(group.exercise?.name ?? "Unknown exercise")
                        Spacer()
                        Text("\(group.entries.count) sets")
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    saveTemplate()
                    dismiss()
                } label: {
                    Text("Save Template")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Save Template")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
        }
    }

    private func saveTemplate() {
        let normalizedName = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else { return }

        if let existing = templates.first(where: { $0.name.localizedCaseInsensitiveCompare(normalizedName) == .orderedSame }) {
            modelContext.delete(existing)
        }

        let template = WorkoutTemplate(name: normalizedName)

        for (index, group) in groupsForDate.enumerated() {
            let item = WorkoutTemplateItem(orderIndex: index, exercise: group.exercise)

            for set in group.entries.sorted(by: { $0.id < $1.id }) {
                let templateSet = WorkoutTemplateSet(
                    id: set.id,
                    reps: set.reps,
                    weightKilograms: set.weightKilograms,
                    distanceMeters: set.distanceMeters,
                    timeSeconds: set.timeSeconds
                )
                item.sets.append(templateSet)
            }

            template.items.append(item)
        }

        modelContext.insert(template)
        try? modelContext.save()
    }
}

struct ApplyWorkoutTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var targetDate: Date
    var templates: [WorkoutTemplate]

    @Query(sort: [SortDescriptor(\WorkoutGroup.date), SortDescriptor(\WorkoutGroup.dayGroupId)])
    private var queriedGroups: [WorkoutGroup]

    @State private var selectedTemplate: WorkoutTemplate?

    var body: some View {
        VStack(spacing: 12) {
            List(templates, selection: $selectedTemplate) { template in
                HStack {
                    Text(template.name)
                    Spacer()
                    Text("\(template.items.count) exercises")
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTemplate = template
                }
            }

            Button {
                applyTemplate()
                dismiss()
            } label: {
                Text("Apply Template")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(selectedTemplate == nil)
        }
        .navigationTitle("Add from Template")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
        }
    }

    private func applyTemplate() {
        guard let selectedTemplate else { return }

        let existingTargetGroups = queriedGroups.filter {
            Calendar.current.compare($0.date, to: targetDate, toGranularity: .day) == .orderedSame
        }
        var nextGroupId = (existingTargetGroups.map(\.dayGroupId).max() ?? -1) + 1

        for item in selectedTemplate.items.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let newGroup = WorkoutGroup(dayGroupId: nextGroupId, date: targetDate)
            newGroup.exercise = item.exercise

            for templateSet in item.sets.sorted(by: { $0.id < $1.id }) {
                let set = WorkoutSet(
                    id: templateSet.id,
                    reps: templateSet.reps,
                    weightKilograms: templateSet.weightKilograms,
                    distanceMeters: templateSet.distanceMeters,
                    timeSeconds: templateSet.timeSeconds,
                    is_personal_record: false
                )
                newGroup.entries.append(set)
            }

            modelContext.insert(newGroup)
            nextGroupId += 1
        }

        try? modelContext.save()
    }
}
