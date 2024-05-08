//
//  Product.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/25/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

enum ProductCategory : Int, CaseIterable, CustomStringConvertible {
    case all, shirts, pants, onepiece, skirt, jumper, shoes, accessories
    
    var description: String {
        switch self{
        case .all:
            "모두보기"
        case .shirts:
            "셔츠"
        case .pants:
            "데님"
        case .onepiece:
            "원피스"
        case .skirt:
            "스커트"
        case .jumper:
            "점퍼"
        case .shoes:
            "신발"
        case .accessories:
            "악세사리"
            
        }
    }
    
    static func allItems() -> [ProductCategory] {
        return ProductCategory.allCases
    }
}


struct ProductResponse : Decodable {
    var title: String?
    var link: String?
    var image: String?
    var lprice: String?
    var hprice: String?
    var mallName: String?
    var productId: String?
    var productType: String?
    var brand: String?
    var maker: String?
    var category1: String?
    var category2: String?
    var category3: String?
    var category4: String?
    
    func toProduct() -> Product {
        return .init(title: title,
                     link: link,
                     imageUrl: image,
                     image: BehaviorRelay<Data?>(value: nil),
                     lprice: lprice,
                     hprice: hprice,
                     mallName: mallName,
                     productId: productId,
                     productType: productType,
                     brand: brand,
                     maker: maker,
                     category1: category1,
                     category2: category2,
                     category3: category3,
                     category4: category4)
    }
}

struct Product : Hashable, Identifiable {
    var id = UUID()
    var title: String?
    var link: String?
    var imageUrl: String?
    var image: BehaviorRelay<Data?>
    var lprice: String?
    var hprice: String?
    var mallName: String?
    var productId: String?
    var productType: String?
    var brand: String?
    var maker: String?
    var category1: String?
    var category2: String?
    var category3: String?
    var category4: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
}
