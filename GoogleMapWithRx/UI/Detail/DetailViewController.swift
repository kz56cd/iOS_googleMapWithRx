//
//  DetailViewController.swift
//  GoogleMapWithRx
//
//  Created by Masakazu Sano on 2018/06/10.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension DetailViewController {
    fileprivate func bind() {
        closeButton.rx.tap.asDriver()
            .drive(onNext: {[weak self] in
                guard let _self = self else { return }
                _self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
