//
//  Promotion.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import Foundation

enum PromotionType : String, Codable, CaseIterable, CustomStringConvertible {
    case total, trends, ideatip, lifestyle, sustainability, mangoCommunity
    
    var description: String {
        switch self {
        case .total: return "전체"
        case .trends: return "Trends"
        case .ideatip: return "아이디어와 팁"
        case .lifestyle: return "Lifestyle"
        case .sustainability: return "Sustainability"
        case .mangoCommunity: return "MangoCommunity"
        }
    }
    
    static func allItems() -> [String] {
        return PromotionType.allCases.map({ $0.description })
    }
    
}

struct Promotion: Codable {
    let id: Int
    let imageName: String?
    let imageUrl: String?
    let title: String?
    let desc: String?
    let promotionType : PromotionType?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        imageName = try? values.decode(String.self, forKey: .imageName)
        imageUrl = try? values.decode(String.self, forKey: .imageUrl)
        title = try? values.decode(String.self, forKey: .title)
        desc = try? values.decode(String.self, forKey: .desc)
        promotionType = try? values.decode(PromotionType.self, forKey: .promotionType)
        
        
    }
    
}
