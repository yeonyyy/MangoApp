//
//  HomeTableViewCell.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import UIKit
import SnapKit
import RxSwift

class HomeTableViewCell: UITableViewCell {
    static let identifier = "HomeTableViewCell"
    
    var promotionImageView : UIImageView  = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private var descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.promotionImageView.image = nil
        self.titleLabel.text = ""
        self.descLabel.text = ""
    }
    
    func fill(with data: Promotion) {
        if let imageName = data.imageName, let image = UIImage(named: imageName) {
            promotionImageView.image = image
            promotionImageView.snp.updateConstraints { make in
                let newHeight = (UIScreen.main.bounds.width - 20*2) * (image.size.height/image.size.width)
                make.height.equalTo(newHeight).priority(999)
            }
        }
        self.titleLabel.text = data.title
        self.descLabel.text = data.desc
        
    }
    
    private func setConstraints() {
        promotionImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(10).priority(999)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(promotionImageView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.addSubviews([promotionImageView, titleLabel, descLabel])
    }
    
    
}
