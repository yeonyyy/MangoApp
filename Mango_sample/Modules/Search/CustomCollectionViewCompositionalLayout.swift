//
//  EqualHeightsUICollectionViewCompositionalLayout.swift
//  Mango_sample
//
//  Created by rayeon lee on 4/27/24.
//

import UIKit

class CustomCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    private var heights = [Int: [IndexPath: CGFloat]]()
    private var largests = [Int: CGFloat]()
    private let columns: Int
    
    private var maxHeight = CGFloat.zero
    
    init(section: NSCollectionLayoutSection, columns: Int) {
        self.columns = columns
        super.init(section: section)
    }
    
    init(columns:Int, sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) {
        self.columns = columns
        super.init(sectionProvider: sectionProvider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        heights.removeAll(keepingCapacity: true)
        largests.removeAll(keepingCapacity: true)
    }
    
    /**
     cell의 height를 동일 group 내 cell 중 가장 큰 값에 맞춤.
     */
    func updateLayoutAttributesHeight(layoutAttributes: UICollectionViewLayoutAttributes) {
        let height = layoutAttributes.frame.height
        let indexPath = layoutAttributes.indexPath
        let row = indexPath.item / columns
        
        heights[row]?[indexPath] = height
        
        largests[row] = max(largests[row] ?? 0, height)
        
        let size = CGSize(width: layoutAttributes.frame.width,
                          height: largests[row] ?? 0)
        layoutAttributes.frame = .init(origin: layoutAttributes.frame.origin, size: size)
    }
}

