# *SimpleWeather*

## 构思(Conceive)

​		这次的iOS作品是简化版本的天气软件,仅仅显示当前的天气状况.就像是现在许多安卓手机的"禅定模式"那样,*SimpleWeather*让用户专注于**最重要**的信息,而不受更多信息的打扰——正如iOS的设计语言那样.

## 设计(Design)

​		APP的主界面如图所示,只有三个信息元素:温度、气候、城市,没有任何多余的信息,用户只需专注于当下.

​		右上角提供了手动的城市切换,这里用的是Segues的方法.

<img src="C:\Users\TsuiPo\Desktop\1.PNG" style="zoom: 25%;" />

​		手动切换城市界面提供了输入框和"GO"按钮,我将其设置为与背景接近的颜色,希望用户在熟悉控件位置后能够实现盲操.

<img src="C:\Users\TsuiPo\Desktop\2.PNG" style="zoom:25%;" />

## 实现(Implement)

​		天气数据的获取是通过`openweathermap.org`提供的API实现的,具体来说采用了`Alamofire`来进行HTTP请求,采用`SwiftJson`对回传的信息进行解析.

## 运营(Operate)

​		目前在Github上开源,仓库地址:`https://github.com/PoTsui99/iOS_Homework`.

