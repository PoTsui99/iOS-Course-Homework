import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
  
  // 天气API
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "c0368fd69694c4dc0d8caa4a32946ec9"
  
  // 实例变量
  let locationManager = CLLocationManager()
  let weatherDataModel = WeatherDataModel()
  
  // 组件连接
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var cityLabel: UILabel!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  
  
  // MARK: - 网络连接,获得数据,更新天气数据
  func getWeatherData(url: String, parameters: [String: String]) {
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
      response in
      if response.result.isSuccess {
        print("成功获取气象数据")
        let weatherJSON: JSON = JSON(response.result.value!)
        self.updateWeatherData(json: weatherJSON)
      }else {
        print("错误 \(String(describing: response.result.error))")
        self.cityLabel.text = "连接问题"
      }
    }
  }
  
  
  // MARK: - JSON 解析

  // 更新天气
  func updateWeatherData(json: JSON) {
    if let tempResult = json["main"]["temp"].double {
      weatherDataModel.temperature = Int(tempResult - 273.15)
      weatherDataModel.city = json["name"].stringValue
      weatherDataModel.condition = json["weather"]["id"].intValue
      weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
      
      updateUIWithWeatherData()
    }else {
      cityLabel.text = "气象信息不可用"
    }
  }
  
  
  
  
  // MARK: - UI Updates
  // UI更新天气
  func updateUIWithWeatherData() {
    cityLabel.text = weatherDataModel.city
    temperatureLabel.text = String(weatherDataModel.temperature) + "°"
    weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
  }
  
  
  // MARK: - 位置管理器代理方法
  
  // 得到地址
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[locations.count - 1]
    
    if location.horizontalAccuracy > 0 {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      
      print("经度 = \(location.coordinate.longitude)，纬度 = \(location.coordinate.latitude)")
      
      let latitude = String(location.coordinate.latitude)
      let longitude = String(location.coordinate.longitude)
      
      let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
      getWeatherData(url: WEATHER_URL, parameters: params)
    }
  }
  
  // 定位: 传入错误对象
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
    cityLabel.text = "定位失败"
  }
  
  
  
  
  // MARK: - 修改城市代理方法
  
  // Write the userEnteredANewCityName Delegate method here:
  func userEnteredANewCityName(city: String) {
    let params: [String: String] = ["q": city, "appid": APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
  }
  
  
  // Write the PrepareForSegue Method here
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "changeCityName" {
      let destinationVC = segue.destination as! ChangeCityViewController
      destinationVC.delegate = self
    }
  }
  
  
  
  
}


