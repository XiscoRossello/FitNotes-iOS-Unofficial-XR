//
//  SetListView.swift
//  FitNotes
//
//  Created by xiscorossello on 01/01/2024.
//

import SwiftUI

struct SetListView: View {
    
    var group: WorkoutGroup
    var sets: [WorkoutSet]
    @Binding var selectedSet: WorkoutSet?
    
    var exercise: Exercise {
        group.exercise!
    }
    
    var body: some View {
        ScrollView {
            ForEach(sets) { set in
                HStack {
                    HStack {
                        
                        // Index
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(String(set.id))
                                    .foregroundColor(.white)
                                    .bold())
                        
                        MetricsRow(set: set)

                        if set.is_personal_record {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal, 5)
                    .padding(.vertical, 4)
                    .onTapGesture {
                        if (self.selectedSet == set) {
                            self.selectedSet = nil
                        } else {
                            self.selectedSet = set
                        }
                    }
                }
                .padding(0)
                .background(set == selectedSet ? .teal.opacity(0.6) : .black.opacity(0), 
                            in: RoundedRectangle(cornerRadius: 10))
                
                
                Divider()
                    .padding(0)
                
            }
            
        }
        .padding()
        .onTapGesture {
                selectedSet = nil
            }
        
        Spacer()
    }
}

