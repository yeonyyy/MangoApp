//
//  CategoryCell.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "Cell"
    
    var containerView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    private(set) var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(containerView).inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        self.titleLabel.text = ""
        
    }
    
    func setSelected(){
        titleLabel.textColor = .black
        containerView.layer.borderColor = UIColor.black.cgColor
    }
    
    func setUnselected(){
        titleLabel.textColor = .lightGray
        containerView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setSelected()
            }else  {
                setUnselected()
            }
        }
    }
    
}
