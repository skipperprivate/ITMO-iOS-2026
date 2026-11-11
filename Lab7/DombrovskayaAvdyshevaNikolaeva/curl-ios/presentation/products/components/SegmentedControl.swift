import SwiftUI

struct SegmentedControl: View {
    let items: [String]
    var defaultSelectedIndex: Int = 0
    let onSelection: (Int) -> Void

    @State private var selectedIndex: Int

    init(
        items: [String],
        defaultSelectedIndex: Int = 0,
        onSelection: @escaping (Int) -> Void
    ) {
        self.items = items
        self.defaultSelectedIndex = defaultSelectedIndex
        self.onSelection = onSelection
        _selectedIndex = State(initialValue: defaultSelectedIndex)
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .font(.custom("Golos", size: 14))
                    .foregroundColor(selectedIndex == index ? .lightBeige : .darkGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedIndex == index ? Color.brightPink : Color.clear
                    )
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedIndex = index
                        onSelection(index)
                    }
            }
        }
        .padding(4)
        .background(Color.lightBeige)
        .cornerRadius(12)
    }
}
