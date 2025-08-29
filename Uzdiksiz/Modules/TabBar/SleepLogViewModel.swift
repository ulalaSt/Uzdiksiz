//
//  SleepLogViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 13.07.2025.
//
import FirebaseFirestore
import FirebaseAuth
import Combine

class SleepLogViewModel: ObservableObject {
    @Published var logs: Loadable<[SleepLog]> = .notRequested
    @Published var sleepReports: Loadable<[SleepReport]> = .notRequested
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
    
    
    init() {
        fetchLogs()
        fetchExpectedWakeTime()
        sleepReports = .isLoading(last: nil, cancelBag: CancelBag())
        
        SleepSessionDbService.shared.reports()
            .map(Loadable.loaded)
            .receive(on: DispatchQueue.main)
            .assign(to: &$sleepReports)
    }
    
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
                
                Task {
                    do {
                        let service = SleepSessionDbService.shared
                        let existing = try await service.fetchReports()
                        if !existing.isEmpty {
                            for each in existing {
                                print(each.debugDescription)
                            }
                            try await service.deleteAllReports()
                        }
                        
                        print("📥 Importing \(logs.count) logs into Core Data...")
                        
                        for log in logs {
                            guard let dateKey = parseDateKey(log.date),
                                  let (sh, sm) = parseTime(log.sleepTime),
                                  let (eh, em) = parseTime(log.wakeTime)
                            else { continue }
                            
                            _ = try await service.createSleepSession(
                                dateKey: dateKey,
                                startTime: Time(hour: sh, minute: sm),
                                endTime: Time(hour: eh, minute: em)
                            )
                        }
                    } catch {
                        print("⚠️ Import failed: \(error)")
                    }
                }
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
        return nil
//        guard let log = logs.value?.first(where: { $0.date == todayDateString() }) else {
//            return nil
//        }
//        let motivation: String
//        if log.wakeTime <= log.expectedWakeTime {
//            motivation = "\n👏 Сіз бүгін уақытылы ояндыңыз!"
//        } else {
//            let earlierTime = subtract30Minutes(from: log.sleepTime)
//            motivation = """
//            \n\n
//    😌 Бір күн қателесу айып емес
//    Бүгін түнде 30 минут бұрын (\(earlierTime)) ұйықтап көріңіз.
//    """
//        }
//        let resultText = """
//        🛌 Ұйықтаған уақыты: \(log.sleepTime)
//        🌅 Оянған уақыты: \(log.wakeTime)
//        😴 Ұйқы ұзақтығы: \(duration(for: log))
//        """
//
//        return resultText + motivation
    }
    
    func duration(for session: SleepSession) -> String {
        let (hour, minute) = calculateDuration(for: session)
        return "\(hour) сағат \(minute) минут"
    }

    func calculateDuration(for session: SleepSession) -> (hour: Int, minute: Int) {
        let startMinutes = Int(session.startHour) * 60 + Int(session.startMinute)
        let endMinutes   = Int(session.endHour) * 60 + Int(session.endMinute)

        // Handle overnight sleep (e.g. 22:00 → 07:00 next day)
        let durationMinutes: Int
        if endMinutes >= startMinutes {
            durationMinutes = endMinutes - startMinutes
        } else {
            durationMinutes = (24 * 60 - startMinutes) + endMinutes
        }

        let hour = durationMinutes / 60
        let minute = durationMinutes % 60
        return (hour, minute)
    }
    
    func calculateTotalDuration(for logs: [SleepLog]) -> (hour: Int, minute: Int) {
        var totalMinutes = 0
        
        for log in logs {
            if let (h, m) = log.durationHM {
                totalMinutes += h * 60 + m
            }
        }
        
        return (totalMinutes / 60, totalMinutes % 60)
    }

    func calculateTotalDuration(for reports: [SleepReport]) -> (hour: Int, minute: Int) {
        let totalSeconds = reports.reduce(0.0) { sum, report in
            guard let sessions = report.sessions as? Set<SleepSession> else { return sum }
            let reportSeconds = sessions.reduce(0.0) { sSum, session in
                let (h, m) = calculateDuration(for: session)
                return sSum + Double(h * 3600 + m * 60)
            }
            return sum + reportSeconds
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

    func exportSleepLogsCSV(logs: [SleepLog]) {
        let csvString = sleepLogsToCSV(logs: logs)
        let fileName = "SleepLogsExport.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
            
        } catch {
            print("Failed to save CSV: \(error.localizedDescription)")
        }
    }
    
    func sleepLogsToCSV(logs: [SleepLog]) -> String {
        var csv = "Date,SleepTime,WakeTime,ExpectedWakeTime,ReasonId,CustomReason,CreatedAt,DocumentID\n"
        let dateFormatter = ISO8601DateFormatter()
        
        for log in logs {
            let customReason = log.customReason?.replacingOccurrences(of: ",", with: " ") ?? ""
            let createdAt = dateFormatter.string(from: log.createdAt)
            let reasonId = log.reasonId != nil ? "\(log.reasonId!)" : ""
            
            csv += "\(log.date),\(log.sleepTime),\(log.wakeTime),\(log.expectedWakeTime),\(reasonId),\(customReason),\(createdAt),\(log.documentID)\n"
        }
        
        return csv
    }
    
    func date(from dateKey: Int32) -> Date? {
        let key = Int(dateKey)
        let year = key / 10000
        let month = (key % 10000) / 100
        let day = key % 100
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)
    }
}


private func parseDateKey(_ str: String) -> Int32? {
    // str = "yyyy-MM-dd" → Int32(yyyyMMdd)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: str) else { return nil }
    
    let calendar = Calendar(identifier: .gregorian)
    let y = calendar.component(.year, from: date)
    let m = calendar.component(.month, from: date)
    let d = calendar.component(.day, from: date)
    return Int32(y * 10000 + m * 100 + d)
}

private func parseTime(_ str: String) -> (Int, Int)? {
    // str = "HH:mm"
    let parts = str.split(separator: ":")
    guard parts.count == 2,
          let h = Int(parts[0]),
          let m = Int(parts[1]) else {
        return nil
    }
    return (h, m)
}
