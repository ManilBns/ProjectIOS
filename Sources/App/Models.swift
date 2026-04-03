// Models.swift
// SecureHome — Système de surveillance de sécurité domestique
// Manil BENMOUSSA — Yasmine Merad

import Foundation

// MARK: - AlertStatus
/// Represents the three alert levels from the Arduino system
enum AlertStatus: String, Codable, Sendable, CaseIterable {
    case ok      = "OK"
    case warning = "WARNING"
    case stop    = "STOP"

    /// Human-readable label for display
    var label: String {
        switch self {
        case .ok:      return "✅ Normal"
        case .warning: return "⚠️ Warning"
        case .stop:    return "🚨 STOP"
        }
    }

    /// CSS class for color styling
    var cssClass: String {
        switch self {
        case .ok:      return "ok"
        case .warning: return "warning"
        case .stop:    return "stop"
        }
    }
}

// MARK: - EventType
/// Type of sensor that triggered the event
enum EventType: String, Codable, Sendable, CaseIterable {
    case distance    = "distance"
    case temperature = "temperature"
    case gas         = "gas"
    case motion      = "motion"
    case manual      = "manual"

    var label: String {
        switch self {
        case .distance:    return "📡 Distance"
        case .temperature: return "🌡️ Température"
        case .gas:         return "☠️ Gaz"
        case .motion:      return "👁️ Mouvement"
        case .manual:      return "✏️ Manuel"
        }
    }
}

// MARK: - SecurityEvent
/// Main data model representing a security event logged by the Arduino system.
/// Conforms to Codable for JSON serialization and Sendable for concurrency safety.
struct SecurityEvent: Codable, Sendable {
    // MARK: Fields (6 minimum required)
    let id: Int                   // Primary key — auto-incremented by SQLite
    var type: String              // Sensor type (EventType raw value)
    var distance: Double          // Distance in centimeters (0 if N/A)
    var temperature: Double       // Temperature in Celsius (0 if N/A)
    var status: String            // Alert status (AlertStatus raw value)
    var notes: String             // Optional operator notes
    var timestamp: String         // ISO 8601 datetime string

    // MARK: - Computed helpers

    /// Returns the typed AlertStatus from the raw string
    var alertStatus: AlertStatus {
        AlertStatus(rawValue: status) ?? .ok
    }

    /// Returns the typed EventType from the raw string
    var eventType: EventType {
        EventType(rawValue: type) ?? .manual
    }

    /// Formatted distance string
    var distanceFormatted: String {
        distance > 0 ? String(format: "%.1f cm", distance) : "N/A"
    }

    /// Formatted temperature string
    var temperatureFormatted: String {
        temperature != 0 ? String(format: "%.1f °C", temperature) : "N/A"
    }
}

// MARK: - CreateEventForm
/// Represents the HTML form data for creating or updating a SecurityEvent.
/// Used to decode multipart/urlencoded form submissions.
struct CreateEventForm: Codable, Sendable {
    var type: String
    var distance: String
    var temperature: String
    var status: String
    var notes: String
}

// MARK: - Extension: Validation
extension CreateEventForm {
    /// Validates form fields and returns error message if invalid
    func validate() -> String? {
        if type.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Le type d'événement est requis."
        }
        if AlertStatus(rawValue: status) == nil {
            return "Le statut sélectionné est invalide."
        }
        if let d = Double(distance), d < 0 {
            return "La distance ne peut pas être négative."
        }
        if let t = Double(temperature), t < -50 || t > 150 {
            return "La température doit être entre -50 et 150 °C."
        }
        return nil // nil = valid
    }

    /// Safely parsed distance, defaults to 0
    var parsedDistance: Double { Double(distance) ?? 0 }

    /// Safely parsed temperature, defaults to 0
    var parsedTemperature: Double { Double(temperature) ?? 0 }
}