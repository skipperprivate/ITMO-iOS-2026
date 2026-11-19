import SwiftUI

struct CustomTabBarHiddenKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func customTabBarHidden(_ hidden: Bool = true) -> some View {
        preference(key: CustomTabBarHiddenKey.self, value: hidden)
    }
}
