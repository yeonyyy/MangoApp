//
//  ProductCell.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/24/24.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class ProductCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"
    
    let containerView : UIView = {
        let view = UIView()
        return view
    }()
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    weak var layout: CustomCollectionViewCompositionalLayout?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attribute = super.preferredLayoutAttributesFitting(layoutAttributes)
        layout?.updateLayoutAttributesHeight(layoutAttributes: attribute)
        return attribute
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = ""
        priceLabel.text = ""
    }
    
    private func setupViews(){
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(containerView)
        
        containerView.addSubviews([imageView,titleLabel,priceLabel])
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(containerView)
            make.height.equalTo(10).priority(999)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.equalTo(containerView)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView)
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.lessThanOrEqualTo(containerView).inset(20)
        }
    }
}
