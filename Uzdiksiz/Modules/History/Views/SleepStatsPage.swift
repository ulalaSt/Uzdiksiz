//
//  SleepStatsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI

struct SleepStatsPage: View {
    @State var currentDate: Date = Date()
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "kk_KZ")
        f.dateFormat = "EEE, d MMM"
        return f
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 0) {
                Text(formatter.string(from: currentDate).capitalized)
                Spacer()
                Image(systemName: "chart.bar.xaxis")
            }
            .font(.title3.weight(.bold))
            .foregroundColor(.textLightGray)
            .padding(.horizontal, 24)
            WeekdayPicker(selectedDate: $currentDate)
            InfinitePageView(
                selection: $currentDate,
                before: { date in
                    Calendar.current.date(byAdding: .weekOfYear, value: -1, to: date) ?? date
                },
                after: { date in
                    Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
                },
                view: { date in
                    pageContent(for: date)
                })
            .frame(maxHeight: .infinity)
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
        .backgroundGradient(ignoring: [.top, .horizontal])
        .navigationBarHidden(true)
    }
    
    func pageContent(for date: Date) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 10) {
                    qualityBar(for: date)
                    sleepInfo(for: date)
                }
                .padding(.vertical, 16)
                CardRow(systemIcon: "text.bubble.fill", title: "Ұйқы жазбасы", content: {
                    Text("Бүгін той болып қалды, содан кеш ұйықтап қалдым")
                        .font(.caption)
                        .foregroundColor(.textSoftWhite)
                        .multilineTextAlignment(.leading)
                }) {
                    print("Tapped")
                }
                CardRow(systemIcon: "face.smiling", title: "Оянған күй", content: {
                    HStack(spacing: 16) {
                        moodButton(imageName: "happy_mood")
                        moodButton(imageName: "neutral_mood")
                        moodButton(imageName: "sad_mood")
                    }
                }) {
                    print("Tapped")
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    func moodButton(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundColor(.textSoftWhite)
            .frame(width: 24, height: 24)
            .padding(10)
            .background(
                Circle().fill(.white.opacity(0.1))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                print("tapped")
            }
    }
    
    func qualityBar(for date: Date) -> some View {
        VStack(spacing: 0) {
            Text("\(quality(for: date))")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(.textSoftWhite)
            Text("Cапа")
                .font(.caption)
                .foregroundColor(.textLightGray)
        }
        .frame(width: 100, height: 100)
        .background {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
            Circle()
                .trim(from: 0, to: CGFloat(quality(for: date)))
                .stroke(
                    LinearGradient(
                        colors: [.accentSkyIceBlue, .primaryOceanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // start from top
                .animation(.easeInOut, value: date)
        }
        .padding(10)
        .background {
            Circle()
                .fill(Color.white.opacity(0.05))
        }
    }
    
    func sleepInfo(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ұйқы ұзақтығы")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textLightGray)
                Group {
                    Text("6").font(.title3.weight(.bold)) + Text("сағ").font(.caption.weight(.bold)) +
                    Text("33").font(.title3.weight(.bold)) + Text("мин").font(.caption.weight(.bold))
                }
                .foregroundColor(.textSoftWhite)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Ұйқы уақыты")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textLightGray)
                Text("22:00-05:39")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.textSoftWhite)
                Text("+ 07:00-07:12")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.textLightGray)
                Text("+ 10:00-11:00")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.textLightGray)
            }
        }
        .padding(.vertical, 8)
    }
    
    func quality(for date: Date) -> Int {
        67
    }

}
