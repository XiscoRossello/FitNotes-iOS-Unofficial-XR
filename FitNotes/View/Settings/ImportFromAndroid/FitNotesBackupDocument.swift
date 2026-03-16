//
//  FitNotesBackupDocument.swift
//  FitNotes
//
//  Created by xiscorossello on 16/03/2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct FitNotesBackup: Codable {
    let appVersion: String
    let createdAt: Date
    let categories: [FitNotesBackupCategory]
    let exercises: [FitNotesBackupExercise]
    let workoutGroups: [FitNotesBackupWorkoutGroup]
    let templates: [FitNotesBackupTemplate]
}

struct FitNotesBackupCategory: Codable {
    let name: String
    let colour: String
}

struct FitNotesBackupExercise: Codable {
    let name: String
    let categoryName: String?
    let usesReps: Bool
    let usesWeight: Bool
    let weightUnit: WeightUnit
    let weightIncrement: Double?
    let usesDistance: Bool
    let distanceUnit: DistanceUnit
    let distanceIncrement: Double?
    let usesTime: Bool
    let timeUnit: TimeUnit
    let timeIncrement: Double?
    let notes: String
    let restTimeSecond: Int?
    let restAlertMode: RestAlertMode
}

struct FitNotesBackupWorkoutGroup: Codable {
    let dayGroupId: Int
    let date: Date
    let exerciseName: String?
    let notes: String?
    let sets: [FitNotesBackupWorkoutSet]
}

struct FitNotesBackupWorkoutSet: Codable {
    let id: Int
    let reps: Double
    let weightKilograms: Double
    let distanceMeters: Double
    let timeSeconds: Double
    let isPersonalRecord: Bool
    let isComplete: Bool?
}

struct FitNotesBackupTemplate: Codable {
    let name: String
    let createdAt: Date
    let items: [FitNotesBackupTemplateItem]
}

struct FitNotesBackupTemplateItem: Codable {
    let orderIndex: Int
    let exerciseName: String?
    let sets: [FitNotesBackupTemplateSet]
}

struct FitNotesBackupTemplateSet: Codable {
    let id: Int
    let reps: Double
    let weightKilograms: Double
    let distanceMeters: Double
    let timeSeconds: Double
}

struct FitNotesBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var backup: FitNotesBackup

    init(backup: FitNotesBackup) {
        self.backup = backup
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        backup = try decoder.decode(FitNotesBackup.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(backup)
        return .init(regularFileWithContents: data)
    }
}
