//
//  Requester.swift
//  xc
//
//  Created by 谢国锐 on 18/4/14.
//  Copyright © 2018年 谢国锐. All rights reserved.
//

import UIKit
import Alamofire

class Requester{
    let httpURL = "http://47.106.88.219:8080"
    var viewcontrol : UIViewController?
    
    enum optcode {
        case startClean
        case stopClean
        case goBack
    }
    

    func Test(myurl: String="http://172.18.218.198:8421/FooService.Foo", data: Data){
        let MYURL = URL(string: myurl)
        var urlRequest = URLRequest(url: MYURL!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        urlRequest.setValue("application/protobuf", forHTTPHeaderField: "Accept")
        
        Alamofire.request(urlRequest).responseData(){
            response in
            let res = try! FooResponse.parseFrom(data: response.data!)
            print(res.text)
        }
        
    }
    
    func Control(op:optcode){
        let realURL = httpURL + "/control"
        var para : Parameters?
        
        switch op {
            
        case .startClean:
            para = ["optcode":"0"]
        case .stopClean:
            para = ["optcode":"1"]
        case .goBack:
            para = ["optcode":"2"]
        }
        
        let req = Alamofire.request(realURL, method: .get, parameters: para)
        print(req)
        req.responseData(){
            response in
            var resString = ""
            if response.data == nil || response.data?.count == 0 {
                resString = "Losing connection with Car?"
            }
            else{
               let res = try! ErrorCode.parseFrom(data: response.data!)
                if res.errorCode != 0{
                    resString = "Losing connection with Car?"
                }
                else{
                    resString = "Request is recieved by Car"
                }
                
            }
            let alterView = UIAlertController(title: "", message: resString, preferredStyle: .alert)
            let ac = UIAlertAction(title: "OK", style: .default, handler: nil)
            alterView.addAction(ac)
            self.viewcontrol?.present(alterView, animated: true, completion: nil)
            print("Data:",response.data ?? "no data")
//            print("debugDescription:",response.debugDescription)
            print("Result:",response.result )
        }
    }
    
    func Qury(ba:UILabel, clt:UILabel){
        
        let realURL = httpURL + "/query"
        
        let req = Alamofire.request(realURL, method: .get)
        print(req)
        req.responseData(){
            response in
            var resString = ""
            if response.data == nil || response.data?.count == 0 {
                resString = "Losing connection with Car?"
            }
            else{
                let res = try! Query.parseFrom(data: response.data!)
                    resString = "Request is recieved by Car"
                let cleanT = res.cleaningTime/60
                let batt = res.remainingCapacity
                
                DispatchQueue.main.async {
                    ba.text = String.init(format: "%d", batt!)
                    clt.text = String.init(format: "%d", cleanT)
                }
                
            }
            let alterView = UIAlertController(title: "", message: resString, preferredStyle: .alert)
            let ac = UIAlertAction(title: "OK", style: .default, handler: nil)
            alterView.addAction(ac)
            self.viewcontrol?.present(alterView, animated: true, completion: nil)
            print("Data:",response.data ?? "no data")
            //            print("debugDescription:",response.debugDescription)
            print("Result:",response.result )
        }
    }
    
}
