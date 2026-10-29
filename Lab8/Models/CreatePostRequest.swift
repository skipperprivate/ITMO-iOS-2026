struct CreatePostRequest: Encodable {
    let title: String
    let body: String
    let userId: Int
}
