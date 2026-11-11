struct HomeScreenRouterAdapter: HomeRouter {
    let onComposition: () -> Void
    let onGuide: () -> Void
    let onDictionary: () -> Void
    let onHairTyping: () -> Void
    let onProducts: () -> Void

    func openComposition() { onComposition() }
    func openGuide()       { onGuide() }
    func openDictionary()  { onDictionary() }
    func openHairTyping()  { onHairTyping() }
    func openProducts()    { onProducts() }
}
