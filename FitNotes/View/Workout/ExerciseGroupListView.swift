//
//  ExerciseGroupListView.swift
//  FitNotes
//
//  Created by xiscorossello on 06/01/2024.
//

import SwiftUI
import SwiftData

struct ExerciseGroupListView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var date: Date
    var onDeleteGroup: ((WorkoutGroup) -> Void)? = nil
    var onReplaceGroup: ((WorkoutGroup) -> Void)? = nil
    
    @Query(sort: \WorkoutGroup.dayGroupId) var queriedGroups: [WorkoutGroup]
    
    var groups: [WorkoutGroup] {
        queriedGroups.filter({ Calendar.current.compare($0.date, to: date, toGranularity: .day) == .orderedSame })
    }
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            ForEach(groups) { group in
                
                
                var sets: [WorkoutSet] {
                    group.entries.filter({ $0.group == group}).sorted { $0.id < $1.id }
                }
                
                
                NavigationLink(value: group) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(hex: group.exercise?.category?.colour ?? "FFFFFF"))
                            .frame(width: 6)

                        VStack(spacing: 8) {
                            Text(group.exercise?.name ?? "Unkown exercise!")
                                .bold()
                                .padding(.top, 6)

                            if (colorScheme == .dark) {
                                Divider()
                                    .colorInvert()
                            } else {
                                Divider()
                            }

                            VStack {
                                ForEach(sets) { set in
                                    MetricsRow(set: set)
                                        .padding(8)
                                }
                                Spacer()
                            }.padding(.vertical, 4)
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.3), radius: 4)
                }
                .padding(.horizontal, 30)
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    Button {
                        onReplaceGroup?(group)
                    } label: {
                        Label("Replace exercise", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Button(role: .destructive) {
                        onDeleteGroup?(group)
                    } label: {
                        Label("Delete exercise and sets", systemImage: "trash")
                    }
                }
                //                .draggable(group.persistentModelID) {
                //                    RoundedRectangle(cornerRadius: 10)
                //                        .frame(width: 100, height: 20)
                //                        .background(.green.opacity(0.2))
                //                        .onAppear {
                //                            draggedGroupId = group.dayGroupId
                //                        }
                //                }
                //                .dropDestination(for: PersistentIdentifier.self) { _, _ in
                //                    return false
                //                } isTargeted: { isTargeted in
                //                    if let draggedGroupId, isTargeted, draggedGroupId != group.dayGroupId {
                //                        if let sourceIdx = groupDayIds.firstIndex(of: draggedGroupId),
                //                            let destinationIdx = groupDayIds.firstIndex(of: group.dayGroupId) {
                //                            let sourceItem = groupDayIds.remove(at: sourceIdx)
                //                            groupDayIds.insert(sourceItem, at: destinationIdx)
                //                        }
                //                    }
                //                }
                
            }
        }
        
    }
}

