//
//  SleepLogViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 13.07.2025.
//
import FirebaseFirestore
import FirebaseAuth

class SleepLogViewModel: ObservableObject {
    @Published var logs: [SleepLog] = []
    @Published var expectedWakeTime: String?
    let reasons = ["😴 Too tired", "⏰ Slept through alarm", "😓 Stress or overthinking", "🔊 Noise or disturbance", "🤒 Feeling sick", "📱 Scrolled phone too long", "💻 Worked late", "🧠 Couldn't fall asleep", "🍔 Ate too late", "🧃 Drank caffeine late", "📺 Watched movies/TV", "🎮 Played games late", "🗓️ Irregular schedule", "👶 Kids or family interrupted", "✈️ Jet lag or travel", "📞 Late call or chat", "📚 Studied late", "❓ No specific reason"
    ]

    private var db = Firestore.firestore()

    func saveSleepLog(_ log: SleepLog) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }

        let data = log.toDict()

        db.collection("users")
            .document(uid)
            .collection("sleepLogs")
            .addDocument(data: data) { [weak self] error in
                if let error = error {
                    print("🔥 Error saving log: \(error.localizedDescription)")
                } else {
                    print("✅ Sleep log saved to subcollection")
                    self?.fetchLogs()
                }
            }
    }

    func fetchLogs() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }

        db.collection("users")
            .document(uid)
            .collection("sleepLogs")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("🔥 Error fetching logs: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self?.logs = documents.compactMap { doc -> SleepLog? in
                    let data = doc.data()
                    return SleepLog(
                        date: data["date"] as? String ?? "",
                        sleepTime: data["sleepTime"] as? String ?? "",
                        wakeTime: data["wakeTime"] as? String ?? "",
                        expectedWakeTime: data["expectedWakeTime"] as? String ?? "",
                        reasonId: data["reasonId"] as? Int,
                        customReason: data["customReason"] as? String,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            }
    }
    
    func fetchExpectedWakeTime() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), let wakeTime = data["expectedWakeTime"] as? String {
                self?.expectedWakeTime = wakeTime
            } else {
                self?.expectedWakeTime = nil
            }
        }
    }

    func saveExpectedWakeTime(_ time: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).setData([
            "expectedWakeTime": time
        ], merge: true) { [weak self] error in
            if let error = error {
                print("🔥 Error saving expected wake time: \(error)")
            } else {
                self?.fetchExpectedWakeTime()
                print("✅ Expected wake time saved")
            }
        }
    }

    func checkIfLogExistsForToday(completion: @escaping (Bool) -> Void) {
        let today = todayDateString()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid)
            .collection("sleepLogs")
            .whereField("date", isEqualTo: today)
            .getDocuments { snapshot, error in
                if let count = snapshot?.documents.count, count > 0 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }

    func shouldAskReason(actualWakeTime: Date) -> Bool {
        guard let expectedWakeTime else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let actual = formatter.string(from: actualWakeTime)
        return actual > expectedWakeTime // simple string compare works in "HH:mm"
    }

    func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func wasOnTimeToday() -> Bool {
        guard let log = logs.first(where: { $0.date == todayDateString() }), let expectedWakeTime else {
            return false
        }
        return log.wakeTime <= expectedWakeTime
    }
}
