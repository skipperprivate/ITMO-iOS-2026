//
//  RepositoryError+Views.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import SwiftUI

// Kept out of the components' files: preview instrumentation can't compile delegating inits there.
// "Повторить" is offered only where retrying can help.
extension StateMessageView {
    init(error: RepositoryError, retry: (() -> Void)?) {
        self.init(
            title: error.title,
            message: error.message,
            systemImage: error.symbolName,
            retry: error.isRetryable ? retry : nil
        )
    }
}

extension StatusBanner {
    init(error: RepositoryError, retry: (() -> Void)?) {
        self.init(text: error.bannerText, systemImage: error.symbolName, action: error.isRetryable ? retry : nil)
    }
}
