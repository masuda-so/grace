import SwiftUI

/// Presents reusable content in the family-wide material card style.
struct CardView<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(
        .thinMaterial,
        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
      )
  }
}
