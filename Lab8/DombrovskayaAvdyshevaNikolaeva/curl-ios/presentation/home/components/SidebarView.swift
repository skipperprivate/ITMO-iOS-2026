import SwiftUI

struct SidebarView: View {
    
    let onLogout: () -> Void
    
    @ObservedObject var viewModel: HomeViewModel
    
    init(onLogout: @escaping () -> Void, viewModel: HomeViewModel) {
        self.onLogout = onLogout
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            profileHeader
            
            Divider()
                .overlay(Color(.curlySurface))
                .padding(.vertical, 10)
            
            hairTypeCard(
                title: "Пористость",
                value: viewModel.hairPorosity,
                color: Color(.curlyOrange),
                options: UserDefaultsService.Options.porosity,
                onSelect: viewModel.setHairPorosity
            )
            
            hairTypeCard(
                title: "Толщина",
                value: viewModel.hairThickness,
                color: Color(.curlyBlue),
                options: UserDefaultsService.Options.thickness,
                onSelect: viewModel.setHairThickness
            )
            
            hairTypeCard(
                title: "Окрашенность",
                value: viewModel.hairColoring,
                color: Color(.curlyOrangeNeg),
                textColor: Color(.curlyGreen),
                options: UserDefaultsService.Options.coloring,
                onSelect: viewModel.setHairColoring
            )
            
            Divider()
                .overlay(Color(.curlySurface))
                .padding(.vertical, 10)
            
            Button(
                action: { viewModel.didTapSignOut(onSuccess: onLogout) },
                label: {
                    Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.bodySerif)
                        .foregroundStyle(Color(.curlySurface))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
            )
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding(16)
        .background(Color(.curlyDarkGreen))
        .ignoresSafeArea(edges: .bottom)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 2, y: 0)
    }
    
    private func hairTypeCard(
        title: String,
        value: String,
        color: Color,
        textColor: Color = Color(.curlySurface),
        options: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.captionSerif)
                .tracking(0.5)
                .foregroundStyle(Color(.curlySurface))
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: 22, height: 100)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { onSelect(option) }
                }
            } label: {
                Text(value)
                    .font(.bodySerif)
                    .tracking(0.3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.bottom, 10)
    }
    
    private var profileHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: viewModel.avatar)
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundStyle(Color(.curlyDarkGreen))
                .frame(width: 130, height: 130)
                .background(Color(.curlySurface))
                .clipShape(Circle())
            
            Text(viewModel.userName)
                .font(.titleSerif)
                .foregroundStyle(Color(.curlySurface))
            
            Text(viewModel.email.uppercased())
                .font(.captionSerif)
                .tracking(1)
                .foregroundStyle(Color(.curlySurface))
            
            Button(action: viewModel.didTapEditProfile) {
                Text("Редактировать")
                    .font(.bodySerif)
                    .tracking(0.6)
                    .foregroundStyle(Color(.curlySurface))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.curlyGreen))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
    }
}
