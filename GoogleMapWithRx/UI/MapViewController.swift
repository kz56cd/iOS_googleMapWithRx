//
//  MapViewController.swift
//  GoogleMapWithRx
//
//  Created by Masakazu Sano on 2018/05/25.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import UIKit
import RxSwift
import GoogleMaps
import RxGoogleMaps
import Prelude

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
//    var spaces: [Space] = []
    var markerInfos: [MarkerInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        prepareCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testScroll()
    }
}

extension MapViewController {
    // MARK: - for google map
    fileprivate func configureMapView() {
        mapView.isMyLocationEnabled = true
        
        // marker情報の配列を取得 -> mapにセット
        markerInfos = getSpacesByApi().map { MarkerInfo(space: $0) }
        setMarker()
        bind()
    }
    
    fileprivate func bind() {
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
    
    fileprivate func getSpacesByApi() -> [Space] {
        // NOTE: 本来はAPIで、Spaceモデルの配列を取得する
        var spaces = [
            Space(id: 1, name: "部屋数多数！レンタルスペース", latitude: 35.905367, longitude: 139.621681, minPrice: 1000),
            Space(id: 2, name: "駅近の貸し会議室", latitude: 35.907539, longitude: 139.629888, minPrice: 1000),
            Space(id: 3, name: "落ち着いた雰囲気のセレモニーホール", latitude: 35.911128, longitude: 139.625505, minPrice: 1000),
        ]
        for i in 0...20 {
            let long = 139.635505 + (Double(i) / 200)
            spaces.append(Space(id: i + 3, name: "foo", latitude: 35.911128, longitude: long, minPrice: 1000))
        }
        return spaces
    }
    
    fileprivate func setMarker() {
        guard markerInfos.count > 0 else { return }
        _ = markerInfos.map { $0.marker.map = mapView }
        collectionView.reloadData()
    }
    
    // MARK: - for fixed area (collection view)
    fileprivate func prepareCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        collectionView.registerClassForCellWithType(SpaceCollectionCell.self)
    }
    
    fileprivate func changeCollectionViewState(isHidden: Bool) {
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let _self = self else { return }
            _self.collectionViewBottomMarginConstraint.constant = isHidden
                ? -(_self.collectionViewHeightConstraint.constant - 35)
                : 0
            _self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func testScroll() {
        sleep(3)
        collectionView.scrollToItem(
            at: IndexPath(row: markerInfos.count - 3, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
}

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return markerInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithType(SpaceCollectionCell.self, forIndexPath: indexPath)
        cell.configure(by: markerInfos[indexPath.row].space)
        return cell
    }
}

struct MarkerInfo {
    let marker: GMSMarker
    let space: Space
    
    init(space: Space) {
        self.space = space
        
        marker = GMSMarker(
            position: CLLocationCoordinate2D(
                latitude: space.latitude,
                longitude: space.longitude
            )
        )
        marker.title = "¥ \(space.minPrice)(\(space.id))"
        marker.isDraggable = true
        marker.icon = #imageLiteral(resourceName: "marker_normal")
    }
}
