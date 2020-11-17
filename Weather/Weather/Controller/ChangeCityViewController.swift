// 改变目标城市的视图控制器
import UIKit

// 改变城市代理协议声明
protocol ChangeCityDelegate {
  func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
  
  // 协议变量声明
  var delegate: ChangeCityDelegate?
  
  //This is the pre-linked IBOutlets to the text field:
  @IBOutlet weak var changeCityTextField: UITextField!
  
  
  // "GO"按钮事件响应
  @IBAction func getWeatherPressed(_ sender: AnyObject) {
    
    let cityName = changeCityTextField.text!
    
    // 如果有一个delegate设置，则调用userEnteredANewCityName()方法
    delegate?.userEnteredANewCityName(city: cityName)
    
    // 销毁CityViewController并返回到WeatherViewController
    self.dismiss(animated: true, completion: nil)
    
  }
  
  
  
  // 点击返回按钮后销毁当前ChangeCityViewController视图控制器
  @IBAction func backButtonPressed(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
