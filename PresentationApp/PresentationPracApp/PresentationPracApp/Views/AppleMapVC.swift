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
    
    let locationManager = CLLocationManager()
    let pSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
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
        
        locationManager.startMonitoringSignificantLocationChanges()
//        // ユーザの現在位置をupdate
//        locationManager.startUpdatingLocation()
        
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
    
}
