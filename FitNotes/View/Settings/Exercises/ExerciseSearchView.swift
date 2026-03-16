//
//  ExerciseSearchView.swift
//  FitNotes
//
//  Created by xiscorossello on 29/04/2024.
//

import SwiftUI
import SwiftData

struct ExerciseSearchView: View {
    @Query(sort: \ExerciseCategory.name) var categories: [ExerciseCategory]
    
    @Binding var selectedCategories: Set<ExerciseCategory>
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(categories) { category in
                        CategoryChipView(category: category, selectedCategories: $selectedCategories)
                    }
                }
            }
            .padding(.bottom, 3)
            .padding(.top, 0)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}

struct CategoryChipView: View {
    let category: ExerciseCategory
    @Binding var selectedCategories: Set<ExerciseCategory>
    
    var isSelected: Bool {
        selectedCategories.contains(category)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: category.colour))
                .frame(width: 8, height: 8)
            
            Text(category.name)
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? .blue : Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .onTapGesture {
            if isSelected {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
    }
}

