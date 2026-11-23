import Foundation

/// First-semester checklist for F-1/J-1 students (same content as the website's data.js).
enum Checklist {
    static let groups: [ChecklistGroup] = [
        ChecklistGroup(icon: "🛂", title: "Immigration & Visa", when: "Before arrival · Week 1", tasks: [
            ChecklistTask(id: "passport", label: "Passport valid 6+ months", hint: "Renew early through your home country's consulate."),
            ChecklistTask(id: "i20", label: "Signed I-20 / DS-2019 in your carry-on", hint: "Never pack immigration documents in checked luggage."),
            ChecklistTask(id: "i94", label: "Download your I-94 arrival record", hint: "Free on the U.S. CBP I-94 website after you land."),
            ChecklistTask(id: "isss", label: "Complete the international student check-in", hint: "Upload passport, visa and I-94 to activate your SEVIS record."),
        ]),
        ChecklistGroup(icon: "📚", title: "Course Registration for Non-Citizens", when: "Weeks 1–2", tasks: [
            ChecklistTask(id: "fulltime", label: "Register for 12+ credit hours", hint: "F-1 undergrads must stay full-time every fall & spring."),
            ChecklistTask(id: "online", label: "Max. one online course toward full-time", hint: "Only one online class can count toward your F-1 minimum."),
            ChecklistTask(id: "advisor", label: "Meet your academic advisor", hint: "Ask about AP / IB / A-level credit from your home country."),
            ChecklistTask(id: "transfer", label: "Plan Gen Eds that transfer from abroad", hint: "Leave room in year 2 for courses you can take at UNSW."),
        ]),
        ChecklistGroup(icon: "💳", title: "Money, Health & Daily Life", when: "First month", tasks: [
            ChecklistTask(id: "bank", label: "Open a U.S. bank account", hint: "Bring passport, I-20 and your enrollment letter."),
            ChecklistTask(id: "insurance", label: "Confirm student health insurance", hint: "Check whether your home plan qualifies for a waiver."),
            ChecklistTask(id: "job", label: "Check on-campus job rules", hint: "F-1 students can usually work up to 20 hrs/week on campus during term."),
            ChecklistTask(id: "phone", label: "Get a U.S. phone number", hint: "Needed for 2-factor login and campus safety alerts."),
        ]),
        ChecklistGroup(icon: "🦘", title: "Study Abroad Early — Sydney Track", when: "Year 1 · Spring", tasks: [
            ChecklistTask(id: "info", label: "Attend a Study Abroad 101 session", hint: "Learn which exchanges accept second-year students."),
            ChecklistTask(id: "unsw", label: "Meet an advisor about the UNSW exchange", hint: "Bring a draft list of courses you'd like credit for."),
            ChecklistTask(id: "gpa", label: "Note the GPA minimum & application deadline", hint: "Add the deadline to your calendar now."),
            ChecklistTask(id: "status", label: "Ask how to keep F-1 status while abroad", hint: "You'll need a travel signature on your I-20 to re-enter the U.S."),
            ChecklistTask(id: "visa500", label: "Research the Australian Student visa (subclass 500)", hint: "Includes Overseas Student Health Cover (OSHC)."),
        ]),    ]

    static var total: Int { groups.reduce(0) { $0 + $1.tasks.count } }
}
