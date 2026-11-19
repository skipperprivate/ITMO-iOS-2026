import Testing
@testable import Evently

@Suite("Feedback ViewModel")
@MainActor
struct FeedbackViewModelTests {
    @Test("Trims input and resets the form after success")
    func submitsFeedback() async {
        let spy = FeedbackRepositorySpy()
        let sut = FeedbackViewModel(repository: spy)
        sut.title = "  Ошибка  "
        sut.message = "  Описание  "

        await sut.submit()
        let call = await spy.recordedCall()

        #expect(call.count == 1)
        #expect(call.title == "Ошибка")
        #expect(call.message == "Описание")
        #expect(sut.isSuccess)
        #expect(sut.errorMessage == nil)
        #expect(sut.title.isEmpty)
        #expect(sut.message.isEmpty)
        #expect(!sut.isSending)
    }
}
