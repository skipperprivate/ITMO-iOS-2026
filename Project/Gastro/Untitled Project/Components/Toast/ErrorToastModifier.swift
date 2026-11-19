import SwiftUI

private struct ErrorToastModifier: ViewModifier {
    let message: ToastMessage?
    let onDismiss: (UUID) -> Void

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let message {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .accessibilityHidden(true)
                    Text(message.text)
                        .accessibilityIdentifier("toast.message")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        onDismiss(message.id)
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Закрыть ошибку")
                    .accessibilityIdentifier("toast.dismiss")
                }
                .foregroundStyle(.white)
                .padding(16)
                .background(Color(red: 0.65, green: 0.08, blue: 0.10), in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6, y: 3)
                .padding()
                .task(id: message.id) {
                    do {
                        try await Task.sleep(for: .seconds(5))
                        try Task.checkCancellation()
                        onDismiss(message.id)
                    } catch {
                        // A new toast or leaving the screen cancels the timer.
                    }
                }
            }
        }
    }
}

extension View {
    func errorToast(_ message: ToastMessage?, onDismiss: @escaping (UUID) -> Void) -> some View {
        modifier(ErrorToastModifier(message: message, onDismiss: onDismiss))
    }
}
