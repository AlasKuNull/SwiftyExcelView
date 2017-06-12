//
//  Model.swift
//  AKExcelDemo
//
//  Created by 吴莎莉 on 2017/5/31.
//  Copyright © 2017年 alasku. All rights reserved.
//

import UIKit

class Model: NSObject {

    var productNo : String?
    var productName : String?
    var specification : String?
    var quantity : String?
    var note : String?
    var pro : String?

    init(dict:[String : AnyObject]) {
        super.init()
        setValuesForKeys(dict)
    }
    override init() {
        super.init()
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}

    
}
