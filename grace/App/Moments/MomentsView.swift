import SwiftData
import SwiftUI

struct MomentsView: View {
  @Environment(\.dynamicTypeSize) private var typeSize
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var showCreateMoment = false
  @Query(sort: \Moment.timestamp)
  private var moments: [Moment]

  static let offsetAmount: CGFloat = 70.0

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 8, pinnedViews: .sectionHeaders) {
          Section {
            pathItems
              .frame(maxWidth: .infinity)
          } header: {
            streakHeader
          }
        }
      }
      .overlay {
        if moments.isEmpty {
          ContentUnavailableView {
            Label("No moments yet!", systemImage: "heart.text.square")
          } description: {
            Text("Post a note or photo to start filling this space with gratitude.")
          } actions: {
            Button("Add Moment") { showCreateMoment = true }
              .buttonStyle(.borderedProminent)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showCreateMoment = true
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Add Moment")
          .sheet(isPresented: $showCreateMoment) {
            MomentEntryView()
          }
        }
      }
      .defaultScrollAnchor(.bottom, for: .initialOffset)
      .defaultScrollAnchor(.bottom, for: .sizeChanges)
      .defaultScrollAnchor(.top, for: .alignment)
      .navigationTitle("Grateful Moments")
    }
  }

  private var pathItems: some View {
    let suppressAnimation = reduceMotion || typeSize.isAccessibilitySize
    return ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
      NavigationLink {
        MomentDetailView(moment: moment)
      } label: {
        if typeSize.isAccessibilitySize {
          VStack(alignment: .leading, spacing: 8) {
            Text(moment.title).font(.headline)
            Text(moment.timestamp, style: .date).font(.subheadline)
          }
          .foregroundStyle(.primary)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
          .padding(.horizontal)
        } else if moment == moments.last {
          MomentHexagonView(moment: moment, layout: .large)
        } else {
          MomentHexagonView(moment: moment)
            .offset(x: sin(Double(index) * .pi / 2) * Self.offsetAmount)
        }
      }
      .scrollTransition { content, phase in
        content
          .opacity(suppressAnimation || phase.isIdentity ? 1 : 0)
          .scaleEffect(suppressAnimation || phase.isIdentity ? 1 : 0.8)
      }
    }
  }

  @ViewBuilder private var streakHeader: some View {
    let streak = StreakCalculator().calculateStreak(for: moments)
    if streak > 0 {
      HStack {
        Text(verbatim: "\(streak)")
        Text(Image(systemName: "flame.fill"))
          .foregroundStyle(.ember)
        Spacer()
      }
      .font(.subheadline)
      .padding()
    }
  }
}

#Preview {
  MomentsView()
    .sampleDataContainer()
}

#Preview("No moments") {
  MomentsView()
    .modelContainer(for: [Moment.self])
    .environment(DataContainer())
}
