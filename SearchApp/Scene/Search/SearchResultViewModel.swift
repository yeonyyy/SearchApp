//
//  BoardsSearchViewModel.swift
//  SampleProject
//
//  Created by rayeon lee on 2023/12/23.
//

import Foundation
import RxCocoa
import RxSwift

typealias SearchSet = (category: Category, searchText: String)

enum CellMoelItem {
    case historyCellViewModelItem(cellViewModel: HistoryCellModel)
    case categoryCellViewModelItem(cellViewModel: CategoryCellModel)
    case resultCellViewModelItem(cellViewModel: PostDTO)
}

protocol SearchResultViewModelInputs {
    var loadHistory : PublishSubject<Void> { get }
    var searchText : PublishSubject<String> { get }
    var select : PublishSubject<CellMoelItem> { get }
    var delete : PublishSubject<HistoryCellModel> { get }
}

protocol SearchResultViewModelOutput {
    var items: Driver<[CellMoelItem]> { get }
    var selected : Signal<SearchSet> { get }
}

protocol SearchResultViewModelProtocol {
    var inputs: SearchResultViewModelInputs { get }
    var outputs: SearchResultViewModelOutput { get }
}

final class SearchResultViewModel : SearchResultViewModelProtocol, SearchResultViewModelInputs, SearchResultViewModelOutput {
    var inputs: SearchResultViewModelInputs  { return self }
    var outputs: SearchResultViewModelOutput  { return self }
    
    // Mark: - Inputs
    var loadHistory = PublishSubject<Void>()
    var searchText = PublishSubject<String>()
    var select = PublishSubject<CellMoelItem>()
    var delete = PublishSubject<HistoryCellModel>()
    
    // Mark: - Outputs
    var items = BehaviorRelay<[CellMoelItem]>(value: []).asDriver()
    var selected = PublishRelay<SearchSet>().asSignal()
    
    private let networkService : NetworkService
    private let localService : LocalService?
    private let disposeBag = DisposeBag()
    init(_ networkService : NetworkService = NetworkService.shared, _ localService : LocalService? = LocalService.shared) {
        self.networkService = networkService
        self.localService = localService
        
        let historyItems =  BehaviorRelay<[CellMoelItem]>(value: [])
        let categoryItems = BehaviorRelay<[CellMoelItem]>(value: [])
        let searchItems = BehaviorRelay<[CellMoelItem]>(value: [])
        self.items = Observable.merge(historyItems.asObservable(), categoryItems.asObservable(), searchItems.asObservable())
            .asDriver(onErrorJustReturn: [])
        
        let selected = PublishRelay<SearchSet>()
        self.selected = selected.asSignal()
        
        inputs.loadHistory
            .map(fetchHistoryItems)
            .bind(to: historyItems)
            .disposed(by: disposeBag)
        
        inputs.searchText
            .filter{ $0.count == 0 }
            .map { _ in () }
            .map(fetchHistoryItems)
            .bind(to: historyItems)
            .disposed(by: disposeBag)
        
        inputs.searchText
            .filter { $0.count != 0 }
            .map(makeCategory(searchText:))
            .bind(to: categoryItems)
            .disposed(by: disposeBag)
        
        inputs.select
            .subscribe(onNext: { [weak self] cellModelItem in
                guard let self = self else { return }
                
                switch cellModelItem {
                case .historyCellViewModelItem(let cellModel):
                    let category = cellModel.category
                    let searchText = cellModel.keyword
                    selected.accept((category, searchText))
                    
                    self.updateHistory(category: category, searchText: searchText)
                    let items = self.fetchPosts(category: category, searchText: searchText)
                    searchItems.accept(items)
                    
                case .categoryCellViewModelItem(let cellModel):
                    let category = cellModel.category
                    let searchText = cellModel.searchText
                    selected.accept((category, searchText))
                    
                    self.updateHistory(category: category, searchText: searchText)
                    let items = self.fetchPosts(category: category, searchText: searchText)
                    searchItems.accept(items)
                    
                case .resultCellViewModelItem(_): break
                }
            })
            .disposed(by: disposeBag)
        
        inputs.delete
            .map { $0.id }
            .map(deleteHistoryItem(id:))
            .map(fetchHistoryItems)
            .bind(to: historyItems)
            .disposed(by: disposeBag)
        
    }
    
}

extension SearchResultViewModel {
    private func fetchPosts(category:Category, searchText:String) -> [CellMoelItem] {
        let posts = BoardsManager.shared.getBoardsMock()
        
        let filtered : [PostDTO]
        switch category {
        case Category.title:
            filtered = posts.value.filter { $0.title.contains(searchText) }
        case Category.content:
            filtered = posts.value.filter { $0.contents.contains(searchText) }
        case Category.writer:
            filtered = posts.value.filter { $0.writer.displayName.contains(searchText) }
        default:
            filtered = posts.value.filter {
                $0.title.contains(searchText)
                || $0.contents.contains(searchText)
                || $0.writer.displayName.contains(searchText)
            }
        }
        return filtered.map { .resultCellViewModelItem(cellViewModel: $0) }
        
    }
    
    
    private func fetchHistoryItems() -> [CellMoelItem] {
        if let historyItems = self.localService?.readData() {
            return historyItems.map { .historyCellViewModelItem(cellViewModel: HistoryCellModel(history: $0)) }
        }
        return []
    }
    
    private func updateHistory(category: Category, searchText:String) {
        let date = Date().yyyMMddHHmmss()
        let category = category.rawValue
        let searchText = searchText
        self.localService?.insert(category: category, keyword: searchText, date: date)
        
    }
    
    private func deleteHistoryItem(id: Int) {
        self.localService?.deleteData(id: id)
    }
    
    private func makeCategory(searchText:String) -> [CellMoelItem] {
        return [
            .categoryCellViewModelItem(cellViewModel: CategoryCellModel(category: .content, searchText: searchText)),
            .categoryCellViewModelItem(cellViewModel: CategoryCellModel(category: .title, searchText: searchText)),
            .categoryCellViewModelItem(cellViewModel: CategoryCellModel(category: .total, searchText: searchText)),
            .categoryCellViewModelItem(cellViewModel: CategoryCellModel(category: .writer, searchText: searchText))
        ]
    }


}


