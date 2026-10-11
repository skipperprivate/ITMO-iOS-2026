import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = RandomNumberViewModel()

    private let imageURLs: [URL] = [
        URL(string: "https://ccdn.goldapple.ru/p/p/99000176906/web/696d6741646434566572746963616c5f30643663366361366664313434663264613136353036396331626666623339658df12a8fa1fa544fullhd.webp")!,
        URL(string: "https://ccdn.goldapple.ru/p/p/19000439440/web/696d6741646434566572746963616c5f62373462306133613238363534343132383733376363356663306138363330648df11a556b0be39fullhd.webp")!,
        URL(string: "https://ccdn.goldapple.ru/p/p/19000447623/web/696d6741646433566572746963616c5f39353263393466326462306134613438613637356437356465643334653833318df0dc170af0e05fullhd.webp")!,
        URL(string: "https://ccdn.goldapple.ru/p/p/19000349169/web/696d6741646433566572746963616c5f37343733313861343763666534663833613037623665343262633632393162618df0db4f043156bfullhd.webp")!,
        URL(string: "https://ccdn.goldapple.ru/p/p/19000521143/web/696d6741646433566572746963616c5f37313238396136643039636534663638383530303230346234346661376266308df1b254dabf872fullhd.webp")!,
        URL(string: "https://cdn-01.goldapple.ru/p/p/19000109705/web/696d6741646433566572746963616c5f36366166626665303438326634323432383566393338393163376632646438338df0dc8171ddb74fullhd.webp")!,
        URL(string: "https://cdn-01.goldapple.ru/p/p/19000109704/web/696d6741646433566572746963616c5f65353131646235653932333734386130383166383631623532646438313138378df0cfb3c58192dfullhd.webp")!,
        URL(string: "https://cdn-01.goldapple.ru/p/p/89312400001/web/696d6741646432566572746963616c5f31333135326264353830613334616533386433383463386439356462323066328df0d8d255aaca9fullhd.webp")!
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Текущее число:")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(viewModel.randomNumber)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(minWidth: 120, minHeight: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)

                HStack(spacing: 20) {
                    VStack {
                        Text("Всего")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(viewModel.generationCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    VStack {
                        Text("Чётных")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(viewModel.evenCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    VStack {
                        Text("Сумма чётных")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(viewModel.evenSum)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                if viewModel.isRunning {
                    Button {
                        viewModel.stopGeneration()
                    } label: {
                        Text("⏹ Остановить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    Button {
                        viewModel.startGeneration()
                    } label: {
                        Text("Запустить поток")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                NavigationLink {
                    HistoryView()
                } label: {
                    Text("История")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink {
                    ImageGalleryView(urls: imageURLs)
                } label: {
                    Text("Картинки")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }
}
