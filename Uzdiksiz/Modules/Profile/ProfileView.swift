//
//  ProfileView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 15.07.2025.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var sleepReportViewModel: SleepReportViewModel
    @ObservedObject var sleepTimeViewModel: SleepTimeViewModel
    @State private var showComingSoon = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image("profile_placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Button {
                            showComingSoon = true
                        } label: {
                            DefaultButtonView(title: "Аккаунт ашу")
                                .opacity(0.5)
                        }
                        .alert("Функция әзірленуде", isPresented: $showComingSoon) {
                            Button("Жақсы", role: .cancel) {}
                        } message: {
                            Text("""
                            Жаңа функция жақында қолжетімді болады. Сізбен бірге боламыз!
                            """)
                        }
                    }
                    HStack(spacing: 0) {
                        info(title: "\(totalSleepReports)", subtitle: "Ұйқы саны")
                        Spacer()
                        info(title: "\(averageSleepQuality)", subtitle: "Орт. сапа")
                        Spacer()
                        info(title: "\(averageSleepDurationString)", subtitle: "Орт. ұйқы")
                    }
                }.padding(.vertical, 32)
                if sleepTimeViewModel.notificationPermissionGranted != true {
                    Button {
                        sleepTimeViewModel.openAppSettings()
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.slash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    Text("Хабарламалар өшірілген")
                                        .font(.footnote.weight(.semibold))
                                        .multilineTextAlignment(.leading)
                                }
                                .foregroundColor(.textSoftWhite)
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("Параметрлерге өту")
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundColor(Color.textLightGray)
                            }
                            Text("Ұйқы уақытын еске салу үшін хабарламаларды қосыңыз. Бұл сізге уақытылы ұйықтауға көмектеседі.")
                                .font(.caption)
                                .foregroundColor(.textLightGray)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 30)
                        }
                        .padding(.vertical, 11)
                        .padding(.horizontal, 16)
                        .background {
                            Color.backgroundDeepNavy
                        }
                        .cornerRadius(16)
                        .contentShape(Rectangle())
                    }
                }
                if #available(iOS 26.0, *), sleepTimeViewModel.alarmPermissionGranted != true {
                    Button {
                        sleepTimeViewModel.openAppSettings()
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.slash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    Text("Оятқышқа рұқсат жоқ")
                                        .font(.footnote.weight(.semibold))
                                        .multilineTextAlignment(.leading)
                                }
                                .foregroundColor(.textSoftWhite)
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("Параметрлерге өту")
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundColor(Color.textLightGray)
                            }
                            Text("Оятқыш дұрыс жұмыс істеуі үшін қолданбаға оятқышты пайдалану құқығын қосу керек. Параметрлерге кіріп, рұқсат беріңіз.")
                                .font(.caption)
                                .foregroundColor(.textLightGray)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 30)
                        }
                        .padding(.vertical, 11)
                        .padding(.horizontal, 16)
                        .background {
                            Color.backgroundDeepNavy
                        }
                        .cornerRadius(16)
                        .contentShape(Rectangle())
                    }
                }
                Button {
                    sleepTimeViewModel.openSettings(state: .sleep)
                } label: {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Ұйқы баптаулары")
                                .font(.footnote.weight(.semibold))
                        }
                        .foregroundColor(.textSoftWhite)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.textSoftWhite)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 16)
                    .background {
                        Color.backgroundDeepNavy
                    }
                    .cornerRadius(16)
                    .contentShape(Rectangle())
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.horizontal, 24)
        }
        .backgroundGradient(ignoring: [.top, .horizontal])
        .navigationBarHidden(true)
    }
    
    private var totalSleepReports: Int {
        switch sleepReportViewModel.sleepReports {
        case .loaded(let reports):
            return reports.count
        default:
            return 0
        }
    }
    
    private var averageSleepQuality: Int {
        switch sleepReportViewModel.sleepReports {
        case .loaded(let reports) where !reports.isEmpty:
            let total = reports.reduce(0) { $0 + $1.quality() }
            return total / reports.count
        default:
            return 0
        }
    }
    
    private var averageSleepDurationString: String {
        switch sleepReportViewModel.sleepReports {
        case .loaded(let reports) where !reports.isEmpty:
            let totalMinutes = reports.reduce(0) { $0 + Int($1.totalSleepMinutes) }
            let averageMinutes = totalMinutes / reports.count
            let hours = averageMinutes / 60
            let minutes = averageMinutes % 60
            return "\(hours)сғ \(minutes)м"
        default:
            return "0сғ 0м"
        }
    }
    
    func info(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title).font(.title3.weight(.bold)).foregroundColor(Color.textSoftWhite)
            Text(subtitle).font(.caption.weight(.medium)).foregroundColor(Color.textLightGray)
        }
    }
}
