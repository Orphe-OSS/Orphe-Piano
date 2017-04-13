//
//  RoundCell.swift
//  OrpheSynth
//
//  Created by kyosuke on 2017/01/11.
//  Copyright © 2017 no new folk studio Inc. All rights reserved.
//

import UIKit

enum RoundCellState : Int {
    case normal
    case connecting
    case connected
}

class RoundCell: UITableViewCell {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var roundShapeView: UIView!
    @IBOutlet weak var sideLabel: UILabel!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        roundShapeView.layer.cornerRadius = roundShapeView.frame.height/2.0
        self.selectionStyle = .none
        
        deviceNameLabel.font = OrpheFont.bold()
        sideLabel.font = OrpheFont.bold()
        sideLabel.text = ""
        
        setState(state: .normal)
    }
    
    func setState(state:RoundCellState){
        switch state {
        case .normal:
            roundShapeView.backgroundColor = UIColor.orphePanel()
            deviceNameLabel.textColor = UIColor.orphePanelText()
            sideLabel.textColor = UIColor.orphePanelText()
            break
        case .connecting:
            roundShapeView.backgroundColor = UIColor.orphePanel()
            deviceNameLabel.textColor = UIColor.orphePanelText()
            sideLabel.textColor = UIColor.orphePanelText()
            break
        case .connected:
            roundShapeView.backgroundColor = UIColor.orpheActivePanel()
            deviceNameLabel.textColor = UIColor.orpheActivePanelText()
            sideLabel.textColor = UIColor.orpheActivePanelText()
            break
        }
        
    }
    
    
}
