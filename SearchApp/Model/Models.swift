//
//  Query.swift
//  SampleProject
//
//  Created by rayeon lee on 2023/12/23.
//

import Foundation

enum Category : String {
    case total = "전체"
    case title = "제목"
    case content = "내용"
    case writer = "작성자"
}

struct History {
    let id : Int
    let category: Category
    let keyword: String
    var date: String
}

struct CategoryCellModel {
    var category : Category
    var searchText : String
}

struct HistoryCellModel {
    var history: History?
    
    var id : Int
    let category: Category
    let keyword: String
    var date: String
    
    init(history: History) {
        self.id = history.id
        self.category = history.category
        self.keyword = history.keyword
        self.date = history.date
    }
    
}

struct SearchResultCellModel {
    var value : PostDTO
    
    var postId : Int
    var title : String
    var boardId : Int
    var boardDisplayName : String
    var writer : WriterDTO
    var contents: String
    var createdDateTime: String
    var viewCount : Int
    var postType : String
    var isNewPost : Bool
    var hasInlineImage : Bool
    var commentsCount : Int
    var attachmentsCount : Int
    var isAnonymous : Bool
    var isOwner : Bool
    var hasReply : Bool

    init(value: PostDTO, postId: Int, title: String, boardId: Int, boardDisplayName: String, writer: WriterDTO, contents: String, createdDateTime: String, viewCount: Int, postType: String, isNewPost: Bool, hasInlineImage: Bool, commentsCount: Int, attachmentsCount: Int, isAnonymous: Bool, isOwner: Bool, hasReply: Bool) {
        self.value = value
        self.postId = postId
        self.title = title
        self.boardId = boardId
        self.boardDisplayName = boardDisplayName
        self.writer = writer
        self.contents = contents
        self.createdDateTime = createdDateTime
        self.viewCount = viewCount
        self.postType = postType
        self.isNewPost = isNewPost
        self.hasInlineImage = hasInlineImage
        self.commentsCount = commentsCount
        self.attachmentsCount = attachmentsCount
        self.isAnonymous = isAnonymous
        self.isOwner = isOwner
        self.hasReply = hasReply
    }
  
}
