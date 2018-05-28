//
//  ViewController.swift
//  GoogleMapWithRx
//
//  Created by Masakazu Sano on 2018/05/25.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import UIKit
import RxSwift
import GoogleMaps
import RxGoogleMaps

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: GMSMapView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
}

extension ViewController {
    fileprivate func configureMapView() {
        mapView.camera = GMSCameraPosition.camera( // 大宮駅
            withLatitude: 35.906295,
            longitude: 139.623999,
            zoom: 14
        )

        // camera ポジション変更 検知
        mapView.rx.didChange.asDriver()
            .drive(onNext: { print("0️⃣ Did change position: \($0)") })
            .disposed(by: disposeBag)
        
        // marker タップ検知
        mapView.rx.didTapAt.asDriver()
            .drive(onNext: { print("Did tap at coordinate: \($0)") })
            .disposed(by: disposeBag)
        
        // location 更新
        mapView.rx.myLocation
            .subscribe(onNext: { location in
                if let l = location {
                    print("My location: (\(l.coordinate.latitude), \(l.coordinate.longitude))")
                } else {
                    print("My location: nil")
                }
            })
            .disposed(by: disposeBag)
    }
}

