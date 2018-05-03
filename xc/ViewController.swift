//
//  ViewController.swift
//  xc
//
//  Created by 谢国锐 on 18/3/17.
//  Copyright © 2018年 谢国锐. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UIScrollViewDelegate{
    //MARK: properties
    @IBOutlet weak var Scroll: UIScrollView!
    @IBOutlet weak var Share: UIButton!
    
    @IBOutlet weak var Battery: UILabel!
    
    @IBOutlet weak var CleanTime: UILabel!
    
    var showImg = UIImageView()
    let mapdealer = MapDealer()
    var requester = Requester()
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    func ChangeButtonPic(but: UIButton, name: String){
        var img = UIImage(named: name)
        UIGraphicsBeginImageContext(but.frame.size)
        let point = CGPoint(x: 0.0, y: 0.0)
        img?.draw(in: CGRect(origin: point, size: but.frame.size))
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if !name.contains("Blue"){
            usleep(125000)
        }
        but.setImage(img, for: .normal)
        
    }
    //MARK: action
    @IBAction func Share(_ sender: UIButton) {
        ChangeButtonPic(but: sender, name: "flushBlue")
        self.Share.isEnabled = false
        Scroll.bringSubview(toFront: indicator)
        indicator.startAnimating()
        
        /*DispatchQueue.global().async {
            let tmp = Potrace.Settings()
            let tmpImg = self.mapdealer.updateImage(settings: tmp)
            //Keep in mind：UI必须在主队列更新！
            DispatchQueue.main.async {
                self.showImg.removeFromSuperview()
                self.showImg = UIImageView(image: tmpImg)
                self.showImg.backgroundColor = UIColor.gray
                self.Scroll.contentSize = CGSize(width: self.showImg.frame.width, height: self.showImg.frame.height)
                
                self.Scroll.addSubview(self.showImg)
                self.scrollViewDidZoom(self.Scroll)
                //print("end")
                self.ChangeButtonPic(but: self.Share, name: "flush")
                self.indicator.stopAnimating()
                self.Share.isEnabled = true
            }
        }*/
        RequireMap()
//        requester.Position(content: self.showImg.image!)
    }
    
    @IBAction func StartClean(_ sender: UIButton) {
        ChangeButtonPic(but: sender, name: "cleanBlue")
        sender.isEnabled = false
        //DispatchQueue.global().async {
            self.requester.Control(op: Requester.optcode.startClean)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.ChangeButtonPic(but: sender, name: "clean")
            }
        //}
    }
    
    @IBAction func StopClean(_ sender: UIButton) {
        ChangeButtonPic(but: sender, name: "stopBlue")
        sender.isEnabled = false
        //DispatchQueue.global().async {
            self.requester.Control(op: Requester.optcode.stopClean)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.ChangeButtonPic(but: sender, name: "stop")
            }
        //}
    }
    
    @IBAction func GoBack(_ sender: UIButton){
        ChangeButtonPic(but: sender, name: "gobackBlue")
        sender.isEnabled = false
        //DispatchQueue.global().async {
            self.requester.Control(op: Requester.optcode.goBack)
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.ChangeButtonPic(but: sender, name: "goback")
            }
        //}
    }
    var code = 0
    //here use button--more
    @IBAction func test(_ sender: UIButton) {
        requester.Qury(ba: Battery, clt: CleanTime)
//        ChangeButtonPic(but: sender, name: "moreBlue")
//        sender.isEnabled = false
////        DispatchQueue.global().async {
//            let foo = FooRequest.Builder()
//            self.code += 1
//            foo.code = Int32(self.code % 3)
//            self.requester.Test(data: try!foo.build().data())
//        
//        
//            DispatchQueue.main.async {
//                sender.isEnabled = true
//                self.ChangeButtonPic(but: sender, name: "more")
//            }
////        }
    }
    
    func RequireMap(){
        let realURL = requester.httpURL + "/mymap"
        var image = UIImage()
        Alamofire.request(realURL).responseData(){
            response in
            if (response.data?.count)! > 0{
                let map = try! Map.parseFrom(data: response.data!)
                print("MAP",map)
                //how to get a image?
                //here!!
                let tmp = Potrace.Settings()
                image = self.mapdealer.updateImage(settings: tmp, map:map)
                
                let realURL = self.requester.httpURL + "/pose"
                let req = Alamofire.request(realURL, method: .get)
                req.responseData(){
                    response in
                    
                    if response.data == nil || response.data?.count == 0 {
                        return
                    }
                    else{
                        let res = try! Pose.parseFrom(data: response.data!)
                        print("POSE",res.x, res.y)
                        UIGraphicsBeginImageContext(image.size)
                        image.draw(in: CGRect(x:0,y:0,width:image.size.width, height:image.size.height))
                        let context = UIGraphicsGetCurrentContext()!
                        context.saveGState()
                        context.setFillColor(UIColor.red.cgColor)
                        context.fill(CGRect(x: Int(res.x), y: Int(res.y), width: 3, height: 3))
                        
                        image = UIGraphicsGetImageFromCurrentImageContext()!
                        context.restoreGState()
                        UIGraphicsEndImageContext()
                        
                        DispatchQueue.main.async {
                            self.showImg.removeFromSuperview()
                            self.showImg = UIImageView(image: image)
                            self.showImg.backgroundColor = UIColor.gray
                            self.Scroll.contentSize = CGSize(width: self.showImg.frame.width, height: self.showImg.frame.height)
                            
                            self.Scroll.addSubview(self.showImg)
                            self.scrollViewDidZoom(self.Scroll)
                            //print("end")
                        }
                        
                    }
                }
                
                
            }
            else{
                DispatchQueue.main.async {
                    let alterView = UIAlertController(title: "Error", message: "Losing connection with Car?", preferredStyle: .alert)
                    let ac = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alterView.addAction(ac)
                    self.present(alterView, animated: true, completion: nil)
                }
            }
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.ChangeButtonPic(but: self.Share, name: "flush")
                self.Share.isEnabled = true
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.color = UIColor.white
        self.view.addSubview(indicator)
        indicator.hidesWhenStopped = true
        
        Scroll.delegate = self
        Scroll.zoomScale = 0.8
        requester.viewcontrol = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !Share.isEnabled{
            return nil
        }
        return showImg
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (Scroll.bounds.size.width > Scroll.contentSize.width) ? (Scroll.bounds.size.width - Scroll.contentSize.width)*0.5 : 0.0
        
        let offsetY = (Scroll.bounds.size.height > Scroll.contentSize.height) ?
            (Scroll.bounds.size.height - Scroll.contentSize.height) * 0.5 : 0.0;
        showImg.center = CGPoint(x:Scroll.contentSize.width * 0.5 + offsetX, y:Scroll.contentSize.height * 0.5 + offsetY);
    }

    //ONLY after autolayout, we can get the REAL size
    override func viewDidLayoutSubviews() {
//        indicator.center = Scroll.convert(Scroll.center, from: Scroll.superview)
        indicator.center = Scroll.center
    }
    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

