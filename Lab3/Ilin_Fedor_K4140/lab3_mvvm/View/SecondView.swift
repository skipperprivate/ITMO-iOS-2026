import SwiftUI

struct SecondView: View {
    var body: some View {
        VStack(spacing: 16) {

            Text("Это второй экран")
                .font(.title)
                .fontWeight(.semibold)
        }
        .padding()
        .navigationTitle("Второй экран")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SecondView()
        }
    }
}
