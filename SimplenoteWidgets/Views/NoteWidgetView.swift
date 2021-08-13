import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
    var entry: NoteWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    Text(entry.title)
                        .widgetHeader(widgetFamily,
                                      color: Color(for: colorScheme, light: .gray100, dark: .white))
                    Text(entry.content)
                        .subheadline(color: Color(for: colorScheme, light: .gray100, dark: .white))
                }
                .filling()
                .padding([.leading, .trailing, .top], Sizes.overallPadding)
                .ignoresSafeArea()
                .widgetURL(entry.url)
            }
            .background(Color(for: colorScheme, light: .white, dark: .darkGray1))
        }
    }
}

private struct Sizes {
    static let overallPadding = CGFloat(20)
}

private struct Constants {
    static let linkUrlBase = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/"
}

struct NoteWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NoteWidgetView(entry: NoteWidgetEntry(
                            date: Date(),
                            title: DemoContent.singleNoteTitle,
                            content: DemoContent.singleNoteContent,
                            url: DemoContent.demoURL))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NoteWidgetView(entry: NoteWidgetEntry(
                            date: Date(),
                            title: DemoContent.singleNoteTitle,
                            content: DemoContent.singleNoteContent,
                            url: DemoContent.demoURL))
                .previewContext(WidgetPreviewContext(family: .systemMedium)).colorScheme(.dark)
        }
    }
}