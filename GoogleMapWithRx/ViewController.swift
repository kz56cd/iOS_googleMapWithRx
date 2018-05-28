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
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomMarginConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        prepareCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMarker()
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
            .drive(onNext: {[weak self] in
                guard let _self = self else { return }
                print("0️⃣ Did change position: \($0)")
//                _self.changeCollectionViewState(isHidden: true)
            })
            .disposed(by: disposeBag)
        
        // marker タップ検知
        mapView.rx.didTapAt.asDriver()
            .drive(onNext: {[weak self] in
                guard let _self = self else { return }
                print("Did tap at coordinate: \($0)")
                _self.changeCollectionViewState(isHidden: false)
            })
            .disposed(by: disposeBag)
        
        mapView.rx.didBeginDragging.asDriver()
            .drive(onNext: {[weak self] in
                guard let _self = self else { return }
                print("0️⃣ Did begin drug: \($0)")
                _self.changeCollectionViewState(isHidden: true)
            })
        
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
    
    fileprivate func setMarker() {
        let center = CLLocationCoordinate2D(
            latitude: 35.906295,
            longitude: 139.623999
        )
        
        do {
            let marker = GMSMarker(position: center)
            marker.title = "Hello, RxSwift"
            marker.isDraggable = true
            marker.icon = #imageLiteral(resourceName: "marker_normal")
            marker.map = mapView
        }
    }
    
    fileprivate func prepareCollectionView() {
//        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
//        layout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func changeCollectionViewState(isHidden: Bool) {
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let _self = self else { return }
            _self.collectionViewBottomMarginConstraint.constant = isHidden ? -138 : 0
            _self.view.layoutIfNeeded()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell
        print("🎰")
        return cell
    }
}

