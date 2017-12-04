//
//  ExcelViewSwifty.swift
//  YunYingSwift
//
//  Created by AlasKu on 17/2/10.
//  Copyright © 2017年 innostic. All rights reserved.
//

import UIKit

let AKCollectionViewCellIdentifier = "AKCollectionView_Cell"
let AKCollectionViewHeaderIdentifier = "AKCollectionView_Header"

@objc protocol AKExcelViewDelegate : NSObjectProtocol {
    
    @objc optional func excelView(_ excelView: AKExcelView, didSelectItemAt indexPath: IndexPath)
    
    @objc optional func excelView(_ excelView: AKExcelView, viewAt indexPath: IndexPath) -> UIView?
    
    @objc optional func excelView(_ excelView: AKExcelView, attributedStringAt indexPath: IndexPath) -> NSAttributedString?
}

class AKExcelView: UIView , UICollectionViewDelegate , UICollectionViewDataSource , UIScrollViewDelegate , UICollectionViewDelegateFlowLayout{
    
    /// Delegate
    weak var delegate : AKExcelViewDelegate?
    /// CellTextMargin
    var textMargin : CGFloat = 5
    /// Cell Max width
    var itemMaxWidth : CGFloat = 200
    /// cell Min width
    var itemMinWidth : CGFloat = 50
    /// cell heihth
    var itemHeight : CGFloat = 44
    /// header Height
    var headerHeight : CGFloat = 44
    /// header BackgroundColor
    var headerBackgroundColor : UIColor = UIColor.lightGray
    /// header Text Color
    var headerTextColor : UIColor = UIColor.black
    /// header Text Font
    var headerTextFontSize : UIFont = UIFont.systemFont(ofSize: 15)
    /// contenTCell TextColor
    var contentTextColor : UIColor = UIColor.black
    /// content backgroung Color
    var contentBackgroundColor : UIColor = UIColor.white
    /// content Text Font
    var contentTextFontSize : UIFont = UIFont.systemFont(ofSize: 13)
    /// letf freeze column
    var leftFreezeColumn : Int = 1
    /// header Titles
    var headerTitles : Array<String>?
    /// content Data
    var contentData : Array<NSObject>?
    /// set Column widths
    var columnWidthSetting : Dictionary<Int, CGFloat>?
    /// CelledgeInset
    var itemInsets : UIEdgeInsets?
    /// showsProperties
    var properties : Array<String>?
    /// autoScrollItem default is false
    var autoScrollToNearItem : Bool = false
    
