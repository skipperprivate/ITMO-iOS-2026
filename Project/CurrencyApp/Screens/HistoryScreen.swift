//  HistoryScreen.swift
//  Экран «История курса»: график за выбранный период и сводка.


import SwiftUI
import CurrencyCore

struct HistoryScreen: View {

    let rate: Rate
    let library: RateLibrary

    /// Создаётся при появлении экрана: модели нужна валюта, известная только здесь.
    @State private var model: HistoryModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                заголовок
                if let model {
                    выборСрока(model)
                    содержимое(model)
                }
            }
            .padding()
        }
        .navigationTitle(rate.code)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if model == nil {
                model = HistoryModel(rate: rate, library: library)
            }
            await model?.load()
        }
    }

    //  MARK: - Части экрана

    private var заголовок: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rate.name)
                .font(.title3)
            Text("Сейчас \(Converter.rateText(rate))")
                .font(.headline)
                .monospacedDigit()
            if rate.nominal != 1 {
                //  Иначе цифры на графике не сойдутся с курсомна са йте ЦБ, который указан за номинал.
                Text("Курс ЦБ указан за \(rate.nominal) единиц")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private func выборСрока(_ model: HistoryModel) -> some View {
        //  Связь собрана вручную: смена периода должна И запомнить выбор И перезагрузить данные.
        Picker("Период", selection: Binding(
            get: { model.period },
            set: { new in Task { await model.choose(new) } }
        )) {
            ForEach(HistoryPeriod.allCases) { срок in
                Text(срок.title).tag(срок)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private func содержимое(_ model: HistoryModel) -> some View {
        switch model.phase {
        case .idle, .loading:
            Ожидание(текст: "Загружаем историю…")
                .frame(maxWidth: .infinity)

        case .failed(let текст):
            ПлохойСлучай(текст: текст) {
                await model.load()
            }

        case .ready:
            VStack(alignment: .leading, spacing: 16) {
                График(точки: model.points01)
                    .frame(height: 200)

                if let подписи = model.axisLabels {
                    HStack {
                        Text(подписи.left)
                        Spacer()
                        Text(подписи.right)
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }

                итоги(model)
            }
        }
    }

    private func итоги(_ model: HistoryModel) -> some View {
        VStack(spacing: 10) {
            строкаИтога("Изменение за период",
                        значение: model.changeText ?? "—",
                        стрелка: model.grew)
            Divider()
            строкаИтога("Самый низкий курс",
                        значение: model.minimumText ?? "—",
                        стрелка: nil)
            Divider()
            строкаИтога("Самый высокий курс",
                        значение: model.maximumText ?? "—",
                        стрелка: nil)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func строкаИтога(_ название: String,
                             значение: String,
                             стрелка: Bool?) -> some View {
        HStack {
            Text(название)
                .foregroundStyle(Color.secondary)
            Spacer()
            if стрелка != nil {
                Стрелка(вверх: стрелка, подпись: значение)
            } else {
                Text(значение)
                    .monospacedDigit()
            }
        }
        .font(.subheadline)
    }
}

//  MARK: - График

struct График: View {

    let точки: [(x: Double, y: Double)]

    var body: some View {
        GeometryReader { место in
            let ширина = место.size.width
            let высота = место.size.height

            if точки.count > 1 {
                ZStack {
                    путь(ширина: ширина, высота: высота,
                         замкнуть: true)
                        .fill(Color.accentColor.opacity(0.15))

                    путь(ширина: ширина, высота: высота,
                         замкнуть: false)
                        .stroke(Color.accentColor, lineWidth: 2)
                }
            } else {
                Text("Нет точек для графика")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .frame(width: ширина, height: высота)
            }
        }
    }

    private func путь(ширина: CGFloat, высота: CGFloat,
                      замкнуть: Bool) -> Path {
        var линия = Path()

        for (номер, точка) in точки.enumerated() {
            let x = ширина * CGFloat(точка.x)
            let y = высота * CGFloat(1 - точка.y)
            //  Поля сверху и снизу, чтобы линия не прилипла к краям.
            let сжатое = y * 0.9 + высота * 0.05
            let место = CGPoint(x: x, y: сжатое)

            if номер == 0 {
                линия.move(to: место)
            } else {
                линия.addLine(to: место)
            }
        }

        if замкнуть {
            линия.addLine(to: CGPoint(x: ширина, y: высота))
            линия.addLine(to: CGPoint(x: 0, y: высота))
            линия.closeSubpath()
        }
        return линия
    }
}
