//
//  AppleMapVC.swift
//  PresentationPracApp
//
//  Created by Kyus'lee on 2022/12/11.
//

import UIKit
import MapKit

class AppleMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.setImage(UIImage(systemName: "multiply")?.withRenderingMode(.alwaysOriginal), for: .normal)
            dismissButton.tintColor = .systemGray3
        }
    }
    
    // latitude: 緯度
    // longitude:　経度
    // 東京タワーを例とした
    let mark = Marker(title: "東京タワー", subtitle: "日本の首都である、東京のランドマーク", coordinate: CLLocationCoordinate2D(latitude: 35.658581, longitude: 139.745433))
    
    let tokyoTowerLocate = CLLocationCoordinate2D(latitude: 35.658581, longitude: 139.745433)
    
    var locationManager = CLLocationManager()
    let pSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    // 現在の位置情報保存
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 🔥途中の段階
        // Map上のzoom設定を行う必要がある
        // markerをクリックすると、zoomされるように今後設定する
        mapView.delegate = self
        mapView.setRegion(MKCoordinateRegion(center: tokyoTowerLocate, span: pSpanValue), animated: true)
        
        //pinを立てる
        mapView.addAnnotation(mark)
        // zoom可能
        mapView.isZoomEnabled = true
        // scroll可能
        mapView.isScrollEnabled = true
        // ２本の指のtouchを可能に (まだの段階)
        mapView.isUserInteractionEnabled = true
        
        
        locationManager.delegate = self
        // 正確度設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 位置データ承認リクエスト
        locationManager.requestWhenInUseAuthorization()
        // ユーザの現在位置をupdate
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AppleMapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager = manager
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            currentLocation = locationManager.location
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // iOS14から追加された新しいプロパティ
        switch manager.authorizationStatus {
        case .notDetermined: // 初回呼び出し時、設定で次回確認を選択時
            print("notDetermined")
            break
        case .restricted: // ペアレンタルコントロールなどの制限あり
            print("restricted")
            break
        case .denied: // 使用拒否した
            print("denied")
            break
        case .authorizedAlways: // いつでも位置情報サービスを開始することを許可した
            print("authorizedAlways")
            manager.startUpdatingLocation() // 位置情報の取得開始
            break
        case .authorizedWhenInUse: // アプリ使用中のみ位置情報サービスを開始することを許可した
            print("authorizedWhenInUse")
            manager.startUpdatingLocation() // 位置情報の取得開始
        @unknown default:
            break
        }
          
        // iOS14から追加された位置情報精度
        switch manager.accuracyAuthorization {
        case .fullAccuracy: // 正確な位置情報
            print("fullAccuracy")
            break
        case .reducedAccuracy: // おおよその位置情報
            print("reducedAccuracy")
            break
        @unknown default:
            break
        }
    }
}
