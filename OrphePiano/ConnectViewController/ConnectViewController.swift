//
//  ConnectViewController.swift
//
//
//  Created by no new folk studio Inc. on 2016/10/18.
//  Copyright © 2016 no new folk studio Inc. All rights reserved.
//


import UIKit
import Orphe
import SVProgressHUD

class ConnectViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sideSwitchButton: UIButton!
    @IBOutlet weak var doneButton: RoundButton!
    
    var rssiTimer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        
        self.view.backgroundColor = UIColor.orpheModalBackground()
        self.tableView.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        
        descriptionLabel.font = OrpheFont.regular()
        descriptionLabel.tintColor = UIColor.orpheTextBackground()
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ORPManager.sharedInstance.delegate = self
        ORPManager.sharedInstance.isEnableAutoReconnection = false
        ORPManager.sharedInstance.startScan()
        rssiTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ConnectViewController.readRSSI), userInfo: nil, repeats: true)
        
        tableView.reloadData()
        updateCellsState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addConstraint(NSLayoutConstraint(item: doneButton,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: -view.bounds.height*0.12))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ORPManager.sharedInstance.stopScan()
        ORPManager.sharedInstance.isEnableAutoReconnection = true
        ORPManager.sharedInstance.autoReconnectionTimeLimitSec = 10
        rssiTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func updateCellsState(){
        for (index, orp) in ORPManager.sharedInstance.availableORPDataArray.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? RoundCell {
                switch orp.state() {
                case .connected:
                    cell.setState(state: .connected)
                    let sideStr = ["L","R"]
                    cell.sideLabel.text = sideStr[orp.side.hashValue]
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
                default:
                    cell.setState(state: .normal)
                }
            }
        }
    }
    
    func readRSSI(){
        for orp in ORPManager.sharedInstance.connectedORPDataArray {
            orp.readRSSI()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchSideButtonAction(_ sender: UIButton) {
        for orp in ORPManager.sharedInstance.connectedORPDataArray {
            orp.switchToOppositeSide()
        }
        updateCellsState()
    }
    
}

//MARK: - UITableViewDelegate
extension ConnectViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        PRINT("didSelect")
        let orp = ORPManager.sharedInstance.availableORPDataArray[indexPath.row]
        
        if ORPManager.sharedInstance.getConnectedOrpheNum() < 2{
            ORPManager.sharedInstance.connect(orphe: orp)
            SVProgressHUD.show(withStatus: "Connecting...")
        }
        else{
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        PRINT("didDeselect")
        let orp = ORPManager.sharedInstance.availableORPDataArray[indexPath.row]
        
        if orp.state() == .connected{
            
            let alert: UIAlertController = UIAlertController(title: "Disconnect", message: "Are you sure you want to disconnect Orphe?", preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                ORPManager.sharedInstance.disconnect(orphe: orp)
            })
            
            let cancelAction = UIAlertAction(title: "NO", style: .default) {
                action in
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
    
}

//Mark: UITableViewDataSource
extension ConnectViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return ORPManager.sharedInstance.availableORPDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell", for: indexPath) as! RoundCell
        let orp = ORPManager.sharedInstance.availableORPDataArray[indexPath.row]
        cell.deviceNameLabel.text = orp.name + ": " + String(describing: orp.RSSI)
        cell.sideLabel.text = ""
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        return cell
    }
}

//MARK: - ORPManagerDelegate
extension ConnectViewController: ORPManagerDelegate{
    
    func orpheDidUpdateBLEState(state:CBCentralManagerState){
        PRINT("didUpdateBLEState")
        switch state {
        case .poweredOn:
            ORPManager.sharedInstance.startScan()
        default:
            break
        }
    }
    
    func orpheDidUpdateRSSI(orphe:ORPData){
        //        print("didUpdateRSSI", orphe.RSSI)
        if let index = ORPManager.sharedInstance.availableORPDataArray.index(of: orphe){
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? RoundCell{
                cell.deviceNameLabel.text = orphe.name + ": " + String(describing: orphe.RSSI)
            }
        }
    }
    
    func orpheDidDiscoverOrphe(orphe:ORPData){
        PRINT("didDiscoverOrphe")
        tableView.reloadData()
        updateCellsState()
    }
    
    func orpheDidDisappearOrphe(orphe:ORPData){
        PRINT("didDisappearOrphe")
        tableView.reloadData()
        updateCellsState()
    }
    
    func orpheDidFailToConnect(orphe:ORPData){
        PRINT("didFailToConnect")
        tableView.reloadData()
        updateCellsState()
        SVProgressHUD.dismiss()
    }
    
    func orpheDidDisconnect(orphe:ORPData){
        PRINT("didDisconnect")
        tableView.reloadData()
        updateCellsState()
    }
    
    func orpheDidConnect(orphe:ORPData){
        PRINT("didConnect")
        tableView.reloadData()
        updateCellsState()
        
        orphe.setScene(.sceneSDK)
        orphe.setGestureSensitivity(.high)
        SVProgressHUD.dismiss()
    }
    
    func orpheDidUpdateOrpheInfo(orphe:ORPData){
        PRINT("didUpdateOrpheInfo")
        updateCellsState()
    }
}
