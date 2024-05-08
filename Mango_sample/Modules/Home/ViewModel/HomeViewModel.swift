//
//  HomeViewModel.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/16/24.
//

import RxSwift
import RxCocoa

final class HomeViewModel : ViewModelType {
    struct Input {
        let trigger: Observable<Void>
        let menuSelection : Observable<Menu>
        let headerSelection : Observable<Int>
        let selection: Observable<(IndexPath,Promotion)>
    }
    
    struct Output {
        let item: Driver<[Promotion]>
        let headerItem : Driver<[HeaderItem]>
        let updatedHeaderItem: Signal<[UpdateHeaderItem]>
        let selected: Signal<(IndexPath,Promotion)>
    }
    
    let service = Service()
    
    let menuSelection = BehaviorRelay<Menu>(value: .women)
    let headerSelection = BehaviorRelay<Int>(value: 0)
    let selection = PublishRelay<(IndexPath,Promotion)>()
    
    let element = BehaviorRelay<[Promotion]>(value: [])
    let headerElement = BehaviorRelay<[HeaderItem]>(value: [])
    let updatedHeaderElement = PublishRelay<[UpdateHeaderItem]>()
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        var lastSelectedIndex = 0
        
        Observable.just(())
            .map {
                return PromotionType.allItems().enumerated().map { idx, str in
                    HeaderItem(title: str, isSelected: BehaviorRelay(value: idx == 0) )
                }
            }
            .bind(to: headerElement)
            .disposed(by: disposeBag)
        
        input.headerSelection.bind(to: headerSelection).disposed(by: disposeBag)
        
        input.menuSelection.bind(to: menuSelection).disposed(by: disposeBag)
        
        input.selection.bind(to: selection).disposed(by: disposeBag)
        
        menuSelection
            .map({ _ in 0 })
            .bind(to: headerSelection)
            .disposed(by: disposeBag)
     
        headerSelection
            .filter({ $0 != lastSelectedIndex })
            .subscribe(onNext: { [weak self] (idx) in
                guard let self = self else { return }
                
                let headerElement = self.headerElement.value
                headerElement[lastSelectedIndex].isSelected.accept(false)
                headerElement[idx].isSelected.accept(true)
                
                let updateHeaderItemTypes : [UpdateHeaderItem] = [
                    (lastSelectedIndex, headerElement[lastSelectedIndex]),
                    (idx, headerElement[idx])
                ]
                lastSelectedIndex = idx
                
                self.updatedHeaderElement.accept(updateHeaderItemTypes)
                
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.trigger, headerSelection)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .utility))
            .flatMapLatest({ [weak self] (_, idx) -> Observable<[Promotion]> in
                guard let self = self else { return Observable.empty() }
                
                //dummy data
                let menu = menuSelection.value
                var element = service.requestPromotions(with: menu)
                switch menu
                {
                default:
                    switch idx {
                    case 1 :
                        element = element.map { $0.filter { $0.promotionType == PromotionType.trends  } }
                    case 2 :
                        element = element.map { $0.filter { $0.promotionType == PromotionType.ideatip  } }
                    case 3 :
                        element = element.map { $0.filter { $0.promotionType == PromotionType.lifestyle  } }
                    case 4 :
                        element = element.map { $0.filter { $0.promotionType == PromotionType.sustainability  } }
                    case 5 :
                        element = element.map { $0.filter { $0.promotionType == PromotionType.mangoCommunity  } }
                    default:
                        break
                    }
                }
                return element
                
            })
            .bind(to: element)
            .disposed(by: disposeBag)
        
        return Output(item: element.asDriver(),
                      headerItem: headerElement.asDriver(),
                      updatedHeaderItem: updatedHeaderElement.asSignal(), selected: selection.asSignal())
    }
    
    
}
