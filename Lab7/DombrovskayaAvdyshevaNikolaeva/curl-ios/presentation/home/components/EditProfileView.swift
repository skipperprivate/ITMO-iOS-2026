import SwiftUI

struct EditProfileView: View {

    @ObservedObject var viewModel: HomeViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 56), spacing: 12)
    ]

    private let avatarOptions: [String] = UserDefaultsService.avatarOptions

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    avatarSection
                    Divider().overlay(Color(.curlyDarkGreen).opacity(0.2))
                    nameField
                    emailField
                    Spacer(minLength: 0)
                }
                .padding(20)
            }
            .background(Color("CurlySurface").ignoresSafeArea())
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { viewModel.didTapCancelEditProfile() }
                        .foregroundStyle(Color(.curlyDarkGreen))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { viewModel.didTapSaveProfile() }
                        .fontWeight(.semibold)
                        .foregroundStyle(saveButtonColor)
                        .disabled(!viewModel.isDraftValid)
                }
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            previewAvatar
            avatarGrid
        }
        .frame(maxWidth: .infinity)
    }

    private var previewAvatar: some View {
        Image(systemName: viewModel.draftAvatar)
            .resizable()
            .scaledToFit()
            .padding(20)
            .foregroundStyle(Color(.curlyDarkGreen))
            .frame(width: 100, height: 100)
            .background(Color(.curlySurface))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.curlyGreen), lineWidth: 2))
    }

    private var avatarGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(avatarOptions, id: \.self) { symbol in
                AvatarCell(
                    symbol: symbol,
                    isSelected: viewModel.draftAvatar == symbol
                ) {
                    viewModel.didSelectDraftAvatar(symbol)
                }
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Имя")
                .font(.captionSerif)
                .foregroundStyle(Color(.curlyDarkGreen))

            TextField("Имя", text: $viewModel.draftName)
                .font(.bodySerif)
                .foregroundStyle(Color(.curlyDarkGreen))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.curlySurface))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.curlyDarkGreen).opacity(0.25), lineWidth: 1)
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.captionSerif)
                .foregroundStyle(Color(.curlyDarkGreen))

            TextField("EMAIL@MAIL.COM", text: $viewModel.draftEmail)
                .font(.bodySerif)
                .foregroundStyle(Color(.curlyDarkGreen))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.curlySurface))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.curlyDarkGreen).opacity(0.25), lineWidth: 1)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
        }
    }

    private var saveButtonColor: Color {
        viewModel.isDraftValid
        ? Color(.curlyGreen)
        : Color(.curlyDarkGreen).opacity(0.3)
    }
}
