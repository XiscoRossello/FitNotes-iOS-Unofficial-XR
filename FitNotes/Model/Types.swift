//
//  Types.swift
//  FitNotes
//
//  Created by xiscorossello on 26/12/2023.
//


protocol PickerEnum: RawRepresentable, Codable, Hashable, CaseIterable where RawValue == String {}

enum RestAlertMode: String, Codable, CaseIterable, PickerEnum {
    case soundAndVibration = "Sound + Vibration"
    case soundOnly = "Sound Only"
    case vibrationOnly = "Vibration Only"
    case silent = "Silent"

    var includesSound: Bool {
        switch self {
        case .soundAndVibration, .soundOnly:
            return true
        case .vibrationOnly, .silent:
            return false
        }
    }

    var includesVibration: Bool {
        switch self {
        case .soundAndVibration, .vibrationOnly:
            return true
        case .soundOnly, .silent:
            return false
        }
    }
}


enum WeightUnit: String, Codable, CaseIterable, PickerEnum {
    case `default` = "Default"
    case kg = "KG"
    case lb = "Lb"
    
    private static let stringValues: [WeightUnit: String] = [
        .default: "Default",
        .kg: "KG",
        .lb: "Lb"
    ]
    
    init?(rawValue: String) {
        guard let unit = WeightUnit.allCases.first(where: { Self.stringValues[$0] == rawValue }) else {
            return nil
        }
        self = unit
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Self.stringValues[self]!)
    }
    
    func toMetric(weight: Double, defaultUnit: WeightUnitSetting) -> Double {
        switch (self) {
        case WeightUnit.kg:
            return weight
        case WeightUnit.lb:
            return weight * 0.453592
        default:
            return defaultUnit == WeightUnitSetting.kg ? weight : weight * 0.453592
        }
    }
    
    func fromMetric(weight: Double, defaultUnit: WeightUnitSetting) -> Double {
        switch (self) {
        case WeightUnit.kg:
            return weight
        case WeightUnit.lb:
            return weight / 0.453592
        default:
            return defaultUnit == WeightUnitSetting.kg ? weight : weight / 0.453592
        }
    }
    
    func resolve(defaultUnit: WeightUnitSetting) -> String {
        switch (self) {
        case WeightUnit.default:
            switch defaultUnit {
            case WeightUnitSetting.kg:
                return "Kg"
            case WeightUnitSetting.lb:
                return "Lb"
                
            }
        default:
            return self.rawValue
        }
    }
    
}

enum DistanceUnit: String, Codable, CaseIterable, PickerEnum {
    case `default` = "Default"
    case miles = "Miles"
    case kilometers = "Km"
    case meters = "Metres"
    
    private static let stringValues: [DistanceUnit: String] = [
        .default: "Default",
        .miles: "Miles",
        .kilometers: "Km",
        .meters: "Metres"
    ]
    
    init?(rawValue: String) {
        guard let unit = DistanceUnit.allCases.first(where: { Self.stringValues[$0] == rawValue }) else {
            return nil
        }
        self = unit
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Self.stringValues[self]!)
    }
    
    func toMetric(distance: Double, defaultUnit: DistanceUnitSetting) -> Double {
        switch (self) {
        case DistanceUnit.kilometers:
            return distance * 1000
        case DistanceUnit.miles:
            return distance * 1609.34
        case DistanceUnit.meters:
            return distance
        default:
            switch (defaultUnit) {
            case DistanceUnitSetting.meters:
                return distance
            case DistanceUnitSetting.kilometers:
                return distance / 1000
            case DistanceUnitSetting.miles:
                return distance / 1609.34
            }
        }
    }
    
    func fromMetric(distance: Double, defaultUnit: DistanceUnitSetting) -> Double {
        switch (self) {
        case DistanceUnit.kilometers:
            return distance / 1000
        case DistanceUnit.miles:
            return distance / 1609.34
        case DistanceUnit.meters:
            return distance
        default:
            switch (defaultUnit) {
            case DistanceUnitSetting.meters:
                return distance
            case DistanceUnitSetting.kilometers:
                return distance * 1000
            case DistanceUnitSetting.miles:
                return distance * 1609.34
            }
        }
    }
    
    func resolve(defaultUnit: DistanceUnitSetting) -> String {
        switch (self) {
        case DistanceUnit.default:
            switch(defaultUnit) {
            case DistanceUnitSetting.kilometers:
                return "Km"
            case DistanceUnitSetting.miles:
                return "Mi"
            case DistanceUnitSetting.meters:
                return "m"
            }
        default:
            return self.rawValue
            
        }
    }
    
}

enum TimeUnit: String, Codable, CaseIterable, PickerEnum {
    case `default` = "Default"
    case seconds = "Sec"
    case minutes = "Min"
    
    private static let stringValues: [TimeUnit: String] = [
        .default: "Default",
        .seconds: "Sec",
        .minutes: "Min"
    ]
    
    init?(rawValue: String) {
        guard let unit = TimeUnit.allCases.first(where: { Self.stringValues[$0] == rawValue }) else {
            return nil
        }
        self = unit
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Self.stringValues[self]!)
    }
    
    
    func toMetric(time: Double, defaultUnit: TimeUnitSetting) -> Double {
        switch (self) {
        case TimeUnit.seconds:
            return time
        case TimeUnit.minutes:
            return time / 60
        default:
            return defaultUnit == TimeUnitSetting.seconds ? time : time / 60
        }
    }
    
    func fromMetric(time: Double, defaultUnit: TimeUnitSetting) -> Double {
        switch (self) {
        case TimeUnit.seconds:
            return time
        case TimeUnit.minutes:
            return time * 60
        default:
            return defaultUnit == TimeUnitSetting.seconds ? time : time * 60
        }
    }
    
    func resolve(defaultUnit: TimeUnitSetting) -> String {
        switch (self) {
        case TimeUnit.default:
            switch (defaultUnit) {
            case TimeUnitSetting.seconds:
                return "Sec"
            case TimeUnitSetting.minutes:
                return "Min"
            }
        default:
            return self.rawValue
            
        }
    }
    
    
}
