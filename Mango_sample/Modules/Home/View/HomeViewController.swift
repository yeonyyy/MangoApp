//
//  HomeViewController.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxDataSources

final class HomeViewController: UIViewController {
    
    private lazy var topSafeAreaView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var headerView : HomeHeaderView = {
        let view = HomeHeaderView(frame: .zero)
        return view
    }()
    
    private lazy var tableView: UITableView  =  {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 10.0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.rx.setDelegate(self).disposed(by:disposeBag)
        return tableView
    }()
    
    private var viewModel: HomeViewModel?
    
    private var disposeBag = DisposeBag()

    var headerHeightConstraint: Constraint!
    
    let maxHeaderHeight: CGFloat = 88
    
    let minHeaderHeight: CGFloat = 44
    
    /// The last known scroll position
    var previousScrollOffset: CGFloat = 0
    
    /// The last known height of the scroll view content
    var previousScrollViewHeight: CGFloat = 0

    init(viewModel : HomeViewModel?){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setConstraint()
        bindViewModel()
        self.previousScrollViewHeight = self.tableView.contentSize.height
    }
}

extension HomeViewController {
    private func setupViews(){
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(topSafeAreaView)
        view.addSubview(tableView)
    }
    
    private func setConstraint(){
        var topSafeAreaInsets: CGFloat = 0.0
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        if let hasWindowScene = windowScene {
            topSafeAreaInsets = hasWindowScene.windows.first?.safeAreaInsets.top ?? 0
        }
        
        topSafeAreaView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(topSafeAreaInsets)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            headerHeightConstraint = make.height.equalTo(maxHeaderHeight).constraint
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        let trigger = Observable.just(())
        let headerSelection = headerView.rx.onIndexSelected.distinctUntilChanged()
        let menuSelection = headerView.rx.onMenuSelected
        let selection = Observable.zip(self.tableView.rx.itemSelected, self.tableView.rx.modelSelected(Promotion.self))
        
        let input = HomeViewModel.Input(trigger: trigger,
                                        menuSelection: menuSelection, headerSelection: headerSelection, selection: selection)
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.item
            .drive(tableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)){ (row, element, cell) in
                cell.fill(with: element)
            }
            .disposed(by: disposeBag)
        
        output.headerItem
            .asObservable()
            .bind(to: headerView.rx.setItems)
            .disposed(by:disposeBag)
        
        output.updatedHeaderItem
            .emit(to: headerView.rx.updateCells)
            .disposed(by: disposeBag)
        
        output.selected
            .emit(onNext: { [weak self] (indexPath, _) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
}

extension HomeViewController :UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            self.previousScrollViewHeight = scrollView.contentSize.height
            self.previousScrollOffset = scrollView.contentOffset.y
        }

        let heightDiff = scrollView.contentSize.height - self.previousScrollViewHeight
        let scrollDiff = (scrollView.contentOffset.y - self.previousScrollOffset)

        // If the scroll was caused by the height of the scroll view changing, we want to do nothing.
        guard heightDiff == 0 else { return }

        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;

        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        if canAnimateHeader(scrollView) {

            // Calculate new header height
            var newHeight = self.headerHeightConstraint.layoutConstraints[0].constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.layoutConstraints[0].constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.layoutConstraints[0].constant + abs(scrollDiff))
            }

            // Header needs to animate
            if newHeight != self.headerHeightConstraint.layoutConstraints[0].constant {
                self.headerHeightConstraint.layoutConstraints[0].constant = newHeight
                self.updateHeader()
                self.setScrollPosition(self.previousScrollOffset)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)

        if self.headerHeightConstraint.layoutConstraints[0].constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.layoutConstraints[0].constant - minHeaderHeight

        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }

    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.layoutConstraints[0].constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }

    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.layoutConstraints[0].constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }

    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }

    func updateHeader() {
        let openAmount = self.maxHeaderHeight - self.headerHeightConstraint.layoutConstraints[0].constant
        self.headerView.setTopViewHeightConstraint(constant: openAmount)
    }
}
