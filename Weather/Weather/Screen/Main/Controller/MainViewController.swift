//
//  ViewController.swift
//  Weather
//
//  Created by 소연 on 2022/08/13.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: - UI Property
    
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var minAndMaxTempLabel: UILabel!
    
    @IBOutlet weak var tempDescriptionLabel: UILabel!
    
    @IBOutlet weak var currentDustLabel: UILabel!
    
    @IBOutlet weak var weatherDetailLabel: UILabel!
    
    @IBOutlet var stackViewCollectionView: [UIStackView]!
    
    // MARK: - Property
    
    private let locationManager = CLLocationManager()
    
    private var latitude = CLLocationCoordinate2D().latitude
    private var longtitude = CLLocationCoordinate2D().longitude
    
    private var weatherList: [WeatherData] = []
    private var main: MainData?
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM.dd(E) a HH:mm"
        return formatter
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setLocationManager()
    }
    
    // MARK: - Custom Method
    
    private func configureUI() {
        configureLabel()
        
        for stackview in stackViewCollectionView {
            stackview.layer.cornerRadius = 8
            stackview.clipsToBounds = true
        }
    }
    
    private func configureLabel() {
        [dateAndTimeLabel, locationLabel].forEach {
            $0?.textColor = .darkGray
            $0?.text = "   "
        }
        
        [currentTempLabel, minAndMaxTempLabel, tempDescriptionLabel, currentDustLabel, weatherDetailLabel].forEach {
            $0?.text = "   "
        }
        
        dateAndTimeLabel.text = formatter.string(from: Date())
    }
    
    private func configureLocationLabel(latitude: Double, longtitude: Double) {
        let currentLocation = CLLocation(latitude: latitude, longitude: longtitude)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "ko_KR")
        geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                if let name: String = address.last?.name {
                    self.locationLabel.text = name
                }
            }
        })
    }
    
    private func setLocationManager() {
        locationManager.delegate = self
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpShareButton(_ sender: UIButton) {
        
    }
    
    @IBAction func touchUpAddButton(_ sender: UIButton) {
        
    }
    
    @IBAction func touchUpSettingButton(_ sender: UIButton) {
        
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
            configureLocationLabel(latitude: latitude, longtitude: longtitude)
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

// MARK: - Network

extension MainViewController {
    private func callRequest(latitude: Double, longtitude: Double) {
        MainAPIManager.shared.fetchCurrentWeather(latitude: latitude, longtitude: longtitude) { weather, main in
            self.weatherList = weather
            
            self.main = main
            guard let mainData = self.main else { return }
            
            DispatchQueue.main.async {
                self.currentTempLabel.text = "\(Int(mainData.temp - 273))"
                self.minAndMaxTempLabel.text = "\(Int(mainData.tempMin - 273)) • \(Int(mainData.tempMax - 273))"
                
//                self.weatherDetailLabel.text = "\(self.weatherList[0].description.contains("rain") ? "비가 오네요" : "비는 안오지만 혹시 모르니 우산을 챙겨주세요")"
                self.weatherDetailLabel.text = self.weatherList[0].description
            }
        }
        
        MainAPIManager.shared.fetchWeatherHistory(latitude: latitude, longtitude: longtitude) { value in
            guard let main = self.main else { return }
            
            if main.temp > value {
                self.tempDescriptionLabel.text = "어제보다 \(main.temp - value)º 높아요"
            } else if main.temp == value {
                self.tempDescriptionLabel.text = "어제와 비슷한 온도에요"
            } else {
                self.tempDescriptionLabel.text = "어제보다 \(main.temp - value)º 낮아요"
            }
        }
        
        MainAPIManager.shared.fetchAirPollution(latitude: latitude, longtitude: longtitude) { airPollution in
            let no2 = airPollution.no2
            let pm10 = airPollution.pm10
            let o3 = airPollution.o3
            let pm25 = airPollution.pm2_5
            
            if (no2 < 50) && (pm10 < 25) && (o3 < 60) && (pm25 < 15) {
                self.setDustLabel(text: "좋음")
            } else {
                self.setDustLabel(text: "나쁨")
            }
        }
    }
    
    private func setDustLabel(text: String) {
        currentDustLabel.text = "미세먼지 • 초미세먼지 \(text)"
        let attributtedString = NSMutableAttributedString(string: currentDustLabel.text!)
        
        if text == "좋음" {
            attributtedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemMint, range: (currentDustLabel.text! as NSString).range(of:text))
        } else {
            attributtedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemOrange, range: (currentDustLabel.text! as NSString).range(of:text))
        }
        
        currentDustLabel.attributedText = attributtedString
    }
}
