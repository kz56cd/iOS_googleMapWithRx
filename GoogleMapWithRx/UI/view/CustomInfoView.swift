//
//  CustomInfoView.swift
//  GoogleMapWithRx
//
//  Created by Masakazu Sano on 2018/06/12.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import UIKit
import Prelude

final class CustomInfoView: UIView, XibInstantiatable {
    @IBOutlet private weak var titleLabel: UILabel!
    
//    override var isSelected: Bool {
//        didSet {
//            selectedCell.isHidden = !isSelected
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate(isUserInteractionEnabled: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate(isUserInteractionEnabled: false)
    }
}

extension CustomInfoView {
    func configure(title: String) {
        titleLabel.text = title
    }
}
