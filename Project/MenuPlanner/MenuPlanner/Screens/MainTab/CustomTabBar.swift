import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(4)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(tab.iconName)
                    .renderingMode(.template)
                    .frame(width: 22, height: 22)

                Text(tab.title)
                    .font(AppFonts.micro)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(isSelected ? AppColors.accent : AppColors.secondaryText)
            .padding(4)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                isSelected ? AppColors.accentSoft : Color.clear,
                in: RoundedRectangle(cornerRadius: 20)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Таббар") {
    @Previewable @State var selectedTab: MainTab = .menu

    CustomTabBar(selectedTab: $selectedTab)
        .padding(24)
        .background(AppColors.background)
}
