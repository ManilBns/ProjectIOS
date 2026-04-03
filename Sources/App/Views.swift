// Views.swift
// SecureHome — Génération HTML côté serveur
// Toute l'interface utilisateur est produite ici en Swift pur.

import Foundation

// MARK: - Views
/// Namespace for all server-side HTML rendering functions.
/// Each function returns a complete or partial HTML String.
enum Views {

    // MARK: - Shared Layout
    /// Wraps any page content in the full HTML shell with <head>, nav, and <footer>.
    static func layout(title: String, content: String, flashMessage: String? = nil) -> String {
        let flash = flashMessage.map { msg in
            """
            <div class="flash \(msg.hasPrefix("✅") ? "flash-ok" : "flash-error")" role="alert">
              \(msg)
            </div>
            """
        } ?? ""

        return """
        <!DOCTYPE html>
        <html lang="fr" data-theme="dark">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>\(title) — SecureHome</title>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css" />
          <style>
            :root {
              --primary:   #0062D9;
              --ok-color:  #34C759;
              --warn-color:#FF9500;
              --stop-color:#FF3B30;
              --card-bg:   #1A1D2E;
              --bg:        #0F1117;
            }
            body { background: var(--bg); }
            nav.main-nav {
              background: #13151F;
              padding: 0.8rem 1.5rem;
              display: flex; align-items: center; gap: 1rem;
              border-bottom: 2px solid var(--primary);
            }
            nav.main-nav .brand {
              font-size: 1.3rem; font-weight: 700;
              color: #fff; text-decoration: none;
              display: flex; align-items: center; gap: 0.5rem;
            }
            nav.main-nav a { color: #8890B5; text-decoration: none; font-size: 0.9rem; }
            nav.main-nav a:hover { color: #4D9FFF; }
            nav.main-nav .spacer { flex: 1; }
            .container { max-width: 1100px; margin: 0 auto; padding: 1.5rem; }
            .stats-grid {
              display: grid; grid-template-columns: repeat(4, 1fr);
              gap: 1rem; margin-bottom: 1.5rem;
            }
            .stat-card {
              background: var(--card-bg); border-radius: 12px;
              padding: 1rem; text-align: center;
            }
            .stat-card .stat-value { font-size: 2rem; font-weight: 700; }
            .stat-card .stat-label { font-size: 0.8rem; color: #8890B5; }
            .badge {
              display: inline-block; padding: 2px 10px;
              border-radius: 20px; font-size: 0.78rem; font-weight: 600;
            }
            .badge-ok   { background: rgba(52,199,89,.2);  color: var(--ok-color);   }
            .badge-warning { background: rgba(255,149,0,.2); color: var(--warn-color); }
            .badge-stop { background: rgba(255,59,48,.2);  color: var(--stop-color); }
            .flash {
              padding: 0.8rem 1rem; border-radius: 8px;
              margin-bottom: 1rem; font-weight: 600;
            }
            .flash-ok    { background: rgba(52,199,89,.15); color: var(--ok-color);   border-left: 4px solid var(--ok-color);   }
            .flash-error { background: rgba(255,59,48,.15); color: var(--stop-color); border-left: 4px solid var(--stop-color); }
            table { background: var(--card-bg); border-radius: 12px; overflow: hidden; }
            th { color: #8890B5; font-size: 0.82rem; text-transform: uppercase; letter-spacing: .05em; }
            .btn-danger { --pico-background-color: var(--stop-color); border: none; }
            .btn-sm { padding: 0.3rem 0.7rem; font-size: 0.8rem; }
            .detail-card {
              background: var(--card-bg); border-radius: 16px;
              padding: 1.5rem; margin-bottom: 1rem;
            }
            .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
            .detail-row { display: flex; flex-direction: column; }
            .detail-row .label { font-size: 0.78rem; color: #8890B5; margin-bottom: 2px; }
            .detail-row .value { font-size: 1.1rem; font-weight: 600; }
            footer { text-align: center; color: #4A4F6A; font-size: 0.8rem; padding: 2rem 0 1rem; }
            @media (max-width: 600px) {
              .stats-grid { grid-template-columns: 1fr 1fr; }
              .detail-grid { grid-template-columns: 1fr; }
            }
          </style>
        </head>
        <body>
          <nav class="main-nav">
            <a href="/" class="brand">🏠 SecureHome</a>
            <span class="spacer"></span>
            <a href="/">📋 Événements</a>
            <a href="/new">➕ Nouveau</a>
            <a href="/search">🔍 Recherche</a>
          </nav>
          <main class="container">
            \(flash)
            \(content)
          </main>
          <footer>
            <p>SecureHome © 2025 — Système de surveillance Arduino · Manil BENMOUSSA &amp; Yasmine Merad</p>
          </footer>
        </body>
        </html>
        """
    }

    // MARK: - Badge Helper
    static func statusBadge(_ status: String) -> String {
        let s = AlertStatus(rawValue: status) ?? .ok
        return "<span class=\"badge badge-\(s.cssClass)\">\(s.label)</span>"
    }

