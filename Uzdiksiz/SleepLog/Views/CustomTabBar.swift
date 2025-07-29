//
//  CustomTabBar.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 29.07.2025.
//
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabState
    @Namespace var namespace
    var body: some View {
        HStack(spacing: 10) {
            tabButton(icon: "house.fill", state: .home, label: "Басты бет")
            tabButton(icon: "calendar.badge.clock", state: .history, label: "Ұйқы тарихы")
            tabButton(icon: "person.fill", state: .profile, label: "Профиль")
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color(red: 35 / 255, green: 41 / 255, blue: 53 / 255)))
        .padding(.vertical, 16)
    }

    func tabButton(icon: String, state: TabState, label: String) -> some View {
        Button(action: {
            withAnimation(.interactiveSpring(
                response: 0.3,
                dampingFraction: 0.5,
                blendDuration: 0.5)) {
                selectedTab = state
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: selectedTab == state ? 17 : 16, height: selectedTab == state ? 17 : 16, alignment: .center)
                    .foregroundColor(selectedTab == state ? .white : Color(red: 171 / 255, green: 173 / 255, blue: 179 / 255))
                    .animation(.interactiveSpring(
                        response: 0.3,
                        dampingFraction: 0.7,
                        blendDuration: 0.5), value: selectedTab)
                if selectedTab == state {
                    Text(label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedTab == state ? .white : Color(red: 171 / 255, green: 173 / 255, blue: 179 / 255))
                        .transition(.scale(scale: 0.5).combined(with: .opacity).animation(.interactiveSpring(
                            response: 0.3,
                            dampingFraction: 0.5,
                            blendDuration: 0.5)))
                }
            }
            .padding(8)
        }
        .contentShape(Rectangle())
        .background {
            if selectedTab == state {
                Capsule()
                    .fill(Color(red: 62 / 255, green: 70 / 255, blue: 85 / 255))
                    .matchedGeometryEffect(id: "tabbar_bg", in: namespace)
            }
        }
    }
}

enum TabState: String, Equatable, CaseIterable, Identifiable {
    case home
    case history
    case profile
    
    var id: Self { self }
}
