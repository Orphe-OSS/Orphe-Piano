//
//  RoundButton.swift
//  OrpheSynth
//
//  Created by kyosuke on 2017/02/09.
//  Copyright © 2017 no new folk studio Inc. All rights reserved.
//

import UIKit

class RoundButton:UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        titleLabel?.font = OrpheFont.bold()
        layer.cornerRadius = self.frame.height/2.0
        backgroundColor = UIColor.orphePanel()
        tintColor = UIColor.orpheBlack()
    }
}
