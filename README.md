# SwiftyExcelView
This example project shows a way to show A Form like Excel in Swift.
# Screenshot
![image](https://github.com/AlasKuNull/SwiftyExcelView/blob/master/AKExcelDemo/AKExcelDemo/demo.gif)
# Useage
Drag AKExcelCollectionViewCell.swift , AKExcelDateManager.swift and AKExcelView.swift into your project.
Demo shows detail how to use this.
```
        let excelView : AKExcelView = AKExcelView.init(frame: CGRect.init(x: 0, y: 20, width: AKScreenWidth, height: AKScreenHeight - 20))
        // 自动滚到最近的一列
        excelView.autoScrollToNearItem = true
        // 设置表头背景色
        excelView.headerBackgroundColor = UIColor.cyan
        // 设置表头
        excelView.headerTitles = ["货号","品名","规格","数量","说明"]
        // 设置间隙
        excelView.textMargin = 20
        // 设置左侧冻结栏数
        excelView.leftFreezeColumn = 1
        // 设置对应模型里面的属性  按顺序
        excelView.properties = ["productNo","productName","specification","quantity","note"]
        excelView.delegate = self
        // 指定列 设置 指定宽度  [column:width,...]
        excelView.columnWidthSetting = [3:180]
        var arrM = [Model]()
        for i in 0 ..< 50 {
            
            let model = Model()
            model.productNo = String.init("货号 - \(i)")
            model.productName = String.init("品名 - \(i)")
            model.specification = String.init("规格  - \(i)")
            model.quantity = String.init("数量 - \(i)")
            model.note = String.init("说明说明说明说明说明说明说明说明 - \(i)")
            model.pro = "others ..."
            
            arrM.append(model)
        }
        // 设置数据
        excelView.contentData = arrM
  
        view.addSubview(excelView)
        // 刷新
        excelView.reloadData()
        
```
# Thanks 
[BSNumbersView](https://github.com/blurryssky/BSNumbersView) , A form like Excel in Objective-C
