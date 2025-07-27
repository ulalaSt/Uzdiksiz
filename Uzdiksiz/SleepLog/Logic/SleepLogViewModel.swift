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
    @Published var isLoading: Bool = false
    let reasons = [
        "😴 Өте шаршадым",
        "⏰ Оятқышты естімей қалдым",
        "😓 Уайым немесе көп ойлау",
        "🔊 Дыбыс немесе мазасыздық",
        "🤒 Ауырып қалдым",
        "📱 Ұялы телефон қарап ұзақ отырдым",
        "💻 Кешке дейін жұмыс істедім",
        "🧠 Ұйықтай алмадым",
        "🍔 Кеш тамақтандым",
        "🧃 Кеш кофе ішіп қойдым",
        "📺 Теледидар/фильм қарадым",
        "🎮 Ойын ойнадым",
        "🗓️ Кестем тұрақсыз болды",
        "👶 Бала немесе отбасы",
        "✈️ Ұшақтан кейінгі уақыт айырмашылығы",
        "📞 Кешке қоңырау немесе сөйлесу",
        "📚 Кешке дейін сабақ оқыдым",
        "❓ Белгісіз себеп"
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
        self.logs = []
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
        isLoading = true
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            self?.isLoading = false
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
    
    func todaysResultText() -> String? {
        guard let log = logs.first(where: { $0.date == todayDateString() }) else {
            return nil
        }

        let summary = """
        🛌 Ұйықтаған уақыты: \(log.sleepTime)
        🌅 Оянған уақыты: \(log.wakeTime)
        😴 Ұйқы ұзақтығы: \(calculateDuration(from: log.sleepTime, to: log.wakeTime))
        """

        let motivation: String
        if wasOnTimeToday() {
            motivation = "\n👏 Сіз бүгін уақытылы ояндыңыз!"
        } else {
            let earlierTime = subtract30Minutes(from: log.sleepTime)
            motivation = """
            \n\n
    😌 Бір күн қателесу айып емес
    Бүгін түнде 30 минут бұрын (\(earlierTime)) ұйықтап көріңіз.
    """
        }

        return summary + motivation
    }

    private func calculateDuration(from start: String, to end: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let sleep = formatter.date(from: start),
              let wake = formatter.date(from: end) else {
            return ""
        }

        let calendar = Calendar.current
        let sleepTime = sleep
        var wakeTime = wake

        if wake <= sleep {
            // Means wake time is next day
            wakeTime = calendar.date(byAdding: .day, value: 1, to: wakeTime)!
        }

        let components = calendar.dateComponents([.hour, .minute], from: sleepTime, to: wakeTime)

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        return "\(hour) сағат \(minute) минут"
    }
    
    private func subtract30Minutes(from timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let date = formatter.date(from: timeString) else { return timeString }

        let newDate = Calendar.current.date(byAdding: .minute, value: -30, to: date)!
        return formatter.string(from: newDate)
    }
    
    func currentStrike() -> Int? {
        guard let expectedWakeTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var strike = 0
        var date = Date()
        
        while true {
            let dateString = formatter.string(from: date)
            guard let log = logs.first(where: { $0.date == dateString }) else { break }
            
            if log.wakeTime <= expectedWakeTime {
                strike += 1
                // Move to previous day
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        
        return strike
    }

}
