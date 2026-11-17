
import SwiftUI
import FirebaseFirestore

struct ExploreView: View {

    // MARK: - State

    @State private var articles: [EcoNewsItem] = []
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?

    // MARK: - Appearance

    private let green = Color(
        red: 0.17,
        green: 0.77,
        blue: 0.36
    )

    private let categories = [
        "All",
        "Forests",
        "Climate",
        "Wildlife",
        "Mangroves"
    ]

    // MARK: - Filtered News

    private var filteredArticles: [EcoNewsItem] {
        articles.filter { article in

            let matchesCategory =
                selectedCategory == "All" ||
                article.category == selectedCategory

            let matchesSearch =
                searchText.isEmpty ||
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.source.localizedCaseInsensitiveContains(searchText) ||
                article.summary.localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
    }

    // MARK: - Main View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                header

                searchBar

                categoryFilters

                newsContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .onAppear {
            startListening()
        }
        .onDisappear {
            stopListening()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {

                Text("DISCOVER NATURE")
                    .font(.caption2.bold())
                    .tracking(2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 5) {
                    Text("Explore")
                        .foregroundStyle(.primary)

                    Text("Green")
                        .foregroundStyle(green)
                }
                .font(.system(size: 30, weight: .bold))
            }

            Spacer()

            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(green)
                .frame(width: 48, height: 48)
                .background(green.opacity(0.1))
                .clipShape(Circle())
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {

            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(
                "Search environmental news...",
                text: $searchText
            )
            .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(15)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {

                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .foregroundStyle(
                                selectedCategory == category
                                ? Color.white
                                : Color.primary
                            )
                            .background(
                                selectedCategory == category
                                ? green
                                : Color(.secondarySystemGroupedBackground)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - News Content

    @ViewBuilder
    private var newsContent: some View {

        if isLoading {
            ProgressView("Loading environmental news...")
                .frame(maxWidth: .infinity)
                .padding(.top, 80)

        } else if let errorMessage {
            ContentUnavailableView(
                "Unable to Load News",
                systemImage: "wifi.exclamationmark",
                description: Text(errorMessage)
            )

        } else if filteredArticles.isEmpty {
            ContentUnavailableView(
                "No News Found",
                systemImage: "leaf",
                description: Text(
                    "No environmental articles match your selection."
                )
            )

        } else {
            if let featured = filteredArticles.first {
                featuredCard(featured)
            }

            if filteredArticles.count > 1 {
                Text("Latest Stories")
                    .font(.title3.bold())

                ForEach(
                    Array(filteredArticles.dropFirst())
                ) { article in
                    newsCard(article)
                }
            }
        }
    }

    // MARK: - Featured News Card

    private func featuredCard(
        _ article: EcoNewsItem
    ) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Featured Story")
                .font(.title3.bold())

            articleImage(
                article.imageURL,
                height: 190
            )

            Text(article.category.uppercased())
                .font(.caption.bold())
                .foregroundStyle(green)

            Text(article.title)
                .font(.title3.bold())

            Text(article.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            articleMetadata(article)

            // Clickable article button
            articleButton(
                article,
                title: "Read Full Story",
                prominent: true
            )
        }
        .padding(15)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - Latest News Card

    private func newsCard(
        _ article: EcoNewsItem
    ) -> some View {

        HStack(alignment: .top, spacing: 13) {

            articleImage(
                article.imageURL,
                height: 105
            )
            .frame(width: 105)

            VStack(alignment: .leading, spacing: 7) {

                Text(article.category.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(green)

                Text(article.title)
                    .font(.subheadline.bold())
                    .lineLimit(3)

                Text(article.source)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                articleButton(
                    article,
                    title: "Read Story",
                    prominent: false
                )
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Article Metadata

    private func articleMetadata(
        _ article: EcoNewsItem
    ) -> some View {

        HStack(spacing: 8) {
            Text(article.source)

            Text("•")

            Text(
                article.publishedAt,
                style: .date
            )
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    // MARK: - Clickable Article Link

    
    @ViewBuilder
    private func articleButton(
        _ article: EcoNewsItem,
        title: String,
        prominent: Bool
    ) -> some View {

        if let url = article.articleLink {
            Link(destination: url) {
                HStack(spacing: 8) {
                    Text(title)

                    if prominent {
                        Spacer()
                    }

                    Image(systemName: "arrow.up.right")
                }
                .font(.subheadline.bold())
                .foregroundStyle(
                    prominent ? Color.white : green
                )
                .padding(prominent ? 15 : 0)
                .background(
                    prominent ? green : Color.clear
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
            }
            .padding(.top, prominent ? 8 : 2)
        }
    }

    // MARK: - Article Image

    private func articleImage(
        _ imageURL: String,
        height: CGFloat
    ) -> some View {

        AsyncImage(
            url: URL(string: imageURL)
        ) { phase in

            switch phase {

            case .empty:
                ZStack {
                    green.opacity(0.1)

                    ProgressView()
                }

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure(let error):
                placeholderImage
                    .onAppear {
                        print(
                            "IMAGE ERROR: \(error.localizedDescription)"
                        )
                    }

            @unknown default:
                placeholderImage
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(green.opacity(0.1))
        .clipped()
        .clipShape(
            RoundedRectangle(cornerRadius: 13)
        )
    }

    // MARK: - Placeholder Image

    private var placeholderImage: some View {
        ZStack {
            green.opacity(0.1)

            Image(systemName: "leaf.fill")
                .font(.largeTitle)
                .foregroundStyle(green)
        }
    }

    // MARK: - Firestore Listener

    private func startListening() {
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        print("Starting Firestore ecoNews listener...")

        listener = Firestore.firestore()
            .collection("ecoNews")
            .order(
                by: "publishedAt",
                descending: true
            )
            .addSnapshotListener { snapshot, error in

                if let error {
                    print(
                        "FIRESTORE ERROR: \(error.localizedDescription)"
                    )

                    errorMessage = error.localizedDescription
                    isLoading = false
                    return
                }

                guard let snapshot else {
                    errorMessage =
                        "No Firestore response received."
                    isLoading = false
                    return
                }

                print(
                    "Documents found: \(snapshot.documents.count)"
                )

                var loadedArticles: [EcoNewsItem] = []

                for document in snapshot.documents {
                    do {
                        let article = try document.data(
                            as: EcoNewsItem.self
                        )

                        loadedArticles.append(article)

                        print(
                            "Loaded article: \(article.title)"
                        )

                    } catch {
                        print(
                            "DECODING ERROR \(document.documentID): \(error)"
                        )
                    }
                }

                articles = loadedArticles
                errorMessage = nil
                isLoading = false
            }
    }

    // MARK: - Stop Firestore Listener

    private func stopListening() {
        listener?.remove()
        listener = nil
    }
}

// MARK: - Preview

#Preview {
    ExploreView()
}