    // MARK: - Stats Cards
    static func statsCards(total: Int, stops: Int, warnings: Int, oks: Int) -> String {
        """
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-value" style="color:#4D9FFF">\(total)</div>
            <div class="stat-label">Total événements</div>
          </div>
          <div class="stat-card">
            <div class="stat-value" style="color:var(--stop-color)">\(stops)</div>
            <div class="stat-label">🚨 STOP</div>
          </div>
          <div class="stat-card">
            <div class="stat-value" style="color:var(--warn-color)">\(warnings)</div>
            <div class="stat-label">⚠️ Warning</div>
          </div>
          <div class="stat-card">
            <div class="stat-value" style="color:var(--ok-color)">\(oks)</div>
            <div class="stat-label">✅ Normal</div>
          </div>
        </div>
        """
    }

    // MARK: - Event Row
    static func eventRow(_ e: SecurityEvent) -> String {
        """
        <tr>
          <td><strong>#\(e.id)</strong></td>
          <td>\(e.eventType.label)</td>
          <td>\(e.distanceFormatted)</td>
          <td>\(e.temperatureFormatted)</td>
          <td>\(statusBadge(e.status))</td>
          <td style="color:#8890B5;font-size:.82rem">\(e.timestamp)</td>
          <td>
            <a href="/event/\(e.id)" class="btn-sm" role="button" style="--pico-background-color:#1A3A5C">
              Détails
            </a>
          </td>
          <td>
            <form action="/delete/\(e.id)" method="POST" style="display:inline;margin:0">
              <button type="submit" class="btn-sm btn-danger"
                onclick="return confirm('Supprimer cet événement ?')">
                🗑
              </button>
            </form>
          </td>
        </tr>
        """
    }

    // MARK: - Index Page (READ)
    static func indexPage(
        events: [SecurityEvent],
        stats: (total: Int, stops: Int, warnings: Int, oks: Int),
        sortBy: String = "id",
        flash: String? = nil
    ) -> String {
        let rows = events.isEmpty
            ? "<tr><td colspan='8' style='text-align:center;color:#4A4F6A;padding:2rem'>Aucun événement enregistré.</td></tr>"
            : events.map { eventRow($0) }.joined()

        func sortLink(_ field: String, _ label: String) -> String {
            let active = sortBy == field ? " style=\"color:#4D9FFF\"" : ""
            return "<a href=\"/?sort=\(field)\"\(active)>\(label)</a>"
        }

        let content = """
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:1rem">
          <h1 style="margin:0">📋 Journal de sécurité</h1>
          <div style="display:flex;gap:.5rem">
            <a href="/new" role="button">➕ Nouvel événement</a>
            <form action="/delete-all" method="POST" style="margin:0">
              <button type="submit" class="btn-danger"
                onclick="return confirm('Supprimer TOUS les événements ?')">
                🗑 Tout effacer
              </button>
            </form>
          </div>
        </div>
        \(statsCards(total: stats.total, stops: stats.stops, warnings: stats.warnings, oks: stats.oks))
        <div style="margin-bottom:.5rem;font-size:.85rem;color:#8890B5">
          Trier par :
          \(sortLink("id", "Date"))
          · \(sortLink("distance", "Distance"))
          · \(sortLink("temperature", "Température"))
          · \(sortLink("status", "Statut"))
          · \(sortLink("type", "Type"))
        </div>
        <div style="overflow-x:auto">
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Type</th><th>Distance</th>
              <th>Température</th><th>Statut</th><th>Horodatage</th>
              <th>Détails</th><th>Suppr.</th>
            </tr>
          </thead>
          <tbody>\(rows)</tbody>
        </table>
        </div>
        """
        return layout(title: "Journal", content: content, flashMessage: flash)
    }

    // MARK: - Detail Page (READ single)
    static func detailPage(event e: SecurityEvent) -> String {
        let content = """
        <div style="display:flex;align-items:center;gap:1rem;margin-bottom:1rem">
          <a href="/" style="color:#8890B5">← Retour</a>
          <h1 style="margin:0">Événement #\(e.id)</h1>
          \(statusBadge(e.status))
        </div>
        <div class="detail-card">
          <div class="detail-grid">
            <div class="detail-row">
              <span class="label">Type</span>
              <span class="value">\(e.eventType.label)</span>
            </div>
            <div class="detail-row">
              <span class="label">Statut</span>
              <span class="value">\(statusBadge(e.status))</span>
            </div>
            <div class="detail-row">
              <span class="label">Distance</span>
              <span class="value">\(e.distanceFormatted)</span>
            </div>
            <div class="detail-row">
              <span class="label">Température</span>
              <span class="value">\(e.temperatureFormatted)</span>
            </div>
            <div class="detail-row">
              <span class="label">Horodatage</span>
              <span class="value" style="font-size:.95rem">\(e.timestamp)</span>
            </div>
            <div class="detail-row">
              <span class="label">Notes</span>
              <span class="value" style="font-weight:400">\(e.notes.isEmpty ? "<em>Aucune note</em>" : e.notes)</span>
            </div>
          </div>
        </div>

        <h2>✏️ Modifier cet événement</h2>
        \(eventForm(action: "/update/\(e.id)", event: e))

        <form action="/delete/\(e.id)" method="POST" style="margin-top:1rem">
          <button type="submit" class="btn-danger"
            onclick="return confirm('Supprimer définitivement cet événement ?')">
            🗑️ Supprimer cet événement
          </button>
        </form>
        """
        return layout(title: "Événement #\(e.id)", content: content)
    }

