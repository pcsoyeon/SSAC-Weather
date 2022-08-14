//
//  ViewController.swift
//  Weather
//
//  Created by 소연 on 2022/08/13.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: - Property
    
    private let locationManager = CLLocationManager()
    
    private var latitude = CLLocationCoordinate2D().latitude
    private var longtitude = CLLocationCoordinate2D().longitude
    
    private var weatherList: [WeatherData] = []
    private var main: MainData?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationManager()
    }
    
    // MARK: - Custom Method
    
    private func setLocationManager() {
        locationManager.delegate = self
    }
    
    private func callRequest(latitude: Double, longtitude: Double) {
        MainAPIManager.shared.fetchCurrentWeather(latitude: latitude, longtitude: longtitude) { weather, main in
            print("==================== 🟡 Weather 🟡 ====================")
            self.weatherList = weather
            print(self.weatherList)
            
            print("==================== 🟢 Main 🟢 ====================")
            self.main = main
            print(self.main)
        }
        
        MainAPIManager.shared.fetchWeatherHistory(latitude: latitude, longtitude: longtitude) { json in
            print("==================== 🔵 Weather History 🔵 ====================")
            print(json)
        }
    }
}

// MARK: - Authorization

extension MainViewController {
    func checkUserDeviceLocationServiceAuthorization() {
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            checkUserCurrentLocationAuthorization(authorizationStatus)
        } else {
            print("위치 서비스가 꺼져 있어 위치 권한 요청을 하지 못합니다.")
        }
    }
    
    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            print("NOT DETERMINED")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            print("DENIED, 아이폰 설정으로 유도")
            showRequestLocationServiceAlert()
        case .authorizedWhenInUse:
            print("WHEN IN USE")
            locationManager.startUpdatingLocation()
        default:
            print("DEFAULT")
        }
    }
    
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .default)
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)
        
        present(requestLocationServiceAlert, animated: true, completion: nil)
    }
}

// MARK: - CLLocation Protocol

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, locations)
        
        if let coordinate = locations.last?.coordinate {
            latitude = coordinate.latitude
            longtitude = coordinate.longitude
            
            callRequest(latitude: latitude, longtitude: longtitude)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkUserDeviceLocationServiceAuthorization()
    }
}
