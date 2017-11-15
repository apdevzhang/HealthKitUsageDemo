//
//  ViewController.swift
//  skoal-example
//
//  Created by BANYAN on 2017/11/12.
//  Copyright © 2017年 skoal. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let titleArray: [String] = ["2","3","4","写入步数","写入身高"]
    
    var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        requestPermission()
        
        initUI()
    }
    

    ///-------------------------
    /// Objective-C请求权限示例
    ///-------------------------
//        [[skoal sharedInstance]requestHealthPermissionWithBlock:^(HealthStorePermissionResponse permissionResponse) {
//            if (permissionResponse == HealthStorePermissionResponseError) {
//                DLog(@"请求权限失败");
//            }else{
//                DLog(@"请求权限成功");
//            }
//        }];
    
    //MARK:请求健康权限
    func requestPermission() {
        skoal.sharedInstance().requestHealthPermission { (response: HealthStorePermissionResponse) in
            if response == HealthStorePermissionResponse.error {
                print("请求失败")
            } else {
                print("请求成功")
            }
        }        
    }
            
    //MARK:UI
    func initUI() {
        _tableView = UITableView.init(frame:CGRect.init(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height),style:UITableViewStyle.plain)
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.showsVerticalScrollIndicator = false
        _tableView.tableFooterView = UIView.init()
        self.view.addSubview(_tableView)
        _tableView.register(UITableViewCell().classForCoder, forCellReuseIdentifier: "cellId")
    }
    
    //MARK:UITbleviewDelegate,UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        cell.textLabel?.textColor = UIColor.lightGray
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
//            var alert = UIAlertView(title: "2", message: "v", delegate: self, cancelButtonTitle: "y")
//            alert.alertViewStyle = UIAlertViewStyle.default
//            alert.show()
            
            skoal.sharedInstance().readFlightsClimbedFromHealthStore(completion: { (_ value: NSInteger, error: Error?) in
                print(value)
            })
            
            print("")
            
//            skoal.sharedInstance().writeBodyMassIndexToHealthStore(withBodyMassIndex: 12.3, completion: { (_ response: Bool) in
//                print(response)
//            })
            
            //读取步行&跑步距离
//            skoal.sharedInstance().readDistanceWalkingRunningFromHealthStore(completion: { (_ value: Double, error: Error?) in
//                print(value)
//            })
            
//            skoal.sharedInstance().readBodyMassFromHealthStore(completion: { (_ value: Double, error: Error?) in
//                print(value)
//            })
            
//            skoal.sharedInstance().readStepCountFromHealthStore(completion: { (_ response: Double, _ error: Error?) in
//                print(response)
//            })
            
        case 1:            
//            skoal.sharedInstance().readStepCountFromHealthStore(withStartDateString: "2017-11-15 08:00", endDateString: "2017-11-15 09:00", completion: { (_ response: Double, _ error: Error?) in
//                print(response)
//            })
            
//            skoal.sharedInstance().writeBodyMassToHealthStore(withBodyMass: 180, completion: { (_ response: Bool) in
//                print(response)
//            })
            
//            skoal.sharedInstance().writeBodyMassToHealthStore(withBodyMass: 180, completion: { (_ response: Bool) in
//                print(response)
//            })
            
            ////写入读取步行&跑步距离
//            skoal.sharedInstance().writeDistanceWalkingRunningToHealthStore(withBodyMassIndex: 23.4, completion: { (_ response: Bool) in
//                print(response)
//            })
            
            print("")
        case 2:
            
//            skoal.sharedInstance().readHeightFromHealthStore(completion: { (_ response: Double, _ error: Error?) in
//                print(response)
//                print(String(error.debugDescription))
//            })
            
            print("")
        case 3:
            
//            skoal.sharedInstance().writeStepCountToHealthStore(withStepCount: 200.0, completion: { (_ response: Bool) -> Void in
//                print(response)
//            })
            
//            skoal.sharedInstance().writeStepCountToHealthStore(withStepCount: 9999.0, startTime: "2017-11-14 08:00", endTime: "2017-11-14 09:00", completion: { (_ response: Bool) in
//                print(response)
//            })
            
            print("")
        case 4:
            skoal.sharedInstance().writeHeightToHealthStore(withHeight: 1.3, completion: { (_ response: Bool) in
                print(response)
            })
            print("")
        case 5:
            print("")
        case 6:
            print("")
        case 7:
            print("")
        default:
            print("")
        }
        _tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

