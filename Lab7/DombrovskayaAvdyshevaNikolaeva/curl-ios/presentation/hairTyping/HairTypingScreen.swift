import SwiftUI

struct HairTypingScreen: View {
    let onOpenPhotoAnalysis: () -> Void
    let onOpenPorosityText: () -> Void
    let onOpenThicknessText: () -> Void
    let onOpenColoredText: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Типизация волос")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "4A5B48"))
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: "728C6A"))
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    Text("Пройдите тест и узнайте тип ваших волос для правильного ухода и подбора средств")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "4A5B48"))
                        .lineSpacing(4)
                }
                .padding(20)
                .background(Color(hex: "F8F4ED"))
                .cornerRadius(24)

                VStack(spacing: 12) {
                    TypingFeatureCard(
                        icon: "drop.fill",
                        title: "Определение\nпористости по фото",
                        isMain: true,
                        action: onOpenPhotoAnalysis
                    )
                    TypingFeatureCard(
                        icon: "testtube.2",
                        title: "Определение\nпористости тестом",
                        action: onOpenPorosityText
                    )
                    TypingFeatureCard(
                        icon: "water.waves",
                        title: "Определение\nтолщины волос",
                        action: onOpenThicknessText
                    )
                    TypingFeatureCard(
                        icon: "paintpalette.fill",
                        title: "Информация о наличии\nокрашивания",
                        action: onOpenColoredText
                    )
                }
            }
            .padding(24)
        }
        .background(Color(hex: "F8F4ED").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(Color(hex: "4A5B48"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "person.circle")
                    .foregroundColor(Color(hex: "4A5B48"))
            }
        }
    }
}
