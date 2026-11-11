import SwiftUI

struct HomeScreen: View {
    let onOpenComposition: () -> Void
    let onOpenGuide: () -> Void
    let onOpenDictionary: () -> Void
    let onOpenHairTyping: () -> Void
    let onOpenProducts: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Привет!")
                    .font(.largeTitle)
                    .foregroundStyle(Color.darkGreen)

                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 16) {
                            FeatureCard(
                                color: .lightPink,
                                title: "Проверка составов",
                                height: 280,
                                action: onOpenComposition
                            )
                            FeatureCard(
                                color: .darkGreen,
                                title: "Гайд",
                                height: 132,
                                action: onOpenGuide
                            )
                        }

                        VStack(spacing: 16) {
                            FeatureCard(
                                color: .accentPink,
                                title: "Словарь",
                                height: 132,
                                action: onOpenDictionary
                            )
                            FeatureCard(
                                color: .lightGreen,
                                title: "Типизация волос",
                                height: 280,
                                action: onOpenHairTyping
                            )
                        }
                    }

                    FeatureCard(
                        color: .brightPink,
                        title: "База средств",
                        height: 132,
                        action: onOpenProducts
                    )
                }
            }
            .padding(24)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}
