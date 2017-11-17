//
//  ViewController.swift
//  skoal-example
//
//  Created by BANYAN on 2017/11/17.
//  Copyright © 2017年 skoal. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let permission: [String] = ["请求权限"]
    let setpCount: [String] = ["读取当天总步数","读取一定时间段内的步数","写入当天总步数","写入一定时间段的步数"]
    let height: [String] = ["读取身高","写入身高"]
    let bodyMass: [String] = ["读取体重","写入体重"]
    let bodyMassIndex: [String] = ["读取身体质量指数","写入身体质量指数"]
    let distanceWalkingRunning: [String] = ["读取步行加跑步距离","写入步行加跑步距离"]
    let flightsClimbed: [String] = ["读取当天以爬楼层","写入当天以爬楼层"]
    let respiratoryRate: [String] = ["读取呼吸速率","写入呼吸速率"]
    let dietaryEnergyConsumed: [String] = ["读取膳食能量消耗","写入膳食能量消耗"]
    let oxygenSaturation: [String] = ["血氧饱和度"]
    let bodyTemperature: [String] = ["读取体温","写入体温"]
    let bloodGlucose: [String] = ["读取血糖","写入血糖"]
    let bloodPressure: [String] = ["读取血压收缩压","写入血压收缩压","读取血压舒张压","写入血压舒张压"]
    let standHour: [String] = ["读取当天站立小时"]
    let biologicalSex: [String] = ["读取性别"]
    let dateOfBirth: [String] = ["读取出生日期"]
    let bloodType: [String] = ["读取血型"]
    let fitzpatrickSkin: [String] = ["日光反应型皮肤类型"]
    let sleepAnalysis: [String] = ["读取睡眠分析"]
    let menstrualFlow: [String] = ["读取最近一次月经"]
    let intermenstrualBleeding: [String] = ["读取点滴出血"]
    let sexualActivity: [String] = ["读取最近一次性行为"]
    
    var alertText: String = String()
    
    var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
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
        return 22
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 2
        case 5:
            return 2
        case 6:
            return 2
        case 7:
            return 2
        case 8:
            return 2
        case 9:
            return 1
        case 10:
            return 2
        case 11:
            return 2
        case 12:
            return 4
        case 13:
            return 1
        case 14:
            return 1
        case 15:
            return 1
        case 16:
            return 1
        case 17:
            return 1
        case 18:
            return 1
        case 19:
            return 1
        case 20:
            return 1
        case 21:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "获取权限"
        case 1:
            return "步数"
        case 2:
            return "身高"
        case 3:
            return "体重"
        case 4:
            return "身体质量指数"
        case 5:
            return "步行+跑步距离"
        case 6:
            return "以爬楼层"
        case 7:
            return "呼吸速率"
        case 8:
            return "膳食能量消耗"
        case 9:
            return "血氧饱和度"
        case 10:
            return "体温"
        case 11:
            return "血糖"
        case 12:
            return "血压"
        case 13:
            return "站立小时"
        case 14:
            return "性别"
        case 15:
            return "出生日期"
        case 16:
            return "血型"
        case 17:
            return "日光反应型皮肤类型"
        case 18:
            return "睡眠分析"
        case 19:
            return "月经"
        case 20:
            return "点滴出血"
        case 21:
            return "性行为"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel!.text = permission[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel!.text = setpCount[indexPath.row]
        } else if indexPath.section == 2 {
            cell.textLabel!.text =  height[indexPath.row]
        } else if indexPath.section == 3 {
            cell.textLabel!.text = bodyMass[indexPath.row]
        } else if indexPath.section == 4 {
            cell.textLabel!.text = bodyMassIndex[indexPath.row]
        } else if indexPath.section == 5 {
            cell.textLabel!.text = distanceWalkingRunning[indexPath.row]
        } else if indexPath.section == 6 {
            cell.textLabel!.text = flightsClimbed[indexPath.row]
        } else if indexPath.section == 7 {
            cell.textLabel!.text = respiratoryRate[indexPath.row]
        } else if indexPath.section == 8 {
            cell.textLabel!.text = dietaryEnergyConsumed[indexPath.row]
        } else if indexPath.section == 9 {
            cell.textLabel!.text = oxygenSaturation[indexPath.row]
        } else if indexPath.section == 10 {
            cell.textLabel!.text = bodyTemperature[indexPath.row]
        } else if indexPath.section == 11 {
            cell.textLabel!.text = bloodGlucose[indexPath.row]
        } else if indexPath.section == 12 {
            cell.textLabel!.text = bloodPressure[indexPath.row]
        } else if indexPath.section == 13 {
            cell.textLabel!.text = standHour[indexPath.row]
        } else if indexPath.section == 14 {
            cell.textLabel!.text = biologicalSex[indexPath.row]
        } else if indexPath.section == 15 {
            cell.textLabel!.text = dateOfBirth[indexPath.row]
        } else if indexPath.section == 16 {
            cell.textLabel!.text = bloodType[indexPath.row]
        } else if indexPath.section == 17 {
            cell.textLabel!.text = fitzpatrickSkin[indexPath.row]
        } else if indexPath.section == 18 {
            cell.textLabel!.text = sleepAnalysis[indexPath.row]
        } else if indexPath.section == 19 {
            cell.textLabel!.text = menstrualFlow[indexPath.row]
        } else if indexPath.section == 20 {
            cell.textLabel!.text = intermenstrualBleeding[indexPath.row]
        } else if indexPath.section == 21 {
            cell.textLabel!.text = sexualActivity[indexPath.row]
        }
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        cell.textLabel?.textColor = UIColor.lightGray
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:     // AccessPermission(获取权限)
            if indexPath.row == 0 {
                skoal.sharedInstance().requestHealthPermission { (response: HealthStorePermissionResponse) in
                    if response == HealthStorePermissionResponse.error {
                        print("请求失败")
                    } else {
                        print("请求成功")
                    }
                }
            }
        case 1:     // StepCount(步数)
            if indexPath.row == 0 {
                skoal.sharedInstance().readStepCountFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().readStepCountFromHealthStore(withStartTime: "2017-11-17 08:00", endTime: "2017-11-17 10:00", completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 2 {
                skoal.sharedInstance().writeStepCountToHealthStore(withUnit: 888, completion: { (_ response: Bool) in
                    print(response)
                })
            } else if indexPath.row == 3 {
                skoal.sharedInstance().writeStepCountToHealthStore(withUnit: 888, startTime: "2017-11-17 11:00", endTime: "2017-11-17 12:00", completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 2:     // Height(身高)
            if indexPath.row == 0 {
                skoal.sharedInstance().readHeightFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeHeightToHealthStore(withUnit: 1.80, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 3:     // BodyMass(体重)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBodyMassFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeBodyMassToHealthStore(withUnit: 70, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 4:     // BodyMassIndex(身体质量指数)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBodyMassIndexFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeBodyMassIndexToHealthStore(withUnit: 22, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 5:     // DistanceWalkingRunning(步行+跑步距离)
            if indexPath.row == 0 {
                skoal.sharedInstance().readDistanceWalkingRunningFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeDistanceWalkingRunningToHealthStore(withUnit: 20.0, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 6:     //FlightsClimbed(以爬楼层)
            if indexPath.row == 0 {
                skoal.sharedInstance().readFlightsClimbedFromHealthStore(completion: { (_ flightsClimbed: NSInteger, _ error: Error?) in
                    print("\(flightsClimbed)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeFlightsClimbedToHealthStore(withUnit: 23, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 7:     // RespiratoryRate(呼吸速率)
            if indexPath.row == 0 {
                skoal.sharedInstance().readRespiratoryRateFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeRespiratoryRateToHealthStore(withUnit: 20.0, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 8:     // DietaryEnergyConsumed(膳食能量消耗)
            if indexPath.row == 0 {
                skoal.sharedInstance().readDietaryEnergyConsumedFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeDietaryEnergyConsumedToHealthStore(withUnit: 22.2, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 9:     // OxygenSaturation(血氧饱和度)
            if indexPath.row == 0 {
                skoal.sharedInstance().readOxygenSaturationFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            }
        case 10:    // BodyTemperature(体温)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBodyTemperatureFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeBodyTemperatureToHealthStore(withUnit: 35.0, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 11:    // BloodGlucose(血糖)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBloodGlucoseFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeBloodGlucoseToHealthStore(withUnit: 16.0, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 12:    // BloodPressure(血压)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBloodPressureSystolicFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 1 {
                skoal.sharedInstance().writeBloodPressureSystolicToHealthStore(withUnit: 65.0, completion: { (_ response: Bool) in
                    print(response)
                })
            } else if indexPath.row == 2 {
                skoal.sharedInstance().readBloodPressureDiastolicFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            } else if indexPath.row == 3 {
                skoal.sharedInstance().writeBloodPressureDiastolicToHealthStore(withUnit: 77.0, completion: { (_ response: Bool) in
                    print(response)
                })
            }
        case 13:    // StandHour(站立小时)
            if indexPath.row == 0 {
                skoal.sharedInstance().readStandHourFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            }
        case 14:    // BiologicalSex(性别)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBiologicalSexFromHealthStore(completion: { (_ biologicalSex: String!, _ error: Error?) in
                    print("\(biologicalSex)\n\(error.debugDescription)")
                })
            }
        case 15:    // DateOfBirth(出生日期)
            if indexPath.row == 0 {
                skoal.sharedInstance().readDateOfBirthFromHealthStore(completion: { (_ date: Date!, _ error: Error?) in
                    print("\(date)\n\(error.debugDescription)")
                })
            }
        case 16:    // BloodType(血型)
            if indexPath.row == 0 {
                skoal.sharedInstance().readBloodTypeFromHealthStore(completion: { (_ bloodType: String!, _ error: Error?) in
                    print("\(bloodType)\n\(error.debugDescription)")
                })
            }
        case 17:    // FitzpatrickSkin(日光反应型皮肤类型)
            if indexPath.row == 0 {
                skoal.sharedInstance().readFitzpatrickSkinFromHealthStore(completion: { (_ skinType: String!, _ error: Error?) in
                    print("\(skinType)\n\(error.debugDescription)")
                })
            }
        case 18:    // SleepAnalysis(睡眠分析)
            if indexPath.row == 0 {
                skoal.sharedInstance().readSleepAnalysisFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            }
        case 19:    // MenstrualFlow(月经)
            if indexPath.row == 0 {
                skoal.sharedInstance().readMenstrualFlowFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            }
        case 20:    // IntermenstrualBleeding(点滴出血)
            if indexPath.row == 0 {
                skoal.sharedInstance().readIntermenstrualBleedingFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            }
        case 21:    // SexualActivity(性行为)
            if indexPath.row == 0 {
                skoal.sharedInstance().readSexualActivityFromHealthStore(completion: { (_ value: Double, _ error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                })
            }
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

