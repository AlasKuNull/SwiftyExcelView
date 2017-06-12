//
//  AKExcelDateManager.swift
//  YunYingSwift
//
//  Created by AlasKu on 17/2/10.
//  Copyright © 2017年 innostic. All rights reserved.
//

import UIKit

class AKExcelDataManager: NSObject {
    
    //MARK: - Properties
    
    /// excelView
    var excelView : AKExcelView?
    /// AllExcel Data
    var dataArray : [[String]]?
    /// freezeCollection Width
    var freezeWidth : CGFloat = 0
    /// freezeColectionView cells Size
    var freezeItemSize = [String]()
    /// slideCollectionView Cells Size
    var slideItemSize = [String]()
    /// slideCollectionView Cells Size
    var slideWidth : CGFloat = 0
    /// headFreezeCollectionView Data
    var headFreezeData = [String]()
    /// headSlideCollectionView Data
    var headSlideData = [String]()
    /// contentFreezeCollectionView Data
    var contentFreezeData = [[String]]()
    /// contentSlideCollectionView Data
    var contentSlideData = [[String]]()
    
    //MARK: - Private Method
    private func loadData() {
        
        var arrM = [[String]]()
        
        if ((excelView?.headerTitles) != nil) {
            arrM.append((excelView?.headerTitles)!)
        }
        if ((excelView?.contentData) != nil) {
            for model in (excelView?.contentData)! {
                
                arrM.append(model.getValueOfPropertys(properties: excelView?.properties))
            }
        }
        dataArray = arrM
    }
    
    private func configData() {
        var freezeData = [[String]]()
        var slideData = [[String]]()
        let count = dataArray!.count
        
        for i in 0 ..< count {
            var freezeArray = [String]()
            var slideArray = [String]()
            
            let arr : [String] = dataArray![i]
            let cou = arr.count
            
            for j in 0 ..< cou {
                let value = arr[j];
                
                if (j < (excelView?.leftFreezeColumn)!) {
                    freezeArray.append(value)
                } else {
                    slideArray.append(value)
                }
            }
            freezeData.append(freezeArray)
            slideData.append(slideArray)
        }
        
        if ((excelView?.headerTitles) != nil) {
            headFreezeData = (dataArray?.first)!
            headSlideData = (dataArray?.first)!
            
            let fArray = Array(freezeData[1..<freezeData.count])
            let sArray = Array(slideData[1..<slideData.count])
            
            contentFreezeData = fArray
            contentSlideData = sArray
        } else {
            contentFreezeData = freezeData;
            contentSlideData = slideData;
        }
    }
    
    private func caculateWidths() {
        
        var fItemSize = [String]()
        var sItemSize = [String]()
        
        let col = dataArray?.first?.count
        
        for i in 0..<col! {
            
            var colW = CGFloat()
            for j in 0 ..< (dataArray?.count)! {
                
                let value = dataArray?[j][i]
                
                var size = value?.getTextSize(font: (excelView?.contentTextFontSize)!, size: CGSize.init(width: (excelView?.itemMaxWidth)!, height: (excelView?.itemHeight)!))
                if j == 0 {
                    size = value?.getTextSize(font: (excelView?.headerTextFontSize)!, size: CGSize.init(width: (excelView?.itemMaxWidth)!, height: (excelView?.itemHeight)!))
                }
                
                if ((excelView?.setsDic) != nil) {
                    
                    if let setWidth = excelView?.setsDic?[i] {
                        
                        size = CGSize.init(width: setWidth, height: (excelView?.itemHeight)!)
                    }
                }
                
                let targetWidth = (size?.width)! + 2 * (excelView?.textMargin)!;
                
                if targetWidth >= colW {
                    colW = targetWidth;
                }
                
                colW = max((excelView?.itemMinWidth)!, min((excelView?.itemMaxWidth)!, colW))
            }
            if (i < (excelView?.leftFreezeColumn)!) {
                
                fItemSize.append(NSStringFromCGSize(CGSize.init(width: colW, height: (excelView?.itemHeight)! - 1)))
                freezeWidth += colW
                
            } else {
                sItemSize.append(NSStringFromCGSize(CGSize.init(width: colW, height: (excelView?.itemHeight)! - 1)))
                slideWidth += colW
            }
        }
        freezeItemSize = fItemSize
        slideItemSize = sItemSize
    }
    
    //MARK: - Public Method
    
    func caculateData() {
        loadData()
        configData()
        caculateWidths()
    }
}

//MARK: - String Extension
extension String {
    
    func getTextSize(font:UIFont,size:CGSize) -> CGSize {
        
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let stringSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context:nil).size
        
        return stringSize
    }
}

//MARK: - 获取属性值
extension NSObject {
    
    /**
     获取对象所有的属性值，无对应的属性则返回NIL
     
     - returns: [String]
     */
    func getValueOfPropertys(properties : Array<String>?) -> [String] {
        
        if let pros = properties {
            var values = [String]()
            for pro in pros {
                values.append(self.getValueOfProperty(property: pro) as! String)
            }
            return values;
        }
        let allPropertys = self.getAllPropertys()
        var values = [String]()
        for pro in allPropertys {
            values.append(self.getValueOfProperty(property: pro) as! String)
        }
        return values;
    }
    
    
    /**
     获取对象对于的属性值，无对应的属性则返回NIL
     
     - parameter property: 要获取值的属性
     
     - returns: 属性的值
     */
    func getValueOfProperty(property:String)->AnyObject?{
        let allPropertys = self.getAllPropertys()
        if(allPropertys.contains(property)){
            return self.value(forKey: property) as AnyObject
            
        }else{
            return nil
        }
    }
    
    /**
     设置对象属性的值
     
     - parameter property: 属性
     - parameter value:    值
     
     - returns: 是否设置成功
     */
    func setValueOfProperty(property:String,value:AnyObject)->Bool{
        let allPropertys = self.getAllPropertys()
        if(allPropertys.contains(property)){
            self.setValue(value, forKey: property)
            return true
            
        }else{
            return false
        }
    }
    
    /**
     获取对象的所有属性名称
     - returns: 属性名称数组
     */
    func getAllPropertys()->[String]{
        
        var result = [String]()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(object_getClass(self), count)
        let countInt = Int(count[0])
        
        for i in 0 ..< countInt {
            let temp = buff?[i]
            let tempPro = property_getName(temp)
            
            let proper = String.init(cString: tempPro!)
//            print(proper)
            result.append(proper)
        }
        
        return result
    }
    
}
