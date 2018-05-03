//
//  InstructSatement.swift
//  xc
//
//  Created by 谢国锐 on 18/4/13.
//  Copyright © 2018年 谢国锐. All rights reserved.
//

import Foundation

//use URLSession to connect
/*    let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)

    let session = URLSession.shared

    let dataTask = session.dataTask(with: url!) { (data, respond, error) in
        
        if let data = data {
            
            if let result = String(data:data,encoding:.utf8){
                
                success(result)
            }
        }else {
            
            failure(error!)
        }
    }
    dataTask.resume()*/

//闭包
//闭包：｛（para）-> retType in
//        statements
//      ｝
//trailing 闭包：函数括号外，当作最后一个参数


//NSURLConnection to connect
//one type is sendSynchronousRequest 同步
//another is sendAsynchronousRequest 异步，不会停止UI响应

/*        let url = URL(string: "http://api.tianapi.com/wxnew/?key=ad6ffb8749443d691587c4b54d3f2c7a&num=1")

        //用 setvalue 设置 http 参数好像不行
        let request = URLRequest(url: url!)

        let data = try? NSURLConnection.sendSynchronousRequest(request, returning: nil)*/


//use protobuf
/*        let mapcell = MapCell.Builder()
        mapcell.x = 32768;
        mapcell.y = 4;
        mapcell.value = try!MapCell.Value.fromString("FREE")
        print(mapcell)
        //序列化
        let mapcellEncode = try! mapcell.build().data()
        print(mapcellEncode)

        //反序列化
        let mapcellDecode = try! MapCell.parseFrom(data: mapcellEncode)
        print(mapcellDecode)*/


//use Alamofire
/*let parameters: Parameters = ["foo": "bar"]
 Alamofire.request("https://httpbin.org/get", parameters: parameters) // encoding 默认是`URLEncoding.default`
// https://httpbin.org/get?foo=bar
 
 Alamofire.request("https://httpbin.org/get").responseData { response in
 debugPrint("All Response Info: \(response)")
 
 if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
 print("Data: \(utf8Text)")
 }
 }
*/
