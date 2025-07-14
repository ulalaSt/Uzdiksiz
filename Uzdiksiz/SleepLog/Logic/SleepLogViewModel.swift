//
//  SleepLogViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 13.07.2025.
//
import FirebaseFirestore

class SleepLogViewModel: ObservableObject {
    @Published var logs: [SleepLog] = []

    private var db = Firestore.firestore()

    func saveSleepLog(_ log: SleepLog) {
        db.collection("sleepLogs").addDocument(data: log.toDict()) { [weak self] error in
            if let error = error {
                print("🔥 Error saving log: \(error.localizedDescription)")
            } else {
                print("✅ Sleep log saved!")
                self?.fetchLogs()
            }
        }
    }

    func fetchLogs() {
        db.collection("sleepLogs")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Error fetching logs: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.logs = documents.compactMap { doc -> SleepLog? in
                    let data = doc.data()
                    
                    // Manual mapping — Firestore doesn't auto-decode Codable here
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
}
