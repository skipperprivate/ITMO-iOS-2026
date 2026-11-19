import SwiftUI

struct RecipeIngredientEditorRow: View {
    @Bindable var row: RecipeIngredientDraft
    let showsErrors: Bool
    var focus: FocusState<RecipeEditorField?>.Binding
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                RecipeEditorFieldView(error: showsErrors ? row.nameError : nil) {
                    TextField("Название продукта", text: $row.name)
                        .accessibilityIdentifier("recipeEditor.ingredientName")
                        .focused(focus, equals: .ingredientName(row.id))
                        .submitLabel(.next)
                        .onSubmit { focus.wrappedValue = .ingredientQuantity(row.id) }
                }
                .id(RecipeEditorField.ingredientName(row.id))

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash").frame(width: 44, height: 48)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Удалить ингредиент")
                .accessibilityIdentifier("recipeEditor.deleteIngredient")
            }
            HStack(alignment: .top, spacing: 12) {
                RecipeEditorFieldView(error: showsErrors ? row.quantityError : nil) {
                    TextField("Количество", text: $row.quantity)
                        .accessibilityIdentifier("recipeEditor.ingredientQuantity")
                        .keyboardType(.decimalPad)
                        .focused(focus, equals: .ingredientQuantity(row.id))
                }
                .id(RecipeEditorField.ingredientQuantity(row.id))
                Picker("Единица измерения", selection: $row.unit) {
                    ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .padding(.horizontal, 8)
                .frame(minWidth: 76, minHeight: 48)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 12))
            }
            if let quantity = row.sourceQuantity {
                Text("В оригинале: \(quantity). Уточни количество и единицу или убери ингредиент.")
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
