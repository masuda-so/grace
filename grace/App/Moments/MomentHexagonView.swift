import SwiftUI

struct MomentHexagonView: View {
  var moment: Moment
  @State var layout: HexagonLayout = .standard
  @Environment(\.locale) private var locale

  var body: some View {
    Hexagon(layout: layout, moment: moment) {
      hexagonContent()
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(moment.title))
    .accessibilityValue(Text(accessibilityValue))
  }

  private func hexagonContent() -> some View {
    ZStack(alignment: .bottom) {
      if showImage {
        Color.clear
        contentStack()
          .frame(maxWidth: .infinity)
          .padding(.top, 8)
          .background(.ultraThinMaterial)
      } else {
        Color.ember
        contentStack()
          .frame(height: layout.size * 0.80)
      }

      Text(
        moment.timestamp.formatted(
          .dateTime.locale(locale)
            .month(.abbreviated).day()
        )
      )
      .font(.footnote)
      .padding(.bottom, layout.size * 0.08)
      .frame(maxWidth: layout.size / 3)
      .frame(maxHeight: layout.timestampHeight)
    }
    .foregroundStyle(.white)
  }

  private func contentStack() -> some View {
    VStack(alignment: .leading) {
      Text(moment.title)
        .font(layout.titleFont)
      if !moment.note.isEmpty, !showImage {
        Text(moment.note)
          .font(layout.bodyFont)
      }
    }
    .frame(maxWidth: layout.size * 0.80)
    .frame(maxHeight: layout.size * (showImage ? 0.15 : 0.50))
    .padding(.bottom, layout.size * layout.textBottomPadding)
    .fixedSize(horizontal: false, vertical: true)
  }

  private var showImage: Bool {
    moment.image != nil
  }

  private var accessibilityValue: String {
    let date = moment.timestamp.formatted(
      .dateTime.locale(locale).month(.abbreviated).day()
    )
    let details =
      moment.note.isEmpty
      ? date : String(localized: "\(moment.note), \(date)")
    return showImage ? String(localized: "\(details), includes a photo") : details
  }
}

#Preview {
  ScrollView {
    MomentHexagonView(moment: Moment.imageSample)
    MomentHexagonView(moment: Moment.imageSample, layout: .large)
    MomentHexagonView(moment: Moment.sample)
    MomentHexagonView(moment: Moment.sample, layout: .large)
  }
}

#Preview("English language, region Great Britian") {
  MomentHexagonView(moment: Moment.imageSample)
    .environment(\.locale, Locale(identifier: "en_GB"))
}

#Preview("Spanish language") {
  MomentHexagonView(moment: Moment.imageSample)
    .environment(\.locale, Locale(identifier: "es"))
}
