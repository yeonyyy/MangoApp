//
//  HomeHeaderView.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/08.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

typealias UpdateHeaderItem = (Int, HeaderItem)

struct HeaderItem : Identifiable {
    var id = UUID()
    var title: String
    var isSelected: BehaviorRelay<Bool>
}
    
enum Menu: Int, CaseIterable, CustomStringConvertible {
    case women, men
    
    var description:String {
        switch self {
        case .women:
            return "여성"
        case .men:
            return "남성"
        }
    }
}

class HomeHeaderView: UIView {
    let maxHeaderHeight: CGFloat = 88
    let minHeaderHeight: CGFloat = 44
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16.0)
        label.text = "Discover by MANGO"
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var menuList : UIMenu = {
        var checkedMenu = Menu.allCases[0].description
        let menuList = UIMenu(children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                var actions = [UIMenuElement]()
                Menu.allCases.forEach { menu in
                    let action = UIAction(
                        title: menu.description,
                        state: menu.description == checkedMenu ? .on: .off,
                        handler: { [weak self] value in
                            checkedMenu = menu.description
                            self?.menuButton.setTitle(value.title, for: .normal)
                            self?.selectedMenuPublish.onNext(menu)
                        })
                    actions.append(action)
                }
                completion(actions)
            }])
        return menuList
    }()
    
    private lazy var menuButton : UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.title = Menu.allCases[0].description
        config.image = UIImage(named: "up.down")?.withTintColor(.gray)
        config.baseForegroundColor = .gray
        config.imagePadding = 5
        config.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 5, bottom: 5, trailing: 5)
        config.imagePlacement = NSDirectionalRectEdge.trailing
        
        let button = UIButton(configuration: config)
        button.menu = menuList
        button.showsMenuAsPrimaryAction = true
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return button
        
    }()
    
    fileprivate lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        collectionView.register(HomeHeaderCell.self, forCellWithReuseIdentifier: HomeHeaderCell.identifier)
        return collectionView
        
    }()
    
    private lazy var topView : UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    private lazy var bottomView : UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var topHeaderViewTopConstraint: Constraint!
    fileprivate var dataSources = [HeaderItem]()
    fileprivate let selectedPublish = PublishSubject<Int>()
    fileprivate let selectedMenuPublish = PublishSubject<Menu>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraint()
        setCollectionViewDelegate()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTopViewHeightConstraint(constant: CGFloat){
        self.topHeaderViewTopConstraint.layoutConstraints[0].constant = -constant
    }
    
}

//Mark: - Private method
extension HomeHeaderView {
    private func setCollectionViewDelegate(){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupViews() {
        self.addSubview(topView)
        self.addSubview(bottomView)
        self.topView.addSubviews([titleLabel, menuButton])
        self.bottomView.addSubview(collectionView)
    }
    
    private func setupConstraint() {
        topView.snp.makeConstraints { make in
            topHeaderViewTopConstraint = make.top.equalToSuperview().constraint
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
    
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(topView).inset(20.0)
            make.centerY.equalTo(topView)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(topView).inset(20.0)
            make.centerY.equalTo(topView)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(bottomView)
        }
    }
}

extension HomeHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHeaderCell.identifier, for: indexPath) as? HomeHeaderCell else {
            return .zero
        }
        
        cell.titleLabel.text = dataSources[indexPath.item].title
        cell.titleLabel.sizeToFit()
        let cellWidth = cell.titleLabel.frame.width + 20.0
    
        return CGSize(width: cellWidth, height: 30.0)
    }
    
}

extension HomeHeaderView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHeaderCell.identifier, for: indexPath ) as? HomeHeaderCell
        else {
            return UICollectionViewCell()
        }
        
        cell.titleLabel.text = dataSources[indexPath.row].title
        
        if dataSources[indexPath.row].isSelected.value == true {
            cell.containerView.layer.borderColor = UIColor.black.cgColor
            cell.titleLabel.textColor = UIColor.black
        }else {
            cell.containerView.layer.borderColor = UIColor.lightGray.cgColor
            cell.titleLabel.textColor = UIColor.lightGray
        }
        
        return cell
        
    }
}

extension HomeHeaderView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPublish.onNext(indexPath.row)
    }
}

extension Reactive where Base : HomeHeaderView {
    var onIndexSelected: Observable<Int> {
        base.selectedPublish.asObservable()
    }
    
    var setItems : Binder<[HeaderItem]> {
        Binder(base) { base, items in
            base.dataSources = items
        }
    }
    
    var updateCells : Binder<[UpdateHeaderItem]> {
        Binder(base) { base, items in
            items.forEach { idx, item in
                base.dataSources[idx] = item
            }
            
            UIView.performWithoutAnimation {
                base.collectionView.reloadData()
            }
        }
    }
    
    var onMenuSelected: Observable<Menu> {
        return base.selectedMenuPublish.asObservable()
    }
    
}
