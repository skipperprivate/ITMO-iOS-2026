import SwiftUI

struct OnboardingView: View {

    let onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()

                Text("Добро пожаловать в Evently")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Находите интересные мероприятия и сохраняйте их.")
                    .foregroundStyle(.purple)
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    onFinish()
                } label: {
                    Text("Продолжить")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .accessibilityIdentifier("onboarding.continue")
                .buttonStyle(.glassProminent)
                .tint(.purple)
            }
            .padding(.all, 20)
        }
    }
}
