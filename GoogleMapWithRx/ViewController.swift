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
    
    var spaces: [Space] = []
    
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
        getSpacesByApi()
        
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
            })
            .disposed(by: disposeBag)
        
        // marker タップ検知
        mapView.rx.selectedMarker.asDriver()
            .drive(onNext: { [weak self] selected in
                guard let _self = self else { return }
                if let marker = selected {
                    print("Selected marker: \(marker.title ?? "") (\(marker.position.latitude), \(marker.position.longitude))")
                    _self.changeCollectionViewState(isHidden: false)
                } else {
                    print("Selected marker: nil")
                }
            })
            .disposed(by: disposeBag)
        
        mapView.rx.didTapInfoWindowOf.asDriver()
            .drive(onNext: { print("Did tap info window of marker: \($0)") })
            .disposed(by: disposeBag)
        
        mapView.rx.willMove.asDriver()
            .drive(onNext: { [weak self] isUserGesture in
                guard let _self = self else { return }
                if isUserGesture {
                    _self.changeCollectionViewState(isHidden: true)
                }
            })
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
    
    fileprivate func getSpacesByApi() {
        sleep(2)
        // NOTE: 本来はAPIで取得する
        spaces = [
            Space(id: 1, name: "【20:00-29:00】当日レンタルOK！ドリンク飲み放題ダーツカラオケ完備のパーティールーム", latitude: 35.905367, longitude: 139.621681, minPrice: 1000),
            Space(id: 2, name: "大宮駅徒歩5分　きれいな38名収容貸し会議室", latitude: 35.907539, longitude: 139.629888, minPrice: 1000),
            Space(id: 3, name: "【大宮】清潔感が好評！落ち着いた雰囲気の中会議室(18名様)", latitude: 35.911128, longitude: 139.625505, minPrice: 1000),
            Space(id: 4, name: "foo", latitude: 35.911128, longitude: 140.625505, minPrice: 1000)
        ]
        setMarker()
    }
    
    fileprivate func setMarker() {
        guard spaces.count > 0 else { return }
        do {
            func configureMarker(space: Space) {
                let marker = GMSMarker(
                    position: CLLocationCoordinate2D(
                        latitude: space.latitude,
                        longitude: space.longitude
                    )
                )
                marker.title = "¥1,000"
                marker.isDraggable = true
                marker.icon = #imageLiteral(resourceName: "marker_normal")
                marker.map = mapView
            }
            spaces.map { configureMarker(space: $0) }
        }
        collectionView.reloadData()
    }
    
    fileprivate func prepareCollectionView() {
//        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
//        layout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func changeCollectionViewState(isHidden: Bool) {
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let _self = self else { return }
            _self.collectionViewBottomMarginConstraint.constant = isHidden ? -138 : 0
            _self.view.layoutIfNeeded()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell
        print("🎰")
        return cell
    }
}

