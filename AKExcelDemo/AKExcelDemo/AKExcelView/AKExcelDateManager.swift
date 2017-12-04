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
    /// slideItemOffSetX
    var slideItemOffSetX = [CGFloat]()
    
    //MARK: - Private Method
    private func loadData() {
        
        var arrM = [[String]]()
        
        if ((excelView?.headerTitles) != nil) {
            arrM.append((excelView?.headerTitles)!)
        }
        if ((excelView?.contentData) != nil) {
            for model in (excelView?.contentData)! {
                
                arrM.append(model.valuesFor(excelView?.properties))
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
                
                if ((excelView?.columnWidthSetting) != nil) {
                    
                    if let setWidth = excelView?.columnWidthSetting?[i] {
                        
                        size = CGSize.init(width: setWidth, height: (excelView?.itemHeight)!)
                    }
                }
                
                let targetWidth = (size?.width)! + 2 * (excelView?.textMargin)!;
                
                if targetWidth >= colW {
                    colW = targetWidth;
                }
                
                colW = max((excelView?.itemMinWidth)!, min((excelView?.itemMaxWidth)!, colW))
            }
            // 滑动scroll节点
            slideItemOffSetX.append(slideWidth)
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
        
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        
        let stringSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : Any] , context:nil).size
        
        return stringSize
    }
}


extension NSObject
{
    func propertyNames() -> [String] {
        
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }
    
    func valueFor(_ property:String) -> String? {
        
        var value : String?
        for case let (label?, anyValue) in Mirror(reflecting:self).children {
            if label.isEqual(property) {
                value = anyValue as? String
                //                return anyValue as? String
            }
        }
        return value
    }
    
    func valuesFor(_ properties:[String]?) -> [String] {
        
        if let pros = properties {
            var arrM = [String]()
            for pro in pros {
                arrM.append(valueFor(pro)!)
            }
            return arrM
        }
        
        var values = [String]()
        for case let (_?, anyValue) in Mirror(reflecting:self).children {
            
            values.append(anyValue as? String ?? "")
        }
        return values
    }
}

