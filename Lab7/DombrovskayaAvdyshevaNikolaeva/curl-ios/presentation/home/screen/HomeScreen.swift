import SwiftUI

struct HomeScreen: View {

    @StateObject private var viewModel: HomeViewModel

    init(router: HomeRouter) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(router: router))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            mainContent
                .disabled(viewModel.isSidebarOpen)
            
            if viewModel.isSidebarOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.closeSidebar() }
                    .transition(.opacity)
            }
            
            SidebarView(viewModel: viewModel)
                .frame(width: 280)
                .offset(x: viewModel.isSidebarOpen ? 0 : -280)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isSidebarOpen)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.isEditProfilePresented) {
            EditProfileView(viewModel: viewModel)
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Button(action: viewModel.openSidebar) {
                        avatarView
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 0) {
                        Text("Привет,")
                            .font(.titleSerif)
                            .foregroundStyle(Color(.curlyDarkGreen))
                        Text(viewModel.userName + "!")
                            .font(.titleSerif)
                            .foregroundStyle(Color(.curlyDarkGreen))
                    }
                }

                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 16) {
                            FeatureCard(
                                bgColor: Color(.curlyGreen),
                                textColor: Color.curlySurface,
                                title: "Проверка составов",
                                height: 280,
                                action: viewModel.didTapComposition
                            )
                            FeatureCard(
                                bgColor: Color(.curlyBlue),
                                textColor: Color.curlySurface,
                                title: "Гайд",
                                height: 132,
                                action: viewModel.didTapGuide
                            )
                        }

                        VStack(spacing: 16) {
                            FeatureCard(
                                bgColor: Color(.curlyOrange),
                                textColor: Color.curlySurface,
                                title: "Словарь",
                                height: 132,
                                action: viewModel.didTapDictionary
                            )
                            FeatureCard(
                                bgColor: Color.lightPink,
                                textColor: Color.curlyDarkGreen,
                                title: "Типизация волос",
                                height: 280,
                                action: viewModel.didTapHairTyping
                            )
                        }
                    }

                    FeatureCard(
                        bgColor: Color(.curlyLavander),
                        textColor: Color.curlySurface,
                        title: "База средств",
                        height: 132,
                        action: viewModel.didTapProducts
                    )
                }
            }
            .padding(24)
        }
        .background(Color(.curlySurface))
        .animation(.easeInOut(duration: 0.25), value: viewModel.isSidebarOpen)
    }

    private var avatarView: some View {
        Image(systemName: viewModel.avatar)
            .resizable()
            .scaledToFit()
            .padding(20)
            .foregroundStyle(Color(.curlySurface))
            .frame(width: 130, height: 130)
            .background(Color(.curlyDarkGreen))
            .clipShape(Circle())
    }
}
