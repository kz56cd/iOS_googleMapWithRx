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
import MaterialComponents
import Prelude

class MapViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var researchButton: MDCButton!
    
    // MARK: - Property
    let disposeBag = DisposeBag()
    var markerInfos: [MarkerInfo] = []
    var selectedIndexPath: IndexPath? = nil {
        didSet {
            guard let indexPath = selectedIndexPath,
                let oldPath = oldValue else {
                return
            }
            collectionView.reloadItems(at: [indexPath, oldPath])
            scrollCell(by: indexPath)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        prepareCollectionView()
    }
}

extension MapViewController {
    // MARK: - for google map
    fileprivate func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
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
                guard let _self = self,
                    let marker = selected else {
                    return
                }
                print("Selected marker: \(marker.title ?? "") (\(marker.position.latitude), \(marker.position.longitude))")
                _self.changeCollectionViewState(isHidden: false)
                
                let indexPath = _self.markerInfos
                    .enumerated()
                    .filter { $1.marker == marker }
                    .compactMap { IndexPath(row: $0.offset, section: 0) }
                    .first
                
                guard _self.selectedIndexPath != indexPath else { return }
                _self.selectedIndexPath = indexPath
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
        
        mapView.rx.handleMarkerInfoWindow { marker -> (UIView?) in
//            guard let _self = self else { return nil }
            let view = CustomInfoView(frame:
                CGRect(
                    origin: CGPoint.zero,
                    size: CGSize(width: 100, height: 30)
                )
            )
            view.configure(title: marker.title ?? "???")
            return view
        }
    }
    
    fileprivate func getSpacesByApi() -> [Space] {
        // NOTE: 本来はAPIで、Spaceモデルの配列を取得する
        var spaces = [
            Space(id: 1, name: "部屋数多数！レンタルスペース", latitude: 35.905367, longitude: 139.621681, minPrice: 1000),
            Space(id: 2, name: "駅近の貸し会議室", latitude: 35.907539, longitude: 139.629888, minPrice: 1000),
            Space(id: 3, name: "落ち着いた雰囲気のセレモニーホール", latitude: 35.911128, longitude: 139.625505, minPrice: 1000),
        ]
        for i in 0...37 {
            let long = 139.635505 + (Double(i) / 200)
            spaces.append(Space(id: i + 4, name: "foo", latitude: 35.911128, longitude: long, minPrice: 1000))
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
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let _self = self else { return }
            _self.collectionViewBottomMarginConstraint.constant = isHidden
                ? -(_self.collectionViewHeightConstraint.constant - 35)
                : 0
            _self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func scrollCell(by indexPath: IndexPath?) {
         guard let indexPath = indexPath else { return }
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
    
    // MARK: - routing
    func presentDetail() {
        present(
            StoryboardScene.DetailViewController.initialScene.instantiate(),
            animated: true,
            completion: nil
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
        cell.isSelected = selectedIndexPath?.row == indexPath.row
        return cell
    }
}

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        func willMoveMarkerAndCamera() {
            let markerInfo = markerInfos[indexPath.row]
            mapView.selectedMarker = markerInfo.marker
            mapView.animate(
                to: GMSCameraPosition.camera(
                    withLatitude: markerInfo.space.latitude,
                    longitude: markerInfo.space.longitude,
                    zoom: 14
                )
            )
        }
        
        if let selectedIndexPath = selectedIndexPath {
            guard selectedIndexPath != indexPath else {
                presentDetail()
                return
            }
            willMoveMarkerAndCamera()
        } else {
            willMoveMarkerAndCamera()
        }
    }
}
