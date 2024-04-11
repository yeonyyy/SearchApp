//
//  ViewController.swift
//  SampleProject
//
//  Created by rayeon lee on 2023/12/19.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class BoardsViewController: UIViewController {
    
    private var searchBar = UISearchBar()
    
    private lazy var searchResultViewController : SearchResultViewController = {
        let searchResultViewModel = SearchResultViewModel()
        let searchResultViewController = SearchResultViewController(searchResultViewModel)
        searchResultViewController.didSelect = setSearchBar
        return searchResultViewController
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 75.0
        tableView.register(BoardsTableViewCell.self, forCellReuseIdentifier: BoardsTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var emptyView : EmptyView = {
        let emptyView = EmptyView()
        emptyView.imageView.image = UIImage(systemName: "magnifyingglass")
        emptyView.descriptionLabel.text = "등록된 게시글이 없습니다."
        return emptyView
    }()
    
    private let boardsViewMdoel : BoardsViewModelProtocol!
    private let disposedBag : DisposeBag = DisposeBag()
    
    init(_ viewModel:BoardsViewModelProtocol){
        boardsViewMdoel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        definesPresentationContext = true
        setNavigationBar(isSetSearchBarButton: false)
        setupViews()
        setupContraints()
        setupBinds()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchBar.becomeFirstResponder()
        }
    }

    private func setSearchBar(set: SearchSet) {
        setSearchBarTitle(set: set)
        searchBar.searchTextField.isUserInteractionEnabled = false
        searchBar.searchTextField.clearButtonMode = .never
    }
    
    private func setSearchBarTitle(set: SearchSet) {
        let category = set.category.rawValue
        let searchText = set.searchText
        let whiteColor = UIColor(white: 0.56, alpha: 1.0)
        let text = "\(category):\(searchText)"
        let attributedString = text.attribute(size: 14,
                                              weight: .regular,
                                              color: whiteColor)
        
        let nsString = NSString(string: text)
        let range = nsString.range(of: searchText)
        
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.black,
                                      range: range)
        
        searchBar.searchTextField.attributedText = attributedString
    }
    
    
    private func setNavigationBar(isSetSearchBarButton: Bool) {
        if isSetSearchBarButton {
            self.searchBar.becomeFirstResponder()
            self.searchBar.text = ""
            self.searchBar.searchTextField.clearButtonMode = .whileEditing
            self.searchBar.searchTextField.isUserInteractionEnabled = true
            self.navigationItem.titleView = searchBar
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            add(searchResultViewController)
        } else {
            self.title = "일반 게시판"
            self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(search))
            searchResultViewController.remove()
        }
        self.navigationItem.rightBarButtonItem?.tintColor = .darkGray
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    @objc func search() {
        self.setNavigationBar(isSetSearchBarButton: true)
    }
    
    
    @objc func cancel() {
        self.setNavigationBar(isSetSearchBarButton: false)
    }
    
    
    
}

// Mark : - Private method

extension BoardsViewController {
    
    private func setupBinds() {
        boardsViewMdoel.inputs.refresh.onNext(())
        
        boardsViewMdoel.outputs.posts
            .drive(tableView.rx.items(cellIdentifier: BoardsTableViewCell.identifier, cellType: BoardsTableViewCell.self)) {
                index, post, cell in
                cell.fill(post)
            }
            .disposed(by: disposedBag)
        
        boardsViewMdoel.outputs.hasPosts
            .asDriver()
            .drive(emptyView.rx.isHidden)
            .disposed(by: disposedBag)
        
        tableView.rx.reachedBottom.asObservable()
            .bind(to: boardsViewMdoel.inputs.loadmore)
            .disposed(by: disposedBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }).disposed(by: disposedBag)
        
        
        searchBar.rx.text
            .orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.searchResultViewController.result(with: $0)
            })
            .disposed(by: disposedBag)
        
    }
    
    private func setupViews() {
        self.view.backgroundColor = .systemGray6
        self.view.addSubview(tableView)
        self.view.addSubview(emptyView)
        
    }
    
    private func setupContraints() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

