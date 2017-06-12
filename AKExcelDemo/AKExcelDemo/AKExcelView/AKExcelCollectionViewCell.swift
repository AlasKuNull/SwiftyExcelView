//
//  AKExcelCollectionViewCell.swift
//  YunYingSwift
//
//  Created by AlasKu on 17/2/10.
//  Copyright © 2017年 innostic. All rights reserved.
//

import UIKit

class AKExcelCollectionViewCell: UICollectionViewCell {
    
    var horizontalMargin : CGFloat?{
        didSet{
         setupFrame()
        }
    }
    var customView : UIView? {
        didSet{
            
            if customView != nil {
            customView?.frame = bounds
            contentView.insertSubview(customView!, at: 0)
            textLabel.text = ""
            }
        }
    }
    
    lazy var textLabel : UILabel = {
       
        let label = UILabel.init()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    private lazy var separatorLayer : CAShapeLayer = {
        
       let lay = CAShapeLayer.init()
        lay.strokeColor = UIColor.lightGray.cgColor
        lay.lineWidth = 0.5
       return lay
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(textLabel)
        contentView.layer.addSublayer(separatorLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupFrame()
    }
    
    func setupFrame() {
        
        let newFrame = CGRect.init(x: horizontalMargin!, y: 0, width: bounds.size.width - 2*horizontalMargin!, height: bounds.size.height)
        
        textLabel.frame = newFrame
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: bounds.size.width - 0.5, y: 0))
        path.addLine(to: CGPoint.init(x: bounds.size.width - 0.5, y: bounds.size.height))
        
        separatorLayer.path = path.cgPath
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        customView?.removeFromSuperview()
    }
}