    //MARK: - Public Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpFrames()
    }
    
    func reloadData() {
        
        dataManager.caculateData()
        
        headFreezeCollectionView.reloadData()
        headMovebleCollectionView.reloadData()
        contentFreezeCollectionView.reloadData()
        contentMoveableCollectionView.reloadData()
        
        setUpFrames()
    }
    
    func sizeForRow(row: Int) -> CGSize {
        
        if row < leftFreezeColumn {
            return CGSizeFromString(self.dataManager.freezeItemSize[row]);
        } else {
            return CGSizeFromString(self.dataManager.slideItemSize[row - leftFreezeColumn]);
        }
    }
    
    //MARK: - Private Method
    private func setup() {
        
        dataManager.excelView = self
        clipsToBounds = true
        
        addSubview(headFreezeCollectionView)
        addSubview(contentFreezeCollectionView)
        addSubview(contentScrollView)
        
        contentScrollView.addSubview(headMovebleCollectionView)
        contentScrollView.addSubview(contentMoveableCollectionView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifi(notifi:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotifi(notifi:NSNotification) {
        
        let orientation = UIDevice.current.orientation
        if orientation != UIDeviceOrientation.portraitUpsideDown {
            UIView.animate(withDuration: 0.3, animations: {
                self.setUpFrames()
            })
        }
    }
    
    private func setUpFrames() {
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        if headerTitles != nil {
            
            headFreezeCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.freezeWidth, height: headerHeight)
            contentFreezeCollectionView.frame = CGRect.init(x: 0, y: headerHeight, width: dataManager.freezeWidth, height: height - headerHeight)
            
            contentScrollView.frame = CGRect.init(x: dataManager.freezeWidth, y: 0, width: width - dataManager.freezeWidth, height: height)
            contentScrollView.contentSize = CGSize.init(width: dataManager.slideWidth, height: height)
            
            headMovebleCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.slideWidth, height: headerHeight)
            contentMoveableCollectionView.frame = CGRect.init(x: 0, y: headerHeight, width: dataManager.slideWidth, height: height - headerHeight)
            
        }else{
            
            contentFreezeCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.freezeWidth, height: height - headerHeight)
            
            contentScrollView.frame = CGRect.init(x: dataManager.freezeWidth, y: 0, width: width - dataManager.freezeWidth, height: height)
            contentScrollView.contentSize = CGSize.init(width: dataManager.slideWidth, height: height)
            
            contentMoveableCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.slideWidth, height: height - headerHeight)
        }
    }
    
    //MARK: - 懒加载
    fileprivate let dataManager : AKExcelDataManager = AKExcelDataManager()
    
    fileprivate lazy var headFreezeCollectionView : UICollectionView = {
        
        return UICollectionView.init(delelate: self, datasource: self)
    }()

    fileprivate lazy var headMovebleCollectionView : UICollectionView = {
        
        return UICollectionView.init(delelate: self, datasource: self)
    }()

    fileprivate lazy var contentFreezeCollectionView : UICollectionView = {
        
        return UICollectionView.init(delelate: self, datasource: self)
    }()

    fileprivate lazy var contentMoveableCollectionView : UICollectionView = {
        
        return UICollectionView.init(delelate: self, datasource: self)
    }()

    fileprivate lazy var contentScrollView : UIScrollView = {
        
        let slideScrollView = UIScrollView()
        slideScrollView.bounces = false
        slideScrollView.showsHorizontalScrollIndicator = true
        slideScrollView.delegate = self
        
        return slideScrollView
    }()
}

