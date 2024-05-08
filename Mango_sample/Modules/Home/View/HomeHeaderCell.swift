//
//  HomeHeaderCell.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/08.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeHeaderCell: UICollectionViewCell {
    static let identifier = "HomeHeaderCell"
    
    private(set) var disposeBag = DisposeBag()

    var containerView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .lightGray
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("ry cell preprare", contentView)
        disposeBag = DisposeBag()
        self.titleLabel.text = ""
    }
    
    // MARK: Methods
    private func setupLayouts() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(containerView).inset(10)
        }
        
    }
}

//extension Reactive where Base: HomeHeaderCell {
//    var prepare: Binder<HeaderItem?> {
//        Binder(base) { base, itemType in
//            base.titleLabel.setTitle(itemType?.title, for: .normal)
//            base.titleLabel.setTitle(itemType?.title, for: .selected)
//            base.titleLabel.isSelected = itemType?.isSelected.value ?? false
//            base.titleLabel.layer.borderColor = itemType?.isSelected.value == true ? UIColor.black.cgColor : UIColor.lightGray.cgColor
//        }
//    }
//    
//    var onTap: ControlEvent<Void> {
//        base.titleButton.rx.tap
//    }
//    
//}
