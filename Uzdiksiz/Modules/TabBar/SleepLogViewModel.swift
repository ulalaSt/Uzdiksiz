//
//  SleepLogViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 13.07.2025.
//
import FirebaseFirestore
import FirebaseAuth

class SleepLogViewModel: ObservableObject {
    @Published var logs: Loadable<[SleepLog]> = .notRequested
    @Published var expectedWakeTime: Loadable<String?> = .notRequested
    let cancelBag = CancelBag()
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
    
    func createSleepLog(date: String, sleepTime: String, wakeTime: String) {
        guard let expectedWakeTime = expectedWakeTime.value,
              let expectedWakeTimeStr = expectedWakeTime,
              let uid = Auth.auth().currentUser?.uid else {
            print("❌ Can't create sleep log — missing expected wake time or user not logged in")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let parsedDate = formatter.date(from: date) else {
            print("❌ Invalid date format")
            return
        }

        let log = SleepLog(
            documentID: "",
            date: date,
            sleepTime: sleepTime,
            wakeTime: wakeTime,
            expectedWakeTime: expectedWakeTimeStr,
            reasonId: nil,
            customReason: nil,
            createdAt: parsedDate
        )

        let data = log.toDict()

        db.collection("users")
            .document(uid)
            .collection("sleepLogs")
            .addDocument(data: data) { [weak self] error in
                if let error = error {
                    print("🔥 Error saving manual log: \(error.localizedDescription)")
                } else {
                    print("✅ Manual sleep log created")
                    self?.fetchLogs()
                }
            }
    }
    
    func saveSleepLog(wakeTime: Date, sleepTime: Date, reasonId: Int?, customReason: String?) {
        guard let expectedWakeTime = expectedWakeTime.value, let expectedWakeTime else {
            return
        }
                
        let log = SleepLog(
            documentID: "",
            date: todayDateString(),
            sleepTime: formatTime(sleepTime),
            wakeTime: formatTime(wakeTime),
            expectedWakeTime: expectedWakeTime,
            reasonId: reasonId,
            customReason: reasonId == 999 ? customReason : nil,
            createdAt: Date()
        )


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
        self.logs.setIsLoading(cancelBag: cancelBag)
        db.collection("users")
            .document(uid)
            .collection("sleepLogs")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("🔥 Error fetching logs: \(error)")
                    self?.logs = .failed(.unexpectedError(error.localizedDescription))
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let logs = documents.compactMap { doc -> SleepLog? in
                    let data = doc.data()
                    return SleepLog(
                        documentID: doc.documentID,
                        date: data["date"] as? String ?? "",
                        sleepTime: data["sleepTime"] as? String ?? "",
                        wakeTime: data["wakeTime"] as? String ?? "",
                        expectedWakeTime: data["expectedWakeTime"] as? String ?? "",
                        reasonId: data["reasonId"] as? Int,
                        customReason: data["customReason"] as? String,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                self?.logs = .loaded(logs)
            }
    }
    
    func fetchExpectedWakeTime() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        expectedWakeTime.setIsLoading(cancelBag: cancelBag)
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error {
                self?.expectedWakeTime = .failed(.unexpectedError(error.localizedDescription))
            }
            if let data = snapshot?.data(), let wakeTime = data["expectedWakeTime"] as? String {
                self?.expectedWakeTime = .loaded(wakeTime)
            } else {
                self?.expectedWakeTime = .loaded(nil)
            }
        }
    }
    
    func saveExpectedWakeTime(_ time: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if case let .loaded(currentTime) = expectedWakeTime, currentTime == time {
            print("ℹ️ Expected wake time hasn't changed")
            return
        }

        db.collection("users").document(uid).setData([
            "expectedWakeTime": time
        ], merge: true) { [weak self] error in
            if let error = error {
                print("🔥 Error saving expected wake time: \(error)")
            } else {
                self?.fetchExpectedWakeTime()
                print("✅ Expected wake time saved: \(time)")
            }
        }
    }

