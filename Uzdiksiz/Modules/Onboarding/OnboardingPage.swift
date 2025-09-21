//
//  OnboardingPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 16.08.2025.
//

import SwiftUI

struct OnboardingPage: View {
    let onFinish: () -> Void
    @State var showTitle: Bool = false
    @State var showPage: Bool = false
    @State var state: OnboardingState = .welcome
    @Namespace var namespace
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if showPage {
                    HStack(spacing: 0) {
                        Button {
                            withAnimation {
                                switch state {
                                case .welcome:
                                    state = .welcome
                                case .regime:
                                    state = .welcome
                                case .history:
                                    state = .regime
                                case .areyouready:
                                    state = .history
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.body.weight(.medium))
                                .foregroundColor(.textSoftWhite)
                                .frame(width: 44, height: 44, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        Spacer()
                        Button {
                            onFinish()
                        } label: {
                            Text("Өткізу")
                                .font(.body.weight(.medium))
                                .foregroundColor(.textSoftWhite)
                                .frame(height: 44, alignment: .center)
                                .padding(.horizontal, 10)
                                .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(state == .welcome ? 0 : 1)
                    .disabled(state == .welcome)
                }
                TabView(selection: $state) {
                    welcomeView.tag(OnboardingState.welcome)
                    infoView(for: .regime).tag(OnboardingState.regime)
                    infoView(for: .history).tag(OnboardingState.history)
                    infoView(for: .areyouready).tag(OnboardingState.areyouready)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: showPage ? .always : .never))
                .toolbar(.hidden, for: .tabBar)
                if showPage {
                    DefaultButtonView(title: buttonTitle, state: state == .welcome ? .primary : .secondary) {
                        switch state {
                        case .welcome:
                            withAnimation {
                                state = .regime
                            }
                        case .regime:
                            withAnimation {
                                state = .history
                            }
                        case .history:
                            withAnimation {
                                state = .areyouready
                            }
                        case .areyouready:
                            onFinish()
                        }
                    }
                    .padding(.bottom, 32)
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity).animation(.easeInOut))
                }
            }
            .zIndex(1)
            if !showPage {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "logo", in: namespace)
                    .frame(width: 100, height: 100)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.interactiveSpring(
                                response: 0.6,
                                dampingFraction: 0.5,
                                blendDuration: 0.5)) {
                                    showPage = true
                            }
                        }
                    }
                    .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundGradient()
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .allowsHitTesting(showTitle)
    }
    
    var buttonTitle: String {
        switch state {
        case .welcome:
            "Бастау"
        case .regime:
            "Келесі"
        case .history:
            "Келесі"
        case .areyouready:
            "Кеттік"
        }
    }
    
    @ViewBuilder
    var welcomeView: some View {
            VStack(spacing: 0) {
                if showPage {
                    VStack(spacing: 24) {
                        Text("Өзгеретін уақыт келді!")
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.textLightGray)
                            .transition(.move(edge: .top).combined(with: .opacity).animation(.easeInOut))
                        VStack(spacing: 0) {
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("Uzdik")
                                    .opacity(showTitle ? 1 : 0)
                                    .offset(y: showTitle ? 0 : 20)
                                Text("siz").foregroundColor(.accentSkyIceBlue)
                                    .opacity(showTitle ? 1 : 0)
                                    .offset(y: showTitle ? 0 : 20)
                                    .animation(.interactiveSpring(
                                        response: 0.3,
                                        dampingFraction: 0.5,
                                        blendDuration: 0.5).delay(0.2), value: showTitle)
                                Text("-ге")
                                    .opacity(showTitle ? 1 : 0)
                                    .offset(y: showTitle ? 0 : 20)
                                    .animation(.interactiveSpring(
                                        response: 0.3,
                                        dampingFraction: 0.5,
                                        blendDuration: 0.5).delay(0.2), value: showTitle)
                            }
                            Text("Қош келдіңіз!")
                                .opacity(showTitle ? 1 : 0)
                                .offset(y: showTitle ? 0 : 20)
                                .animation(.interactiveSpring(
                                    response: 0.6,
                                    dampingFraction: 0.5,
                                    blendDuration: 0.5).delay(0.4), value: showTitle)
                        }
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.textSoftWhite)
                        .animation(.interactiveSpring(
                            response: 0.6,
                            dampingFraction: 0.5,
                            blendDuration: 0.5), value: showTitle)
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "logo", in: namespace)
                            .frame(width: 50, height: 50)
                    }
                    .padding(.vertical, 32)
                    .onAppear {
                        showTitle = true
                    }
                    Image("onboarding_breaking_barriers")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500, maxHeight: 500, alignment: .center)
                        .scaleEffect(showTitle ? 1 : 0.8)
                        .transition(.scale.combined(with: .opacity).animation(.easeInOut))
                        .animation(.interactiveSpring(
                            response: 0.6,
                            dampingFraction: 0.5,
                            blendDuration: 0.5), value: showTitle)
                }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    func infoView(for state: OnboardingState) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                Text(state.title)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSoftWhite)
                Text(state.description)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textLightGray)
            }
            .padding(.vertical, 32)
            Image(state.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 500, maxHeight: 500, alignment: .center)
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 32)
    }
}

enum OnboardingState: Int {
    case welcome
    case regime
    case history
    case areyouready
    
    var title: String {
        switch self {
        case .welcome:
            ""
        case .regime:
            "Тұрақты ұйқы режимі"
        case .history:
            "Ұйқы тарихы"
        case .areyouready:
            "Бастауға дайынсыз ба?"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            ""
        case .regime:
            "Біз сіздің ұйықтау және ояну уақыттарыңызды қадағалап, ұйықтарда ескертіп және оятқыш арқылы оятамыз."
        case .history:
            "Алдыңғы ұйқы деректерін талдап, ұйқы сапасын жақсартыңыз."
        case .areyouready:
            "Бүгіннен бастап бақылауды бастаңыз. Жақсы ұйқы – жақсы күннің кепілі!"
        }
    }
    
    var imageName: String {
        switch self {
        case .welcome:
            ""
        case .regime:
            "onboarding_early_morning"
        case .history:
            "onboarding_analytics"
        case .areyouready:
            "onboarding_key"
        }
    }
}