    // MARK: - New Event Page (CREATE form)
    static func newEventPage(error: String? = nil) -> String {
        let errBox = error.map {
            "<div class=\"flash flash-error\">⚠️ \($0)</div>"
        } ?? ""
        let content = """
        <div style="max-width:600px;margin:0 auto">
          <a href="/" style="color:#8890B5">← Retour</a>
          <h1>➕ Nouvel événement de sécurité</h1>
          \(errBox)
          \(eventForm(action: "/create", event: nil))
        </div>
        """
        return layout(title: "Nouvel événement", content: content)
    }

    // MARK: - Reusable Event Form
    /// Shared form for both CREATE and UPDATE. If `event` is non-nil, pre-fills fields.
    static func eventForm(action: String, event: SecurityEvent?) -> String {
        let typeOptions = EventType.allCases.map { t in
            let sel = event?.type == t.rawValue ? " selected" : ""
            return "<option value=\"\(t.rawValue)\"\(sel)>\(t.label)</option>"
        }.joined()

        let statusOptions = AlertStatus.allCases.map { s in
            let sel = event?.status == s.rawValue ? " selected" : ""
            return "<option value=\"\(s.rawValue)\"\(sel)>\(s.label)</option>"
        }.joined()

        let dist  = event.map { String(format: "%.1f", $0.distance) } ?? ""
        let temp  = event.map { String(format: "%.1f", $0.temperature) } ?? ""
        let notes = event?.notes ?? ""

        return """
        <form action="\(action)" method="POST">
          <div class="grid">
            <label>Type d'événement
              <select name="type" required>\(typeOptions)</select>
            </label>
            <label>Statut
              <select name="status" required>\(statusOptions)</select>
            </label>
          </div>
          <div class="grid">
            <label>Distance (cm)
              <input type="number" name="distance" step="0.1" min="0"
                     value="\(dist)" placeholder="ex: 45.0" />
            </label>
            <label>Température (°C)
              <input type="number" name="temperature" step="0.1" min="-50" max="150"
                     value="\(temp)" placeholder="ex: 23.5" />
            </label>
          </div>
          <label>Notes
            <textarea name="notes" rows="3"
              placeholder="Description facultative de l'événement...">\(notes)</textarea>
          </label>
          <button type="submit">\(event == nil ? "➕ Créer l'événement" : "💾 Enregistrer les modifications")</button>
        </form>
        """
    }

    // MARK: - Search Page
    static func searchPage(results: [SecurityEvent]?, query: String = "") -> String {
        let resultsHTML: String
        if let results {
            if results.isEmpty {
                resultsHTML = "<p style=\"color:#8890B5\">Aucun résultat pour <strong>\(query)</strong>.</p>"
            } else {
                let rows = results.map { eventRow($0) }.joined()
                resultsHTML = """
                <p style="color:#8890B5">\(results.count) résultat(s) pour « \(query) »</p>
                <div style="overflow-x:auto">
                <table>
                  <thead>
                    <tr>
                      <th>ID</th><th>Type</th><th>Distance</th>
                      <th>Température</th><th>Statut</th><th>Horodatage</th>
                      <th>Détails</th><th>Suppr.</th>
                    </tr>
                  </thead>
                  <tbody>\(rows)</tbody>
                </table>
                </div>
                """
            }
        } else {
            resultsHTML = ""
        }

        let content = """
        <h1>🔍 Rechercher un événement</h1>
        <form action="/search" method="POST" style="max-width:500px">
          <div style="display:flex;gap:.5rem">
            <input type="text" name="q" value="\(query)"
              placeholder="Type, statut, notes..." required style="margin:0" />
            <button type="submit">Chercher</button>
          </div>
        </form>
        <hr />
        \(resultsHTML)
        """
        return layout(title: "Recherche", content: content)
    }

    // MARK: - 404 / Error Pages
    static func notFoundPage() -> String {
        let content = """
        <div style="text-align:center;padding:4rem 0">
          <div style="font-size:4rem">🔍</div>
          <h1>404 — Page introuvable</h1>
          <p style="color:#8890B5">La page ou l'événement demandé n'existe pas.</p>
          <a href="/" role="button">← Retour à l'accueil</a>
        </div>
        """
        return layout(title: "404", content: content)
    }

    static func errorPage(message: String) -> String {
        let content = """
        <div style="text-align:center;padding:4rem 0">
          <div style="font-size:4rem">⚠️</div>
          <h1>Erreur serveur</h1>
          <p style="color:#8890B5">\(message)</p>
          <a href="/" role="button">← Retour à l'accueil</a>
        </div>
        """
        return layout(title: "Erreur", content: content)
    }
}