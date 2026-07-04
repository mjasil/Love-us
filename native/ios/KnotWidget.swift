// iOS home-screen widget for Knot (WidgetKit).
// Add a Widget Extension target named "KnotWidget" in Xcode/Codemagic,
// enable App Groups (group.com.flovex.knot) on BOTH app and widget targets,
// then replace the generated file with this one.
import WidgetKit
import SwiftUI

struct Entry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: .now, image: nil) }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(loadEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = loadEntry()
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800))))
    }
    private func loadEntry() -> Entry {
        let defaults = UserDefaults(suiteName: "group.com.flovex.knot")
        if let urlStr = defaults?.string(forKey: "latest_url"),
           let url = URL(string: urlStr),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            return Entry(date: .now, image: img)
        }
        return Entry(date: .now, image: nil)
    }
}

struct KnotWidgetView: View {
    let entry: Entry
    var body: some View {
        if let img = entry.image {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            ZStack {
                Color(red: 0.11, green: 0.08, blue: 0.09)
                Image(systemName: "heart.fill")
                    .foregroundColor(Color(red: 0.91, green: 0.47, blue: 0.54))
                    .font(.largeTitle)
            }
        }
    }
}

@main
struct KnotWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KnotWidget", provider: Provider()) { entry in
            KnotWidgetView(entry: entry)
        }
        .configurationDisplayName("Knot")
        .description("Your partner's latest drop.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}
