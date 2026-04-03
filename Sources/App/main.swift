// main.swift
// SecureHome — Point d'entrée Hummingbird 2
// Routes : 2 GET + 5 POST + 2 GET bonus = 9 routes au total

import Hummingbird
import Foundation

// MARK: - Database setup
let db = try DatabaseManager()

// MARK: - Router
let router = Router()

// ──────────────────────────────────────────────────
// ROUTE 1 — GET / — Liste tous les événements (READ)
// Supporte ?sort=field pour le tri (bonus)
// ──────────────────────────────────────────────────
router.get("/") { request, _ -> Response in
    let sortBy = request.uri.queryParameters.get("sort") ?? "id"
    let flash  = request.uri.queryParameters.get("flash")

    let events = try await db.getSortedEvents(by: sortBy, ascending: sortBy != "id")
    let stats  = try await db.getStats()

    let html = Views.indexPage(
        events: events, stats: stats, sortBy: sortBy, flash: flash
    )
    return htmlResponse(html)
}

// ──────────────────────────────────────────────────
// ROUTE 2 — GET /new — Formulaire de création (CREATE form)
// ──────────────────────────────────────────────────
router.get("/new") { _, _ -> Response in
    return htmlResponse(Views.newEventPage())
}

// ──────────────────────────────────────────────────
// ROUTE 3 — POST /create — Insère un nouvel événement (CREATE)
// ──────────────────────────────────────────────────
router.post("/create") { request, _ -> Response in
    guard let body = try? await request.body.collect(upTo: 1024 * 16),
          let bodyStr = body.getString(at: 0, length: body.readableBytes) else {
        return redirectResponse(to: "/?flash=❌+Données+manquantes")
    }

    let form = parseForm(bodyStr)
    let eventForm = CreateEventForm(
        type:        form["type"] ?? "",
        distance:    form["distance"] ?? "0",
        temperature: form["temperature"] ?? "0",
        status:      form["status"] ?? "OK",
        notes:       form["notes"] ?? ""
    )

    // Validation côté serveur (bonus)
    if let error = eventForm.validate() {
        return htmlResponse(Views.newEventPage(error: error))
    }

    try await db.createEvent(form: eventForm)
    return redirectResponse(to: "/?flash=✅+Événement+créé+avec+succès")
}

// ──────────────────────────────────────────────────
// ROUTE 4 — GET /event/:id — Détail d'un événement (READ single + bonus)
// ──────────────────────────────────────────────────
router.get("/event/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let id = Int(idStr) else {
        return htmlResponse(Views.notFoundPage(), status: .notFound)
    }
    guard let event = try await db.getEvent(id: id) else {
        return htmlResponse(Views.notFoundPage(), status: .notFound)
    }
    return htmlResponse(Views.detailPage(event: event))
}

// ──────────────────────────────────────────────────
// ROUTE 5 — POST /update/:id — Met à jour un événement (UPDATE)
// ──────────────────────────────────────────────────
router.post("/update/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let id = Int(idStr) else {
        return redirectResponse(to: "/?flash=❌+ID+invalide")
    }

    guard let body = try? await request.body.collect(upTo: 1024 * 16),
          let bodyStr = body.getString(at: 0, length: body.readableBytes) else {
        return redirectResponse(to: "/?flash=❌+Données+manquantes")
    }

    let form = parseForm(bodyStr)
    let eventForm = CreateEventForm(
        type:        form["type"] ?? "",
        distance:    form["distance"] ?? "0",
        temperature: form["temperature"] ?? "0",
        status:      form["status"] ?? "OK",
        notes:       form["notes"] ?? ""
    )

    if let error = eventForm.validate() {
        return redirectResponse(to: "/event/\(id)?flash=❌+\(error)")
    }

    try await db.updateEvent(id: id, form: eventForm)
    return redirectResponse(to: "/?flash=✅+Événement+%23\(id)+mis+à+jour")
}

// ──────────────────────────────────────────────────
// ROUTE 6 — POST /delete/:id — Supprime un événement (DELETE)
// ──────────────────────────────────────────────────
router.post("/delete/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let id = Int(idStr) else {
        return redirectResponse(to: "/?flash=❌+ID+invalide")
    }
    try await db.deleteEvent(id: id)
    return redirectResponse(to: "/?flash=✅+Événement+supprimé")
}

// ──────────────────────────────────────────────────
// ROUTE 7 — POST /delete-all — Supprime tous les événements (DELETE bonus)
// ──────────────────────────────────────────────────
router.post("/delete-all") { _, _ -> Response in
    try await db.deleteAllEvents()
    return redirectResponse(to: "/?flash=✅+Tous+les+événements+supprimés")
}

// ──────────────────────────────────────────────────
// ROUTE 8 — GET /search — Formulaire de recherche (bonus)
// ──────────────────────────────────────────────────
router.get("/search") { _, _ -> Response in
    return htmlResponse(Views.searchPage(results: nil))
}

// ──────────────────────────────────────────────────
// ROUTE 9 — POST /search — Exécute la recherche (bonus)
// ──────────────────────────────────────────────────
router.post("/search") { request, _ -> Response in
    guard let body = try? await request.body.collect(upTo: 1024 * 4),
          let bodyStr = body.getString(at: 0, length: body.readableBytes) else {
        return htmlResponse(Views.searchPage(results: nil))
    }

    let form = parseForm(bodyStr)
    let q = form["q"] ?? ""
    let results = try await db.searchEvents(query: q)
    return htmlResponse(Views.searchPage(results: results, query: q))
}

// MARK: - Application
let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("🏠 SecureHome démarré sur http://0.0.0.0:8080")
try await app.runService()

// MARK: - Helpers

/// Parse un body URL-encodé en dictionnaire [String: String]
func parseForm(_ body: String) -> [String: String] {
    var result = [String: String]()
    for pair in body.split(separator: "&") {
        let parts = pair.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
            let key   = String(parts[0]).removingPercentEncoding ?? String(parts[0])
            let value = String(parts[1])
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? String(parts[1])
            result[key] = value
        }
    }
    return result
}

/// Construit une réponse 303 redirect
func redirectResponse(to location: String) -> Response {
    Response(
        status: .seeOther,
        headers: [.location: location],
        body: .init()
    )
}

/// Construit une réponse HTML
func htmlResponse(_ html: String, status: HTTPResponse.Status = .ok) -> Response {
    Response(
        status: status,
        headers: [.contentType: "text/html; charset=utf-8"],
        body: .init(byteBuffer: ByteBuffer(string: html))
    )
}