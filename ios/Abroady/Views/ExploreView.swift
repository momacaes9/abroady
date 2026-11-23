import SwiftUI

/// Home tab: your cohort, and every study-abroad destination your university sends students to.
struct ExploreView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your global campus")
                            .font(.title2.bold()).foregroundStyle(Color.navy)
                        Text("Find your cohort before you fly, meet verified ambassadors, and never miss a campus event.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                if let p = model.profile, let dest = model.university(p.destinationId), let term = p.term {
                    Section("My cohort") {
                        NavigationLink {
                            CohortGate(destination: dest, term: term)
                        } label: {
                            HStack(spacing: 12) {
                                Text(dest.flag).font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text("\(dest.shortName) · \(term)").font(.headline)
                                    Text("Open group chat").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Destinations") {
                    if model.destinations.isEmpty {
                        if model.isLoading { ProgressView() }
                        else { EmptyState(icon: "airplane", title: "No destinations yet", message: "Pull to refresh.") }
                    }
                    ForEach(model.destinations) { dest in
                        NavigationLink(value: dest) {
                            HStack(spacing: 12) {
                                Text(dest.flag).font(.title)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(dest.name).font(.headline)
                                    Text(dest.place).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                let count = model.ambassadors.filter { $0.universityId == dest.id }.count
                                if count > 0 { Pill(text: "\(count) ambassador\(count == 1 ? "" : "s")") }
                            }
                        }
                    }
                }
            }
            .groupedList()
            .safeAreaInset(edge: .top) { DemoBanner() }
            .navigationTitle("Abroady")
            .navigationDestination(for: University.self) { DestinationView(destination: $0) }
            .refreshable { await model.bootstrap() }
        }
    }
}

struct DestinationView: View {
    @Environment(AppModel.self) private var model
    let destination: University
    @State private var term = Terms.upcoming.first ?? "Spring 2028"

    private var ambassadors: [Ambassador] { model.ambassadors.filter { $0.universityId == destination.id } }
    private var events: [CampusEvent] { model.events.filter { $0.universityId == destination.id } }

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Text(destination.flag).font(.system(size: 48))
                    VStack(alignment: .leading) {
                        Text(destination.name).font(.title3.bold())
                        Text(destination.place).foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Picker("Term", selection: $term) {
                    ForEach(Terms.upcoming, id: \.self) { Text($0).tag($0) }
                }
                NavigationLink {
                    CohortGate(destination: destination, term: term)
                } label: {
                    Label("Join the \(term) cohort chat", systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.headline)
                }
            } header: {
                Text("Your cohort")
            } footer: {
                Text("Everyone going to \(destination.shortName) in the same term, in one group chat.")
            }

            Section("Ambassadors here") {
                if ambassadors.isEmpty {
                    Text("No verified ambassadors yet. Been here before? Apply from your Profile.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                ForEach(ambassadors) { a in
                    NavigationLink { AmbassadorDetailView(ambassador: a) } label: { AmbassadorRow(ambassador: a) }
                }
            }

            if !events.isEmpty {
                Section("Upcoming events") {
                    ForEach(events) { e in
                        NavigationLink { EventDetailView(event: e) } label: { EventRow(event: e) }
                    }
                }
            }
        }
        .groupedList()
        .navigationTitle(destination.shortName)
        .inlineTitle()
        .onAppear { if let t = model.profile?.term, Terms.upcoming.contains(t) { term = t } }
    }
}
