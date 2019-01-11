
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let chart = CWBPieChart.init(frame: CGRect.init(x: 0, y: 5, width: UIScreen.main.bounds.size.width - 40, height: 120))
        chart.isShowCenterView = true
        let piemodel1 = pieChart()
        piemodel1.type = "数据1"
        piemodel1.value = 50
        let piemodel2 = pieChart()
        piemodel2.type = "数据2"
        piemodel2.value = 40
        chart.dataArray = [piemodel1,piemodel2]
        chart.colorArray = [UIColor.red,UIColor.green]
        chart.show(view: self.view)
    }
}

