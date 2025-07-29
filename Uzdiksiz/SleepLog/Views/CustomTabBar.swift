//
//  CustomTabBar.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 29.07.2025.
//
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace var namespace
    var body: some View {
        HStack(spacing: 10) {
            tabButton(icon: "house.fill", index: 0, label: "Басты бет")
            tabButton(icon: "person.fill", index: 1, label: "Профиль")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color(red: 35 / 255, green: 41 / 255, blue: 53 / 255)))
        .padding(.vertical, 16)
    }

    func tabButton(icon: String, index: Int, label: String) -> some View {
        Button(action: {
            withAnimation(.interactiveSpring(
                response: 0.3,
                dampingFraction: 0.5,
                blendDuration: 0.5)) {
                selectedTab = index
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: selectedTab == index ? 16 : 14, height: selectedTab == index ? 16 : 14, alignment: .center)
                    .foregroundColor(selectedTab == index ? .white : Color(red: 171 / 255, green: 173 / 255, blue: 179 / 255))
                    .animation(.interactiveSpring(
                        response: 0.3,
                        dampingFraction: 0.7,
                        blendDuration: 0.5), value: selectedTab)
                if selectedTab == index {
                    Text(label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedTab == index ? .white : Color(red: 171 / 255, green: 173 / 255, blue: 179 / 255))
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
            if selectedTab == index {
                Capsule()
                    .fill(Color(red: 62 / 255, green: 70 / 255, blue: 85 / 255))
                    .matchedGeometryEffect(id: "tabbar_bg", in: namespace)
            }
        }
    }
}
