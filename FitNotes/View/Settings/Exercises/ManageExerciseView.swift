//
//  ManageExerciseView.swift
//  FitNotes
//
//  Created by xiscorossello on 22/03/2024.
//

import SwiftUI
import SwiftData

struct ManageExerciseView: View {
    
    @State var searchText = ""
    @State private var selectedCategories: Set<ExerciseCategory> = []
    
    @Query var exercises: [Exercise]
    
    private var filteredExercises: [Exercise] {
        exercises
            .filter { exercise in
                let matchesCategory = selectedCategories.isEmpty || (exercise.category.map { selectedCategories.contains($0) } ?? false)
                let matchesSearch = searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)
                return matchesCategory && matchesSearch
            }
            .sorted { lhs, rhs in
                let lhsCategory = lhs.category?.name ?? ""
                let rhsCategory = rhs.category?.name ?? ""
                if lhsCategory != rhsCategory {
                    return lhsCategory.localizedCaseInsensitiveCompare(rhsCategory) == .orderedAscending
                }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }

    private var groupedExercises: [(category: String, items: [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.category?.name ?? "Uncategorized" }
        return grouped
            .map { (category: $0.key, items: $0.value) }
            .sorted { $0.category.localizedCaseInsensitiveCompare($1.category) == .orderedAscending }
    }
    
    var body: some View {
        List {
            ForEach(groupedExercises, id: \.category) { group in
                Section(group.category) {
                    ForEach(group.items) { exercise in
                        NavigationLink(destination: AddEditExerciseView(exercise: exercise), label: {
                            HStack {
                                Circle()
                                    .fill(Color.init(hex: exercise.category?.colour ?? "FFFFFF"))
                                    .frame(width: 10, height: 10)
                                Text(exercise.name)
                            }
                        })
                    }
                }
            }
        }
        .navigationTitle("Manage Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar() {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AddEditExerciseView()) {
                    Text("Add")
                }
            }
        }
        
    }
}

#Preview {
    @State var navPath = NavigationPath()
    
    return NavigationStack {
        ManageExerciseView()
            .modelContainer(previewContainer)
    }
}
