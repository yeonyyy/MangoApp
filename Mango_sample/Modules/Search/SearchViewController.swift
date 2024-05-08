//
//  SearchViewController.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum SearchSectionItem : Identifiable  {
    case category(HeaderItem)
    case product(Product)
    
    var id : UUID {
        switch self {
        case .category(let item):
            return item.id
        case .product(let item):
            return item.id
        }
    }
}

struct Section : Identifiable {
    enum Identifier: String, CaseIterable {
        case category = "category"
        case product = "product"
    }
    
    var id: Identifier
}

final class SearchViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        return collectionView
    }()
    
    private var headers: [HeaderItem]? = []
    var dataSource : UICollectionViewDiffableDataSource<Section.ID, SearchSectionItem.ID>! = nil
    var snapshot = NSDiffableDataSourceSnapshot<Section.ID, SearchSectionItem.ID>()
    
    private var viewModel: SearchViewModel?
    private var disposeBag = DisposeBag()
    private var service = Service()
    
    fileprivate let selectedHeader = PublishSubject<Int>()
    
    init(viewModel : SearchViewModel?){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureDataSource()
        applyInitialSnapshots()
        bindViewModel()
    }
    
}

extension SearchViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = CustomCollectionViewCompositionalLayout(columns: 2) { (sectionIndex, env) -> NSCollectionLayoutSection?  in
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            let section: NSCollectionLayoutSection
            
            if sectionID == .category {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .absolute(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize.init(widthDimension: .estimated(10), heightDimension: itemSize.heightDimension)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                return section
            }else  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(10))
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10))
                
                let numberOfItemsPerGroup = Int(round(CGFloat(1) / itemSize.widthDimension.dimension))
                let subItemInGroup = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitem: subItemInGroup,
                                                               count: numberOfItemsPerGroup)
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                return section
            }
        }
        return layout
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        navigationItem.title = "Shop"
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func createCategorySectionRegistration() -> UICollectionView.CellRegistration<CategoryCell, SearchSectionItem.ID> {
        return UICollectionView.CellRegistration<CategoryCell, SearchSectionItem.ID> {  [weak self] cell, indexPath, identifier in
            guard let self = self else { return }
            print("ry ", indexPath, cell)
            
            guard let items = self.viewModel?.headerElement.value else { return }
            guard let item = items.first(where: { $0.id == identifier }) else { return }
 
            cell.titleLabel.text = item.title
            if item.isSelected.value == true {
                cell.containerView.layer.borderColor = UIColor.black.cgColor
                cell.titleLabel.textColor = .black
            }else {
                cell.containerView.layer.borderColor = UIColor.lightGray.cgColor
                cell.titleLabel.textColor = .lightGray
            }
        }
    }
    
    private func createProductSectionRegistration() -> UICollectionView.CellRegistration<ProductCell, SearchSectionItem.ID> {
        
        return UICollectionView.CellRegistration<ProductCell, SearchSectionItem.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            guard let products = self.viewModel?.element.value else { return }
            guard let product = products.first(where: { $0.id == itemIdentifier }) else { return }
            
            cell.titleLabel.text = product.title
            cell.priceLabel.text = product.lprice
            cell.layout = self.collectionView.collectionViewLayout as? CustomCollectionViewCompositionalLayout
            
            if let data = product.image.value, let image = UIImage(data: data) {
                cell.imageView.image = image
                cell.imageView.snp.updateConstraints { make in
                    let newheight = cell.bounds.width * (image.size.height)/(image.size.width)
                    cell.imageView.snp.updateConstraints { make in
                        make.height.equalTo(newheight).priority(999)
                    }
                    cell.invalidateIntrinsicContentSize()
                }
            }else {
                if let url = product.imageUrl {
                    _ = self.service.requestImage(urlString: url)
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] data in
                            guard let self = self else { return }
                            if let index = products.firstIndex(where: { $0.id == itemIdentifier }) {
                                self.viewModel?.element.value[index].image.accept(data)
                                var snapshot = self.dataSource.snapshot()
                                snapshot.reconfigureItems([itemIdentifier])
                                self.dataSource.apply(snapshot, animatingDifferences: true)
                            }
                        })
                        .disposed(by: disposeBag)
                }
            }
        }
    }
    
    private func configureDataSource() {
        let categoryCellRegistration = createCategorySectionRegistration()
        let productCellRegistration = createProductSectionRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section.ID, SearchSectionItem.ID>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier  -> UICollectionViewCell? in

            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch sectionID {
            case .category:
                return collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: itemIdentifier)
            case .product:
                return collectionView.dequeueConfiguredReusableCell(using: productCellRegistration, for: indexPath, item: itemIdentifier)
            }
            
        })
    }
    
    private func applyInitialSnapshots(){
        snapshot.appendSections(Section.ID.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        let input = SearchViewModel.Input(trigger: Observable.just(()),
                                          headerSelection: selectedHeader.asObservable())
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.item
            .drive(onNext: { [weak self] products in
                guard let self = self else { return }
                let identifiers = products.map { $0.id }
                var snapshot = NSDiffableDataSourceSectionSnapshot<SearchSectionItem.ID>()
                snapshot.append(identifiers)
                self.dataSource.apply(snapshot, to: .product, animatingDifferences: false)
                
            })
            .disposed(by: disposeBag)
        
        output.headerItem
            .drive(onNext: { [weak self] items in
                guard let self = self else { return }
                var sanpshot = NSDiffableDataSourceSectionSnapshot<SearchSectionItem.ID>()
                let identifiers = items.map { $0.id }
                sanpshot.append(identifiers)
                self.dataSource.apply(sanpshot, to: .category, animatingDifferences: false)
                
            })
            .disposed(by: disposeBag)
        
        output.updatedHeaderID
            .emit(onNext: { [weak self] identifiables in
                guard let self = self else { return }
                _ = identifiables.map {
                    var snapshot = self.dataSource.snapshot()
                    snapshot.reconfigureItems([$0])
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    
}

extension SearchViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        self.selectedHeader.onNext(indexPath.row)
        
    }
    
}
