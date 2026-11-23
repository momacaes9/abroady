import SwiftUI

/// First-semester checklist for F-1/J-1 students. Works offline; syncs when logged in.
struct ChecklistView: View {
    @Environment(AppModel.self) private var model

    private var progress: Double { Double(model.checklistDone.count) / Double(max(Checklist.total, 1)) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Overall progress").font(.headline)
                            Spacer()
                            Text("\(Int(progress * 100))%").font(.headline).foregroundStyle(Color.brandInk)
                        }
                        ProgressView(value: progress).tint(Color.success)
                        Text("\(model.checklistDone.count) of \(Checklist.total) tasks done")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } footer: {
                    Text("General guidance, not legal advice. Your university's international office has the final word on visa rules.")
                }

                ForEach(Checklist.groups) { group in
                    Section {
                        ForEach(group.tasks) { task in
                            Button { model.toggle(task) } label: { row(task) }
                                .buttonStyle(.plain)
                        }
                    } header: {
                        Text("\(group.icon) \(group.title) · \(group.when)")
                    }
                }
            }
            .groupedList()
            .navigationTitle("Arrival checklist")
        }
    }

    private func row(_ task: ChecklistTask) -> some View {
        let done = model.checklistDone.contains(task.id)
        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(done ? Color.success : Color.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(task.label).font(.subheadline.weight(.semibold)).strikethrough(done, color: .secondary)
                Text(task.hint).font(.caption).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(done ? [.isButton, .isSelected] : .isButton)
    }
}
