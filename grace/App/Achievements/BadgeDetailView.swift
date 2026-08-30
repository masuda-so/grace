import SwiftUI

struct BadgeDetailView: View {
  var badge: Badge

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Image(badge.details.image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 140, height: 140)
          .accessibilityHidden(true)

        Text(badge.details.title)
          .font(.title.bold())

        Text(badge.details.congratulatoryMessage)
          .font(.body)

        Spacer()
        if let timestamp = badge.timestamp {
          Text(timestamp, style: .date)
            .font(.caption2.bold())
        }
      }
      .padding()
      .frame(width: 320)
      .frame(minHeight: 410)
      .fixedSize()
      .multilineTextAlignment(.center)
      .foregroundStyle(.white)
      .background(badge.details.color.opacity(0.8))
      .clipShape(RoundedRectangle(cornerRadius: 16.0))
    }
    .scrollBounceBehavior(.basedOnSize)
    .defaultScrollAnchor(.center, for: .alignment)
  }
}

#Preview {
  BadgeDetailView(badge: .sample)
}

#Preview("Japanese language") {
  BadgeDetailView(badge: .sample)
    .environment(\.locale, Locale(identifier: "ja"))
}