//MARK: - UICollectionView Delegate & DataSource & collectionPrivate
extension AKExcelView {
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == headMovebleCollectionView || collectionView == headFreezeCollectionView {
            return 1
        }
        return (contentData?.count)!
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == headFreezeCollectionView || collectionView == contentFreezeCollectionView {
            return leftFreezeColumn
        } else {
            let firstBodyData = self.contentData?.first!
            
            if let pros = properties {
                return pros.count - leftFreezeColumn
            }
            let slideColumn = (firstBodyData?.propertyNames().count)! - leftFreezeColumn;
            return slideColumn
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AKCollectionViewCellIdentifier, for: indexPath) as! AKExcelCollectionViewCell
        cell.horizontalMargin = self.textMargin
        self.configCells(collectionView: collectionView, cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configCells(collectionView:UICollectionView ,cell:AKExcelCollectionViewCell ,indexPath: IndexPath) {
        
        var targetIndexPath = indexPath
        
        if collectionView == headFreezeCollectionView {
            cell.textLabel.text = headerTitles?[leftFreezeColumn - 1]
            cell.backgroundColor = headerBackgroundColor
            cell.textLabel.font = headerTextFontSize
        } else if collectionView == headMovebleCollectionView {
            
            if indexPath.item + leftFreezeColumn < (headerTitles?.count)! {
                cell.backgroundColor = headerBackgroundColor
                cell.textLabel.text = headerTitles?[indexPath.item + leftFreezeColumn]
                cell.textLabel.font = headerTextFontSize
                targetIndexPath = NSIndexPath.init(row: indexPath.row + leftFreezeColumn, section: indexPath.section) as IndexPath

            }
        }else if (collectionView == contentFreezeCollectionView) {
            let text = dataManager.contentFreezeData[indexPath.section][indexPath.row];
            cell.textLabel.text = text;
            cell.backgroundColor = contentBackgroundColor;
            cell.textLabel.textColor = contentTextColor;
            cell.textLabel.font = contentTextFontSize;

            targetIndexPath = NSIndexPath.init(row: indexPath.row, section: indexPath.section + 1) as IndexPath
        } else {
            let text = dataManager.contentSlideData[indexPath.section][indexPath.row];
            cell.textLabel.text = text;
            cell.backgroundColor = contentBackgroundColor;
            cell.textLabel.textColor = contentTextColor;
            cell.textLabel.font = contentTextFontSize;
            
            targetIndexPath = NSIndexPath.init(row: indexPath.row + leftFreezeColumn, section: indexPath.section + 1) as IndexPath
        }
        
        self.customViewInCell(cell: cell, indexPath: targetIndexPath)
        self.attributeStringInCell(cell: cell, indexPath: targetIndexPath)
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (contentData?.count == 0) {
            return CGSize.zero
        } else {
            if (collectionView == headFreezeCollectionView ||
                collectionView == contentFreezeCollectionView) {
                
                return CGSizeFromString(self.dataManager.freezeItemSize[indexPath.row]);
            } else {
                
                return CGSizeFromString(self.dataManager.slideItemSize[indexPath.row]);
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var targetIndexPath = indexPath
        if collectionView == headFreezeCollectionView {
            
        } else if (collectionView == headMovebleCollectionView) {
            targetIndexPath = NSIndexPath.init(row: indexPath.row + leftFreezeColumn, section: indexPath.section) as IndexPath
        } else if (collectionView == contentFreezeCollectionView) {
            targetIndexPath = NSIndexPath.init(row: indexPath.row, section: indexPath.section + 1) as IndexPath
        } else {
            targetIndexPath = NSIndexPath.init(row: indexPath.row + leftFreezeColumn, section: indexPath.section + 1) as IndexPath
        }
        self.delegate?.excelView?(self, didSelectItemAt: targetIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if itemInsets != nil {
            return itemInsets!
        }
        return UIEdgeInsets.zero
    }
}

//MARK: - UISCrollViewDelegate
extension AKExcelView {
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView != contentScrollView {
            contentFreezeCollectionView.contentOffset = scrollView.contentOffset
            contentMoveableCollectionView.contentOffset = scrollView.contentOffset
        }
    }
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if autoScrollToNearItem && scrollView == contentScrollView && !decelerate {
            scrollEndAnimation(scrollView: scrollView)

        }
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView && autoScrollToNearItem {
            scrollEndAnimation(scrollView: scrollView)
        }
    }
    
    func scrollEndAnimation(scrollView: UIScrollView) {
    
        let offSetX = scrollView.contentOffset.x
        
        let deltaOffSets = dataManager.slideItemOffSetX.flatMap({ (offset) -> CGFloat in
            
            return abs(offset - offSetX)
        })
        
        var min:CGFloat = deltaOffSets[0]
        
        for i in 0..<deltaOffSets.count {
            if deltaOffSets[i] < min {
                min = deltaOffSets[i]
            }
        }
        let index = deltaOffSets.index(of: min)
        let slideToOffset = dataManager.slideItemOffSetX[index!]
        
        let scrollViewWidth = bounds.size.width - dataManager.freezeWidth
        
        if dataManager.slideWidth - slideToOffset < scrollViewWidth {
            
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            scrollView.contentOffset.x = slideToOffset
        })
    }
}

//MARK: - CollectionView Extension
extension UICollectionView {
    
    /**
     *  遍历构造函数
     */
    
    convenience init(delelate: UICollectionViewDelegate , datasource: UICollectionViewDataSource){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.headerReferenceSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 1)
        
        self.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        dataSource = datasource
        delegate = delelate
        register(AKExcelCollectionViewCell.self, forCellWithReuseIdentifier: AKCollectionViewCellIdentifier)
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }

    }
}

//MARK: - AKExcelView Delegate Implemention
extension AKExcelView {
    
     func customViewInCell(cell : AKExcelCollectionViewCell , indexPath : IndexPath) {
        
        let customView = delegate?.excelView?(self, viewAt: indexPath)
            cell.customView = customView
    }
    
     func attributeStringInCell(cell: AKExcelCollectionViewCell , indexPath : IndexPath) {
        
        let attributeString = delegate?.excelView?(self, attributedStringAt: indexPath)
        if attributeString != nil {
            cell.textLabel.attributedText = attributeString
        }
    }
}





