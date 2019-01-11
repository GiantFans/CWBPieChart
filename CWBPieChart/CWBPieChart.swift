
import UIKit
//MARK:数据model
class pieChart: NSObject {
    var value = 0.0
    var type = ""
    
    fileprivate var percentage = 0.0
    fileprivate var startAngle:CGFloat = 0
    fileprivate var endAngle:CGFloat = 0
    fileprivate var start:CGFloat = 0
    fileprivate var end:CGFloat = 0
}

//MARK:饼图
class CWBPieChart: UIView {

    //MARK:参数属性
    ///数据组
    var dataArray = [pieChart]()
    ///颜色数组
    var colorArray = [UIColor]()
    
    ///选中的扇形
    fileprivate var selectIndex = 0
    
    ///中心点标题
    fileprivate var titleLabel:UILabel?
    ///外圈曲线数组
    fileprivate var pathArray = [UIBezierPath]()
    ///中心遮盖圈数组
    fileprivate var centerPathArray = [UIBezierPath]()
    ///是否显示中间遮盖视图
    var isShowCenterView = true
    ///存放闪现尾线上label的数组
    var textLabelArray = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:创建视图
    fileprivate func setLayoutView(){
        
        var totalCount = 0.0
        for model in self.dataArray {
            totalCount += model.value
        }
        if self.dataArray.count > 0 {
            if self.dataArray.count == 1 {
                self.dataArray[0].percentage = self.dataArray[0].value / totalCount
                self.dataArray[0].startAngle = 0
                self.dataArray[0].start = 0
                self.dataArray[0].endAngle = CGFloat(Double.pi * 0.005)
                self.dataArray[0].end = CGFloat(Double.pi * 0.005)
            }
            else{
                for i in 0 ..< self.dataArray.count {
                    self.dataArray[i].percentage = self.dataArray[i].value / totalCount
                    if i == 0 {
                        self.dataArray[i].startAngle = 0
                        self.dataArray[i].start = 0
                        self.dataArray[i].endAngle = CGFloat(Double.pi * 2 * (1 - self.dataArray[i].percentage))
                        self.dataArray[i].end = CGFloat(self.dataArray[i].percentage * 360.0)
                    }
                    else if i == self.dataArray.count - 1 {
                        self.dataArray[i].startAngle = self.dataArray[i - 1].endAngle
                        self.dataArray[i].endAngle = CGFloat(Double.pi * 2)
                        self.dataArray[i].start = self.dataArray[i - 1].end
                        self.dataArray[i].end = 360.0
                    }
                    else{
                        self.dataArray[i].startAngle = self.dataArray[i - 1].endAngle
                        self.dataArray[i].endAngle = self.dataArray[i].startAngle + CGFloat(Double.pi * 2 * (1 - self.dataArray[i].percentage))
                        self.dataArray[i].start = self.dataArray[i - 1].end
                        self.dataArray[i].end = self.dataArray[i].start + CGFloat(self.dataArray[i].percentage * 360.0)
                    }
                }
            }
            
        }
        if self.colorArray.count >= self.dataArray.count {
            self.addLayer()
        }
        else{
            print("颜色数组错误")
        }
        
    }
    ///添加画线
    func addLayer(){
        var dataArr = [pieChart]()
        var colorArr = [UIColor]()
        if self.dataArray.count > 0 {
            for (index,model) in self.dataArray.enumerated() {
                if index != self.selectIndex {
                    dataArr.append(model)
                }
            }
            dataArr.append(self.dataArray[self.selectIndex])
            for (index,color) in self.colorArray.enumerated() {
                if index != self.selectIndex {
                    colorArr.append(color)
                }
            }
            if self.selectIndex < self.colorArray.count {
                colorArr.append(self.colorArray[self.selectIndex])
            }
        }
        if dataArr.count > 0 {
            ///画扇形
            for (index,model) in dataArr.enumerated() {
                if index < colorArray.count {
                    self.setBezil(model:model, fillColor: colorArr[index], isSelect: index == dataArr.count - 1)
                }
            }
        }
        else{
            self.setBezil(model: nil, fillColor: UIColor.init(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1), isSelect: true)
        }
    }
    //MARK:创建曲线
    func setBezil(model:pieChart?,fillColor:UIColor,isSelect:Bool){
        let margin:CGFloat = isSelect ? 3 : 0
        let height = frame.size.width >= frame.size.height ? frame.size.height : frame.size.width
        UIGraphicsBeginImageContext(self.bounds.size)
        if model != nil && isSelect {
            ///添加扇形尾线
            self.drawTailLine(model: model!, fillColor: fillColor)
        }
        
        ///中间遮盖圆
        let layer1 = CAShapeLayer.init()
        
        if isShowCenterView {
            let path1 = UIBezierPath.init()
            path1.addArc(withCenter: self.center, radius: height * 0.25 - margin, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)
            layer1.lineWidth = 1
            layer1.strokeColor = UIColor.white.cgColor
            layer1.fillColor = UIColor.white.cgColor
            layer1.path = path1.cgPath
            path1.stroke()
            self.centerPathArray.append(path1)
        }
        
        ///外圆展示圈
        let path2 = UIBezierPath.init()
        path2.move(to: self.center)
        if model != nil {
            path2.addArc(withCenter: self.center, radius: height * 0.5 + margin - 5, startAngle: model!.startAngle, endAngle: model!.endAngle, clockwise: false)
        }
        else{
            path2.addArc(withCenter: self.center, radius: height * 0.5 + margin - 5, startAngle: 0, endAngle: CGFloat(Double.pi * 0.005), clockwise: false)
        }
        
        path2.close()
        let layer2 = CAShapeLayer.init()
        layer2.lineWidth = 1
        layer2.strokeColor = fillColor.cgColor
        layer2.fillColor = fillColor.cgColor
        layer2.path = path2.cgPath
        path2.stroke()
        UIGraphicsEndImageContext()
        self.pathArray.append(path2)
        ///添加轨迹
        self.layer.addSublayer(layer2)
        if isShowCenterView {
            self.layer.addSublayer(layer1)
        }
        
        if self.titleLabel != nil {
            self.titleLabel?.removeFromSuperview()
        }
        //添加中心标题
        if isSelect && self.isShowCenterView{
            titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: (height * 0.25 - margin) * 2, height: (height * 0.25 - margin) * 2))
            titleLabel?.center = self.center
        }
        else if isSelect {
            if model != nil {
                titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: (height * 0.25 - margin) * 2, height: (height * 0.25 - margin) * 2))
                titleLabel?.textColor = UIColor.white
                if self.dataArray.count == 0 || self.dataArray.count == 1{
                    titleLabel?.center = self.center
                }
                else{
                    titleLabel?.center = self.calcCirclePoint(center: self.center, angle: (model!.end + model!.start) * 0.5, radius: height * 0.25 - margin)
                }
            }
            else{
                titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: (height * 0.25 - margin) * 2, height: (height * 0.25 - margin) * 2))
                titleLabel?.center = self.center
                titleLabel?.textColor = UIColor.white
            }
        }
        else{
            titleLabel = UILabel()
        }
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel?.layer.masksToBounds = true
        titleLabel?.layer.cornerRadius = height * 0.25 - margin
        titleLabel?.numberOfLines = 0
        self.addSubview(titleLabel!)
        self.bringSubviewToFront(titleLabel!)
        if self.dataArray.count > 0 {
            titleLabel?.text = String.init(format: "%.2f%@", self.dataArray[self.selectIndex].percentage * 100,"%")
        }
        else{
            titleLabel?.text = "0.0%"
        }
    }
    //MARK:化扇形尾线
    func drawTailLine(model:pieChart,fillColor:UIColor){
        let path3 = UIBezierPath.init()
        path3.lineWidth = 1
        path3.move(to: self.center)
        let point1 = self.calcCirclePoint(center: self.center, angle: (model.end + model.start) * 0.5, radius: self.frame.size.height * 0.5 + 3)
        path3.addLine(to: point1)
        ///数据显示label
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 20))
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        label.text = String.init(format: "%1.f%@", model.value,model.type)
        
        if point1.x >= self.center.x {
            let point2 = CGPoint.init(x: self.frame.size.width - 5, y: point1.y)
            path3.addLine(to: point2)
            if point1.y <= frame.size.height - 30 {
                label.frame.origin = CGPoint.init(x: self.frame.size.width - 85, y: point1.y + 5)
            }
            else{
                label.frame.origin = CGPoint.init(x: self.frame.size.width - 85, y: point1.y - 25)
            }
            label.textAlignment = .right
        }
        else{
            let point2 = CGPoint.init(x: 5, y: point1.y)
            path3.addLine(to: point2)
            if point1.y <= frame.size.height - 30 {
                label.frame.origin = CGPoint.init(x: 5, y: point1.y + 5)
            }
            else{
                label.frame.origin = CGPoint.init(x: 5, y: point1.y - 25)
            }
            label.textAlignment = .left
        }
        self.addSubview(label)
        self.textLabelArray.append(label)
        let layer = CAShapeLayer.init()
        layer.strokeColor = fillColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.path = path3.cgPath
        path3.stroke()
        self.layer.addSublayer(layer)
    }
    //MARK:根据角度计算圆上的坐标
    fileprivate func calcCirclePoint(center:CGPoint,angle:CGFloat,radius:CGFloat) -> CGPoint{
        let x2 = radius * CGFloat(cos(Float(angle * CGFloat(Double.pi / 180.0))))
        let y2 = radius * CGFloat(sin(Float(angle * CGFloat(Double.pi / 180.0))))
        return CGPoint.init(x: center.x + x2, y: center.y - y2)
    }
    //MARK:刷新页面
    func reloadSubLayer(){
        if self.layer.sublayers != nil && self.layer.sublayers!.count > 0 {
            for layer in self.layer.sublayers! {
                if layer.isKind(of: CAShapeLayer.classForCoder()) {
                    layer.removeFromSuperlayer()
                }
            }
            if self.textLabelArray.count > 0 {
                for label in self.textLabelArray {
                    label.removeFromSuperview()
                }
                self.textLabelArray.removeAll()
            }
        }
        
        self.addLayer()
    }
    
    //AMRK:点击事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tou = touches.first {
            let point = tou.location(in: self)
            //两点距离
            let distance = sqrt(pow((point.x - self.frame.size.width * 0.5), 2) + pow((point.y - self.frame.size.height * 0.5), 2))
            if isShowCenterView {
                if distance <= self.frame.size.height * 0.5 - 5 && distance > self.frame.size.height * 0.25{
                    self.selectIndex = self.pointIndex(point: point)
                    self.reloadSubLayer()
                }
            }
            else{
                if distance <= self.frame.size.height * 0.5 {
                    self.selectIndex = self.pointIndex(point: point)
                    self.reloadSubLayer()
                }
            }
        }
    }
    
    //MARK:展示页面
    func show(view:UIView){
        self.setLayoutView()
        view.addSubview(self)
    }
    deinit {
        print("销毁 - 饼图自定义")
    }
    
    //MARK:判断点的位置
    fileprivate func pointIndex(point:CGPoint) -> Int{
        let a:CGFloat = self.frame.size.height * 0.5 - 5
        let b:CGFloat = 0
        
        let c:CGFloat = point.x - self.frame.size.width * 0.5
        let d:CGFloat = point.y - self.frame.size.height * 0.5
        
        var rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))))
        
        if point.y > self.frame.size.height * 0.5 {
            rads = -rads
        }
        
        var ang = rads * 180.0 / CGFloat(Double.pi)
        if ang < 0 {
            ang = 360.0 + ang
        }
        
        var angArray = [(CGFloat,CGFloat)]()
        var startAngle:CGFloat = 0.0
        for (index,model) in self.dataArray.enumerated() {
            if index == 0 {
                let aa = (CGFloat(0),CGFloat(model.percentage * 360.0))
                angArray.append(aa)
            }
            else if index == self.dataArray.count - 1 {
                let aa = (startAngle,CGFloat(360.0))
                angArray.append(aa)
            }
            else{
                let aa = (startAngle,startAngle + CGFloat(model.percentage * 360.0))
                angArray.append(aa)
            }
            startAngle += CGFloat(model.percentage * 360.0)
        }
        var ind = 0
        
        for (index,yz) in angArray.enumerated() {
            if ang >= yz.0 && ang < yz.1 {
                ind = index
                break
            }
        }
        
        return ind
    }
}

