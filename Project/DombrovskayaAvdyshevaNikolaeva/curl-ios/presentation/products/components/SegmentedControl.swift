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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selectedIndex == index ? .white : Color(.curlyDarkGreen))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedIndex == index ? Color(.curlyGreen) : Color.clear)
                    .cornerRadius(14)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedIndex = index
                        onSelection(index)
                    }
            }
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
