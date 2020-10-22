//
//  RookieWidget.swift
//  RookieWidget
//
//  Created by 유연주 on 2020/10/21.
//  Copyright © 2020 yookie. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let rookieEntry = RookieEntry(date: Date())
    
    func placeholder(in context: Context) -> RookieEntry {
        rookieEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (RookieEntry) -> ()) {
        let entry = rookieEntry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [rookieEntry]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

@main
struct RookieWidget: Widget {
    let kind: String = "RookieWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RookieEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.init("DefaultColor"))
        }
        .configurationDisplayName("Rookie of the Day-!")
        .description("Check Today's Checklist:)")
        .supportedFamilies([.systemSmall])
    }
}

struct RookieWidget_Previews: PreviewProvider {
    static var previews: some View {
        RookieEntryView(entry: RookieEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
