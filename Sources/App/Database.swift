// Database.swift
// SecureHome — Couche d'accès aux données SQLite
// Toutes les interactions utilisent SQLite.swift (expressions typées, pas de SQL brut)

import SQLite
import Foundation

// MARK: - DatabaseManager
/// Manages all SQLite interactions for the SecureHome application.
/// Uses SQLite.swift typed expressions exclusively — no raw SQL strings.
actor DatabaseManager {

    // MARK: - Private Properties
    private let db: Connection

    // MARK: - Table & Columns (typed expressions)
    private let events          = Table("security_events")
    private let colId           = Expression<Int>("id")
    private let colType         = Expression<String>("type")
    private let colDistance     = Expression<Double>("distance")
    private let colTemperature  = Expression<Double>("temperature")
    private let colStatus       = Expression<String>("status")
    private let colNotes        = Expression<String>("notes")
    private let colTimestamp    = Expression<String>("timestamp")

    // MARK: - Initializer
    /// Opens (or creates) the SQLite database and sets up the schema.
    init(path: String = "securehome.db") throws {
        db = try Connection(path)
        try createTableIfNeeded()
        try seedDataIfEmpty()
    }

    // MARK: - Schema Setup
    /// Creates the security_events table if it does not already exist.
    private func createTableIfNeeded() throws {
        try db.run(events.create(ifNotExists: true) { table in
            table.column(colId, primaryKey: .autoincrement)
            table.column(colType)
            table.column(colDistance)
            table.column(colTemperature)
            table.column(colStatus)
            table.column(colNotes)
            table.column(colTimestamp)
        })
    }

    /// Seeds 5 realistic demo events on first launch so the list is not empty.
    private func seedDataIfEmpty() throws {
        let count = try db.scalar(events.count)
        guard count == 0 else { return }

        let samples: [(String, Double, Double, String, String)] = [
            ("distance",    5.0,  22.5, "STOP",    "Objet très proche détecté à 5cm — buzzer déclenché"),
            ("distance",   12.0,  21.0, "WARNING", "Zone d'alerte : objet entre 9 et 15cm"),
            ("temperature",  0.0, 41.2, "STOP",    "Température critique dépassant 40°C"),
            ("motion",      45.0, 23.0, "OK",      "Mouvement détecté à distance normale"),
            ("distance",   120.0, 24.1, "OK",      "Aucune menace — statut normal"),
        ]

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for (i, s) in samples.enumerated() {
            let date = Date().addingTimeInterval(Double(-i * 3600))
            try db.run(events.insert(
                colType        <- s.0,
                colDistance    <- s.1,
                colTemperature <- s.2,
                colStatus      <- s.3,
                colNotes       <- s.4,
                colTimestamp   <- fmt.string(from: date)
            ))
        }
    }

    // MARK: - READ
    /// Fetches all events, most recent first.
    func getAllEvents() throws -> [SecurityEvent] {
        let query = events.order(colId.desc)
        return try db.prepare(query).map { row in
            SecurityEvent(
                id:          row[colId],
                type:        row[colType],
                distance:    row[colDistance],
                temperature: row[colTemperature],
                status:      row[colStatus],
                notes:       row[colNotes],
                timestamp:   row[colTimestamp]
            )
        }
    }

    /// Fetches a single event by its primary key. Returns nil if not found.
    func getEvent(id: Int) throws -> SecurityEvent? {
        let query = events.filter(colId == id)
        return try db.prepare(query).map { row in
            SecurityEvent(
                id:          row[colId],
                type:        row[colType],
                distance:    row[colDistance],
                temperature: row[colTemperature],
                status:      row[colStatus],
                notes:       row[colNotes],
                timestamp:   row[colTimestamp]
            )
        }.first
    }

    /// Searches events by type or status using a typed WHERE clause.
    func searchEvents(query searchTerm: String) throws -> [SecurityEvent] {
        let q = events.filter(
            colType.like("%\(searchTerm)%") ||
            colStatus.like("%\(searchTerm)%") ||
            colNotes.like("%\(searchTerm)%")
        ).order(colId.desc)
        return try db.prepare(q).map { row in
            SecurityEvent(
                id:          row[colId],
                type:        row[colType],
                distance:    row[colDistance],
                temperature: row[colTemperature],
                status:      row[colStatus],
                notes:       row[colNotes],
                timestamp:   row[colTimestamp]
            )
        }
    }

    /// Returns events sorted by a given field.
    func getSortedEvents(by field: String, ascending: Bool = true) throws -> [SecurityEvent] {
        let query: Table
        switch field {
        case "distance":
            query = ascending ? events.order(colDistance.asc) : events.order(colDistance.desc)
        case "temperature":
            query = ascending ? events.order(colTemperature.asc) : events.order(colTemperature.desc)
        case "status":
            query = ascending ? events.order(colStatus.asc) : events.order(colStatus.desc)
        case "type":
            query = ascending ? events.order(colType.asc) : events.order(colType.desc)
        default:
            query = ascending ? events.order(colId.asc) : events.order(colId.desc)
        }
        return try db.prepare(query).map { row in
            SecurityEvent(
                id:          row[colId],
                type:        row[colType],
                distance:    row[colDistance],
                temperature: row[colTemperature],
                status:      row[colStatus],
                notes:       row[colNotes],
                timestamp:   row[colTimestamp]
            )
        }
    }

    // MARK: - CREATE
    /// Inserts a new security event into the database.
    func createEvent(form: CreateEventForm) throws {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = fmt.string(from: Date())

        try db.run(events.insert(
            colType        <- form.type,
            colDistance    <- form.parsedDistance,
            colTemperature <- form.parsedTemperature,
            colStatus      <- form.status,
            colNotes       <- form.notes,
            colTimestamp   <- now
        ))
    }

    // MARK: - UPDATE
    /// Updates all mutable fields of an existing event identified by id.
    func updateEvent(id: Int, form: CreateEventForm) throws {
        let row = events.filter(colId == id)
        try db.run(row.update(
            colType        <- form.type,
            colDistance    <- form.parsedDistance,
            colTemperature <- form.parsedTemperature,
            colStatus      <- form.status,
            colNotes       <- form.notes
        ))
    }

    // MARK: - DELETE
    /// Deletes a single event by primary key.
    func deleteEvent(id: Int) throws {
        let row = events.filter(colId == id)
        try db.run(row.delete())
    }

    /// Deletes ALL events — used by the "clear all" admin action.
    func deleteAllEvents() throws {
        try db.run(events.delete())
    }

    // MARK: - STATS
    /// Returns aggregate statistics for the dashboard header.
    func getStats() throws -> (total: Int, stops: Int, warnings: Int, oks: Int) {
        let total    = try db.scalar(events.count)
        let stops    = try db.scalar(events.filter(colStatus == "STOP").count)
        let warnings = try db.scalar(events.filter(colStatus == "WARNING").count)
        let oks      = try db.scalar(events.filter(colStatus == "OK").count)
        return (total, stops, warnings, oks)
    }
}