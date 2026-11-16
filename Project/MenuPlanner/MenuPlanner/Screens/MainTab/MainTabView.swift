//
//  MainTabView.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import SwiftData
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .menu
    @State private var isTabBarHiddenByScreen = false
    @State private var barHeight: CGFloat = 80
    @State private var isKeyboardVisible = false

    private var isTabBarHidden: Bool {
        isKeyboardVisible || isTabBarHiddenByScreen
    }

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedTab) {
                Tab("Меню", image: MainTab.menu.iconName, value: MainTab.menu) {
                    placeholder(for: .menu)
                }

                Tab("Рецепты", image: MainTab.recipes.iconName, value: MainTab.recipes) {
                    NavigationStack {
                        RecipesView()
                    }
                }

                Tab("Покупки", image: MainTab.shopping.iconName, value: MainTab.shopping) {
                    placeholder(for: .shopping)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.bottomBarInset, isTabBarHidden ? 0 : barHeight + geometry.safeAreaInsets.bottom)
            .ignoresSafeArea(.container, edges: isTabBarHiddenByScreen ? [] : .bottom)
            .onPreferenceChange(CustomTabBarHiddenKey.self) { isTabBarHiddenByScreen = $0 }
            .overlay(alignment: .bottom) {
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background {
                        LinearGradient(
                            stops: [
                                .init(color: AppColors.background.opacity(0), location: 0),
                                .init(color: AppColors.background.opacity(0.9), location: 0.35),
                                .init(color: AppColors.background, location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                        .padding(.top, -20)
                        .ignoresSafeArea(.container, edges: .bottom)
                        .allowsHitTesting(false)
                    }
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { barHeight = $0 }
                    .opacity(isTabBarHidden ? 0 : 1)
                    .allowsHitTesting(!isTabBarHidden)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }

    private func placeholder(for tab: MainTab) -> some View {
        NavigationStack {
            Text(tab.title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview("Вкладки") {
    MainTabView()
        .modelContainer(for: AppSchema.models, inMemory: true)
}

#Preview("Вкладки · тёмная тема") {
    MainTabView()
        .preferredColorScheme(.dark)
        .modelContainer(for: AppSchema.models, inMemory: true)
}

private struct BottomBarInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var bottomBarInset: CGFloat {
        get { self[BottomBarInsetKey.self] }
        set { self[BottomBarInsetKey.self] = newValue }
    }
}
