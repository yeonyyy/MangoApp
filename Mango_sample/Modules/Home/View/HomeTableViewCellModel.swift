//
//  HomeTableViewCellModel.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/04.
//

import RxDataSources

struct HomeSectionModel {
    var header : String
    var items: [Promotion]
    
    init(header: String, items: [Promotion]) {
        self.header = header
        self.items = items
    }
    
}

extension HomeSectionModel : SectionModelType {
    init(original: HomeSectionModel, items: [Promotion]) {
        self = original
        self.items = items
    }
}
