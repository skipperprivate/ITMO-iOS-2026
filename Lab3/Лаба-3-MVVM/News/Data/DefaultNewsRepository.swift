struct DefaultNewsRepository: NewsRepository {
    private let remoteDataSource: any NewsRemoteDataSource
    
    init(remoteDataSource: any NewsRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getNews() async throws -> [NewsArticle] {
        let posts = try await remoteDataSource.fetchNews()
        
        return posts.map { post in
            NewsArticle(id: post.id, title: post.title, body: post.body)
        }
    }
}
