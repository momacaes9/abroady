import SwiftUI

/// Real campus events, linked to a university and approved before they go public.
struct EventsView: View {
    @Environment(AppModel.self) private var model
    @State private var audience = "all"

    private let audiences = [("all", "All"), ("international", "International"), ("first_year", "First-years"), ("study_abroad", "Abroad")]

    private var filtered: [CampusEvent] {
        model.events
            .filter { $0.universityId == model.campus?.id }
            .filter { audience == "all" || $0.audience == audience || $0.audience == "all" }
    }

    private var byDay: [(Date, [CampusEvent])] {
        let groups = Dictionary(grouping: filtered) { Calendar.current.startOfDay(for: $0.startsAt) }
        return groups.keys.sorted().map { ($0, groups[$0]!.sorted { $0.startsAt < $1.startsAt }) }
    }

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            List {
                Section {
                    Picker("Who", selection: $audience) {
                        ForEach(audiences, id: \.0) { Text($0.1).tag($0.0) }
                    }
                    .pickerStyle(.segmented)
                }
                if byDay.isEmpty {
                    EmptyState(icon: "calendar.badge.clock", title: "No events yet",
                               message: "Events from \(model.campus?.shortName ?? "your campus"), its clubs and ambassadors show up here once approved.")
                }
                ForEach(byDay, id: \.0) { day, events in
                    Section(day.eventDay) {
                        ForEach(events) { e in
                            NavigationLink { EventDetailView(event: e) } label: { EventRow(event: e) }
                        }
                    }
                }
            }
            .groupedList()
            .safeAreaInset(edge: .top) { DemoBanner() }
            .navigationTitle(model.campus.map { "\($0.shortName) events" } ?? "Events")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("Campus", selection: $model.campusId) {
                            ForEach(model.universities) { u in Text("\(u.flag) \(u.shortName)").tag(Optional(u.id)) }
                        }
                    } label: {
                        Label("Campus", systemImage: "building.columns")
                    }
                }
            }
            .refreshable { await model.bootstrap() }
        }
    }
}

struct EventRow: View {
    @Environment(AppModel.self) private var model
    let event: CampusEvent
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.startsAt.eventTime).font(.caption.weight(.bold)).foregroundStyle(Color.brandInk)
                if event.hostType == "university" { VerifiedBadge(label: "Official") }
                Spacer()
                if model.rsvps.contains(event.id) { Pill(text: "Going", color: .success) }
            }
            Text(event.title).font(.headline)
            if let loc = event.location { Label(loc, systemImage: "mappin.and.ellipse").font(.caption).foregroundStyle(.secondary) }
            HStack {
                Pill(text: event.audienceLabel)
                Text("\(model.going[event.id] ?? 0) going").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EventDetailView: View {
    @Environment(AppModel.self) private var model
    let event: CampusEvent
    @State private var showAuth = false

    var body: some View {
        let isGoing = model.rsvps.contains(event.id)
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack { Pill(text: event.hostLabel); Pill(text: event.audienceLabel, color: .navy) }
                    Text(event.title).font(.title2.bold())
                    Label("\(event.startsAt.eventDay), \(event.startsAt.eventTime)\(event.endsAt.map { " – \($0.eventTime)" } ?? "")",
                          systemImage: "clock")
                    if let loc = event.location { Label(loc, systemImage: "mappin.and.ellipse") }
                    if let host = event.hostName { Label(host, systemImage: "person.3") }
                    if let uni = model.university(event.universityId) { Label("\(uni.flag) \(uni.name)", systemImage: "building.columns") }
                }
                .padding(.vertical, 6)
            }
            if let text = event.description { Section("About") { Text(text) } }
            Section {
                Button {
                    if model.isSignedIn { Task { await model.toggleRSVP(event) } } else { showAuth = true }
                } label: {
                    Label(isGoing ? "You're going · tap to cancel" : "I'm going", systemImage: isGoing ? "checkmark.circle.fill" : "plus.circle")
                        .font(.headline)
                }
                Text("\(model.going[event.id] ?? 0) students going").font(.caption).foregroundStyle(.secondary)
                if let link = event.url.flatMap(URL.init(string:)) {
                    Link(destination: link) { Label("Event page", systemImage: "safari") }
                }
                ShareLink(item: "\(event.title) · \(event.startsAt.eventDay) \(event.startsAt.eventTime) · via Abroady")
            }
        }
        .groupedList()
        .navigationTitle("Event")
        .inlineTitle()
        .sheet(isPresented: $showAuth) { AuthView() }
    }
}
