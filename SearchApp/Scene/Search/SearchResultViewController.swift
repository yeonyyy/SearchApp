//
//  BoardsSearchViewController.swift
//  SampleProject
//
//  Created by rayeon lee on 2023/12/20.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchResultViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 75
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.register(BoardsTableViewCell.self, forCellReuseIdentifier: BoardsTableViewCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private lazy var emptyView : EmptyView = {
        let emptyView = EmptyView()
        emptyView.imageView.image = UIImage(systemName: "magnifyingglass")
        emptyView.descriptionLabel.text = "검색 결과가 없습니다.\n 다른 검색어를 입력해 보세요."
        return emptyView
    }()
    
    private let searchViewMdoel : SearchResultViewModelProtocol!
    private let disposedBag = DisposeBag()
    
    var didSelect: (SearchSet) -> Void = { _ in }
    
    init(_ viewModel:SearchResultViewModelProtocol){
        searchViewMdoel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupContraints()
        setupBinds()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}

extension SearchResultViewController {
    private func setupViews(){
        self.view.backgroundColor = .systemGray6
        self.view.addSubview(tableView)
        self.view.addSubview(emptyView)
        
    }
    
    private func setupBinds() {
        //MARK: - Inputs
        rx.viewWillAppear
            .bind(to: searchViewMdoel.inputs.loadHistory)
            .disposed(by: disposedBag)
        
        Observable.zip(self.tableView.rx.itemSelected, self.tableView.rx.modelSelected(CellMoelItem.self))
            .subscribe(onNext: { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                self?.searchViewMdoel.inputs.select.onNext(item)
            }).disposed(by: self.disposedBag)
        
        //MARK: - Outputs
        searchViewMdoel.outputs.items
            .drive(onNext: { [weak self] items in
                self?.emptyView.isHidden = !items.isEmpty
            })
            .disposed(by: disposedBag)
        
        searchViewMdoel.outputs.items
            .drive(tableView.rx.items) { [weak self] tableview, index, item -> UITableViewCell  in
                switch item {
                case .historyCellViewModelItem(let cellModel):
                    let cell = self?.tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier) as! HistoryTableViewCell
                    cell.fill(cellModel)
                    cell.rx.onTap
                        .subscribe(onNext: { _ in
                            self?.searchViewMdoel.inputs.delete.onNext(cellModel)
                        })
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .categoryCellViewModelItem(let cellModel):
                    let cell = self?.tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier) as! CategoryTableViewCell
                    cell.fill(cellModel)
                    cell.rx.onTap
                        .subscribe(onNext: { _ in
                            self?.searchViewMdoel.inputs.select.onNext(item)
                        })
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .resultCellViewModelItem(let cellModel):
                    let cell = self?.tableView.dequeueReusableCell(withIdentifier: BoardsTableViewCell.identifier) as! BoardsTableViewCell
                    cell.fill(cellModel)
                    return cell
                }
            }
            .disposed(by: disposedBag)
       
        searchViewMdoel.outputs.selected
            .emit(onNext: { [weak self] (set) in
                self?.didSelect((set.category, set.searchText))
            })
            .disposed(by: disposedBag)

    }
    
    
    private func setupContraints() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func result(with searchText: String) {
        searchViewMdoel.inputs.searchText.onNext(searchText)
        
    }
}