    func shouldAskReason(actualWakeTime: Date) -> Bool {
        guard let expectedWakeTimeData = expectedWakeTime.value, let expectedWakeTime = expectedWakeTimeData else { return false }
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
        guard let log = logs.value?.first(where: { $0.date == todayDateString() }), let expectedWakeTimeData = expectedWakeTime.value, let expectedWakeTime = expectedWakeTimeData else {
            return false
        }
        return log.wakeTime <= expectedWakeTime
    }
    
    func deleteTodayLog() {
        guard let log = logs.value?.first(where: { $0.date == todayDateString() }), let expectedWakeTimeData = expectedWakeTime.value, let expectedWakeTime = expectedWakeTimeData else {
            return
        }
        deleteSleepLog(log)
    }
    
    func deleteExpectedWakeTime() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        expectedWakeTime.setIsLoading(cancelBag: cancelBag)
        db.collection("users").document(uid).updateData([
            "expectedWakeTime": FieldValue.delete()
        ]) { [weak self] error in
            if let error = error {
                self?.expectedWakeTime = .failed(.unexpectedError(error.localizedDescription))
                print("🔥 Error deleting expected wake time: \(error)")
            } else {
                print("✅ Expected wake time deleted")
                self?.expectedWakeTime = .loaded(nil)
            }
        }
    }
    
    func deleteSleepLog(_ log: SleepLog) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("sleepLogs")
            .document(log.documentID)
            .delete { [weak self] error in
                if let error = error {
                    print("🔥 Error deleting log: \(error.localizedDescription)")
                } else {
                    print("🗑️ Log deleted")
                    self?.fetchLogs()
                }
            }
    }
    
    func todaysResultText() -> String? {
        guard let log = logs.value?.first(where: { $0.date == todayDateString() }) else {
            return nil
        }
        let motivation: String
        if log.wakeTime <= log.expectedWakeTime {
            motivation = "\n👏 Сіз бүгін уақытылы ояндыңыз!"
        } else {
            let earlierTime = subtract30Minutes(from: log.sleepTime)
            motivation = """
            \n\n
    😌 Бір күн қателесу айып емес
    Бүгін түнде 30 минут бұрын (\(earlierTime)) ұйықтап көріңіз.
    """
        }
        let resultText = """
        🛌 Ұйықтаған уақыты: \(log.sleepTime)
        🌅 Оянған уақыты: \(log.wakeTime)
        😴 Ұйқы ұзақтығы: \(duration(for: log))
        """

        return resultText + motivation
    }
    
    func duration(for log: SleepLog) -> String {
        let (hour, minute) = calculateDuration(for: log)
        return "\(hour) сағат \(minute) минут"
    }

    func calculateDuration(for log: SleepLog) -> (hour: Int, minute: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let sleep = formatter.date(from: log.sleepTime),
              let wake = formatter.date(from: log.wakeTime) else {
            return (0,0)
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

        return (hour, minute)
    }
    
    func calculateTotalDuration(for logs: [SleepLog]) -> (hour: Int, minute: Int) {
        let totalSeconds = logs.reduce(0.0) { sum, log in
            let duration = calculateDuration(for: log)
            return sum + Double(duration.hour * 3600 + duration.minute * 60)
        }

        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        return (hours, minutes)
    }
    
    private func subtract30Minutes(from timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let date = formatter.date(from: timeString) else { return timeString }

        let newDate = Calendar.current.date(byAdding: .minute, value: -30, to: date)!
        return formatter.string(from: newDate)
    }
    
    func currentStrike() -> Int? {
        guard let expectedWakeTimeData = expectedWakeTime.value, let expectedWakeTime = expectedWakeTimeData else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var strike = 0
        var date = Date()
        
        while true {
            let dateString = formatter.string(from: date)
            guard let log = logs.value?.first(where: { $0.date == dateString }) else { break }
            
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
