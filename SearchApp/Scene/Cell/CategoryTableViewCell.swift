//
//  SearchTableViewCell.swift
//  SampleProject
//
//  Created by rayeon lee on 2024/04/05.
//

import UIKit
import SnapKit
import RxSwift

class CategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryTableViewCell"

    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    fileprivate lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron.right"), for: .normal)
        button.setImageTintColor(.lightGray)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryLabel.text = ""
        titleLabel.text = ""
    }

    func fill(_ model: CategoryCellModel) {
        categoryLabel.text = "\(model.category.rawValue):"
        titleLabel.text = model.searchText
    }

    private func setupViews(){
        self.contentView.addSubview(categoryLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(rightButton)
    }
    
    private func setupConstraint() {
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(15)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryLabel.snp.trailing).offset(2)
            make.bottom.top.equalTo(contentView)
        }
        
        rightButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
            make.centerY.equalTo(contentView.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailing).inset(15)
        }
    }
}

extension Reactive where Base: CategoryTableViewCell {
    var onTap: Observable<Void> {
        base.rightButton.rx.tap.map { _ in () }.asObservable()
    }
    
}
