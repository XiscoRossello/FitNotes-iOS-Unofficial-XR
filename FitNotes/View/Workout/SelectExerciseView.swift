//
//  SelectExercise.swift
//  FitNotes
//
//  Created by xiscorossello on 26/12/2023.
//

import SwiftUI
import SwiftData

struct SelectExercise: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Binding var path: NavigationPath
    var date: Date
    
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    @Query(sort: \ExerciseCategory.name) var categories: [ExerciseCategory]

    @State var searchText = ""
    @State private var selectedCategory: ExerciseCategory?
    
    var categoryResults: [ExerciseCategory] {
        if searchText.isEmpty {
            return categories
        }

        return categories.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var exerciseResults: [Exercise] {
        guard let selectedCategory else { return [] }

        let scoped = exercises.filter { $0.category?.persistentModelID == selectedCategory.persistentModelID }
        if searchText.isEmpty {
            return scoped
        }

        return scoped.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @Query var queriedGroups: [WorkoutGroup]
    var numGroupsInDay: Int {
        queriedGroups.filter({ Calendar.current.compare($0.date, to: date, toGranularity: .day) == .orderedSame }).count
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
                    .foregroundStyle(.primary)
                }
            } else {
                ForEach(exerciseResults) { exercise in
                    Button {
                        let newGroup = WorkoutGroup(dayGroupId: numGroupsInDay, date: date)
                        exercise.groups.append(newGroup)
                        try! modelContext.save()
                        path = NavigationPath([newGroup])
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: selectedCategory?.colour ?? "FFFFFF"))
                                .frame(width: 10, height: 10)
                            Text(exercise.name)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                Section {
                    NavigationLink {
                        AddEditExerciseView(initialCategory: selectedCategory)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Create Exercise")
                                .bold()
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: selectedCategory == nil ? "Search category" : "Search exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedCategory?.name ?? "Select Category")
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
        }
    }
    
}

#Preview {
    @State var navPath = NavigationPath()
    
    return NavigationStack {
        SelectExercise(path: $navPath, date: .now)
            .modelContainer(previewContainer)
    }
}
