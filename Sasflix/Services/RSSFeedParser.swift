import Foundation

nonisolated final class RSSFeedParser: NSObject, XMLParserDelegate {
	private var items: [FeedItem] = []
	private var currentElement = ""
	private var currentTitle = ""
	private var currentLink = ""
	private var currentPublicationDate = ""
	private var currentContent = ""
	private var currentAuthor = ""
	private var currentEnclosureURL = ""
	private var isInsideItem = false

	func parse(_ data: Data) throws -> [FeedItem] {
		items = []

		let parser = XMLParser(data: data)
		parser.delegate = self
		parser.shouldProcessNamespaces = false
		parser.shouldReportNamespacePrefixes = false
		parser.shouldResolveExternalEntities = false

		if parser.parse() {
			return items
		}

		throw parser.parserError ?? URLError(.cannotParseResponse)
	}

	func parser(
		_ parser: XMLParser,
		didStartElement elementName: String,
		namespaceURI: String?,
		qualifiedName qName: String?,
		attributes attributeDict: [String: String] = [:]
	) {
		currentElement = qName ?? elementName

		if currentElement == "item" {
			isInsideItem = true
			currentTitle = ""
			currentLink = ""
			currentPublicationDate = ""
			currentContent = ""
			currentAuthor = ""
			currentEnclosureURL = ""
		}

		if isInsideItem, currentElement == "enclosure", let url = attributeDict["url"] {
			currentEnclosureURL = url
		}
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		appendText(string)
	}

	func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
		guard let text = String(data: CDATABlock, encoding: .utf8) else { return }
		appendText(text)
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		let endedElement = qName ?? elementName

		guard isInsideItem else { return }

		if endedElement == "item" {
			appendCurrentItem()
			isInsideItem = false
			return
		}

		currentElement = ""
	}

	private func appendText(_ string: String) {
		guard isInsideItem else { return }

		switch currentElement {
		case "title":
			currentTitle += string
		case "link":
			currentLink += string
		case "pubDate":
			currentPublicationDate += string
		case "content:encoded", "encoded":
			currentContent += string
		case "author", "dc:creator", "creator":
			currentAuthor += string
		default:
			break
		}
	}

	private func appendCurrentItem() {
		let title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
		let linkText = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
		let author = currentAuthor.trimmingCharacters(in: .whitespacesAndNewlines)

		guard !title.isEmpty, let link = URL(string: linkText) else { return }

		let item = FeedItem(
			title: title,
			link: link,
			publishedAt: parseDate(currentPublicationDate) ?? .distantPast,
			posterURL: parsePosterURL(),
			author: author.isEmpty ? nil : author
		)

		items.append(item)
	}

	private func parseDate(_ text: String) -> Date? {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
		return formatter.date(from: text.trimmingCharacters(in: .whitespacesAndNewlines))
	}

	private func parsePosterURL() -> URL? {
		if let enclosureURL = URL(string: currentEnclosureURL.trimmingCharacters(in: .whitespacesAndNewlines)) {
			return enclosureURL
		}

		return extractImageURL(fromHTML: currentContent)
	}

	private func extractImageURL(fromHTML html: String) -> URL? {
		for marker in ["src=\"", "src='"] {
			guard let startRange = html.range(of: marker) else { continue }
			let start = startRange.upperBound
			let terminator: Character = marker.hasSuffix("\"") ? "\"" : "'"

			guard let end = html[start...].firstIndex(of: terminator) else { continue }
			return URL(string: String(html[start..<end]))
		}

		return nil
	}
}
