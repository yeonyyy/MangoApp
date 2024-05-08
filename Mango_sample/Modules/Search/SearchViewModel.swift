//
//  SearchViewModel.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel : ViewModelType {
    
    struct Input {
        let trigger: Observable<Void>
        let headerSelection : Observable<Int>
    }
    
    struct Output {
        let item: Driver<[Product]>
        let headerItem : Driver<[HeaderItem]>
        let updatedHeaderID: Signal<[UUID]>
    }
    
    let service = Service()
    let element : BehaviorRelay<[Product]> = BehaviorRelay(value: [])
    let headerElement : BehaviorRelay<[HeaderItem]> = BehaviorRelay(value: [])
    let headerSelection : BehaviorRelay<Int> = BehaviorRelay(value: 0)
    let updatedHeaderID : PublishRelay<[UUID]> = PublishRelay<[UUID]>()
    
    func transform(input: Input, disposeBag: RxSwift.DisposeBag) -> Output {
        var lastSelectedIndex = 0
        
        input.headerSelection.bind(to: headerSelection).disposed(by: disposeBag)
        
        headerSelection
            .filter({ $0 != lastSelectedIndex })
            .subscribe(onNext: { [weak self] (idx) in
                guard let self = self else { return }
                
                var headerElement = self.headerElement.value
                headerElement[lastSelectedIndex].isSelected.accept(false)
                headerElement[idx].isSelected.accept(true)
                
                let updatedHeaderID = [headerElement[lastSelectedIndex].id, headerElement[idx].id]
                lastSelectedIndex = idx
                
                self.updatedHeaderID.accept(updatedHeaderID)
            })
            .disposed(by: disposeBag)
    
        
        Observable.just(())
            .map { _ in
                return ProductCategory.allItems().enumerated().map {  idx, item in
                    HeaderItem(title: item.description, isSelected: BehaviorRelay(value: idx == 0) )
                }
            }
            .bind(to: headerElement)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.trigger, headerSelection)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .flatMapLatest({ [weak self] (_, index)  -> Observable<[Product]> in
                guard let self = self else { return Observable.empty() }
                
                //dummy data
                let keyword = ProductCategory(rawValue: index)?.description
                var element = service.requestProducts().map { $0.map { $0.toProduct() } }
                switch index {
                case 0:
                    return element
                default:
                    return element.map { $0.filter{ $0.title!.contains(keyword ?? "") } }
                }
            })
            .subscribe(onNext: { [weak self] products in
                self?.element.accept(products)
            })
            .disposed(by: disposeBag)
        
        return Output(item: element.asDriver(),
                      headerItem: headerElement.asDriver(onErrorJustReturn: []),
                      updatedHeaderID: updatedHeaderID.asSignal())
    }
    
    
    
}
