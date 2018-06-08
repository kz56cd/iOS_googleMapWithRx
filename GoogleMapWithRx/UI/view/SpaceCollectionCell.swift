//
//  SpaceCollectionCell.swift
//  GoogleMapWithRx
//
//  Created by Masakazu Sano on 2018/06/08.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import UIKit
import Prelude

final class SpaceCollectionCell: UICollectionViewCell, XibInstantiatable {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedCell: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }
}

extension SpaceCollectionCell {
    func configure(by space: Space) {
        idLabel.text = "\(space.id)"
        nameLabel.text = space.name
    }
}


