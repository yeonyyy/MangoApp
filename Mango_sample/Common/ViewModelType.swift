//
//  ViewModelType.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/16/24.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output
}
