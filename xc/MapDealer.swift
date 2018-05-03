//
//  MapDealer.swift
//  xc
//
//  Created by 谢国锐 on 18/4/13.
//  Copyright © 2018年 谢国锐. All rights reserved.
//

import UIKit

class MapDealer{
    let whiciPhotoName = ["map.pgm", "tb_condo_2.pgm","test_map.pgm", "willow-full.pgm", "willow-2010-02-18-0.10.pgm"]
    var potrace: Potrace!
    var imagePixels : [UInt8] = []
    var rawPixels : [UInt8] = []
    var height = 0
    var width = 0
    
    
    // Read .pgm return  wide    height    data
    func DealPGM2(name:String = "test_map.pgm") -> (wide:Int, height:Int,data:[UInt8]) {
        
        //        var home : String = NSHomeDirectory()
        //        print(home)
        //        home += "/Documents/pgm/\(name)"
        let home = Bundle.main.url(forResource: "\(name)", withExtension: nil)
        let readHandler = try! FileHandle(forReadingFrom:home!)
        let tmpData = readHandler.readDataToEndOfFile()
        
        //P5?
        var index = 0
        let ch0   : UInt8 = tmpData[index]
        
        index += 1
        let ch1   : UInt8 = tmpData[index]   // 1
        
        if ch0 != UInt8(("P".unicodeScalars.first?.value)!){
            print("Not a Pgm")
        }
        
        if ch1 != UInt8(("2".unicodeScalars.first?.value)!)
            && ch1 != UInt8(("5".unicodeScalars.first?.value)!){
            print("Not a Pgm")
        }
        
        index += 1
        
        index += 1   // read \n  3
        var ch   : UInt8 = tmpData[index]
        
        if ch == UInt8(("#".unicodeScalars.first?.value)!) {
            repeat{
                index += 1
                ch = tmpData[index]
            }while ch != UInt8(("\n".unicodeScalars.first?.value)!)
            
            index += 1
            ch = tmpData[index]
        }
        
        if ch < UInt8(("0".unicodeScalars.first?.value)!)
            || ch > UInt8(("9".unicodeScalars.first?.value)!) {
            print("wide Error")
        }
        
        var k : uint = 0
        repeat{
            k = k * 10 + uint(ch) - uint(("0".unicodeScalars.first?.value)!)
            index += 1
            ch = tmpData[index]
        }while ch >= UInt8(("0".unicodeScalars.first?.value)!)
            && ch <= UInt8(("9".unicodeScalars.first?.value)!)
        
        let wide = k
        
        index += 1
        ch = tmpData[index]
        if ch < UInt8(("0".unicodeScalars.first?.value)!)
            || ch > UInt8(("9".unicodeScalars.first?.value)!) {
            print("height Error")
        }
        
        k = 0
        repeat{
            k = k * 10 + uint(ch) - uint(("0".unicodeScalars.first?.value)!)
            index += 1
            ch = tmpData[index]
        }while ch >= UInt8(("0".unicodeScalars.first?.value)!)
            && ch <= UInt8(("9".unicodeScalars.first?.value)!)
        let height = k
        
        index += 1
        ch = tmpData[index]
        if ch < UInt8(("0".unicodeScalars.first?.value)!)
            || ch > UInt8(("9".unicodeScalars.first?.value)!) {
            print("max pix Error")
        }
        k = 0
        repeat{
            index += 1
            ch = tmpData[index]
            k = k * 10 + uint(ch) - uint(("0".unicodeScalars.first?.value)!)
        }while ch >= UInt8(("0".unicodeScalars.first?.value)!)
            && ch <= UInt8(("9".unicodeScalars.first?.value)!)
        _ = k
        
        let matrix : [UInt8] = Array(tmpData[index+1...(tmpData.count - 1)])
        
        print("width=",wide," high=", height)
        return (Int(wide), Int(height), matrix)
        
    }
    
    func pixelData(){
        let result = DealPGM2()
        height = result.height
        width = result.wide
        rawPixels = result.data
        
//        var pixelData = [UInt8](repeating: 0, count: result.wide*result.height*4)
//        
//        for i in 0..<result.height*result.wide{
//            pixelData[4*i] = result.data[i]
//            pixelData[4*i+1] = result.data[i]
//            pixelData[4*i+2] = result.data[i]
//            pixelData[4*i+3] = 0
//        }
//        
//        imagePixels = pixelData
        //        return result.arr
        imagePixels = result.data
    }
    
    
    func updateImage(settings: Potrace.Settings, map:Map? = nil) -> UIImage {
        /////////
        if map == nil {
            pixelData()
        }
        else{
            let mapCells = (map?.mapCell)!
            self.width = Int((map?.width)!)
            self.height = Int((map?.height)!)
            imagePixels = [UInt8](repeating: 125, count: width*height)
            
            for x in mapCells{
                print(x.x, x.y, x.value)
                imagePixels[Int(UInt32(width)*x.x+x.y)] = x.value == MapCell.Value.free ? 255 : 0
            }
            
            rawPixels = [UInt8](imagePixels)
            
        }
        
        let startTime = CACurrentMediaTime()
        
        self.potrace = Potrace(data: UnsafeMutableRawPointer(mutating: self.imagePixels),
                               width: self.width,
                               height: self.height)
        
        self.potrace.process(settings: settings)
        //贝赛尔放大，则newImage的size也要放大，不然显示不全
        let bezier = potrace.getBezierPath(scale: 1.0)
        
        //原来是队列DispatchQueue.main.async？？
        let newImage = self.imageFromBezierPath(path: bezier, size: CGSize.init(width: self.width, height: self.height))
        
        //Origin pic may be big
        UIGraphicsBeginImageContext(CGSize( width:Double(self.width)*0.8, height: Double(self.height)*0.8))
        newImage.draw(in: CGRect(x: 0.0, y: 0.0, width: Double(self.width)*0.8, height: Double(self.height)*0.8))
        let ResImg = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        ///////
        let endTime = CACurrentMediaTime()
        print("All: ",endTime - startTime)
        return ResImg
    }
    
    func imageFromBezierPath(path: UIBezierPath, size: CGSize) -> UIImage {
        var image = UIImage()
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.setFillColor(UIColor.lightGray.cgColor)
            //            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            //            context.fill(rect)
            //
            //            path.stroke()
            
            for i in 0..<self.height{
                for j in 0..<self.width{
                    if self.rawPixels[j+i*self.width] >= 250{
                        context.fill(CGRect(x: j, y: i, width: 1, height: 1))
                    }
                }
            }
            
            context.setFillColor(UIColor.black.cgColor)
            path.fill()
            image = UIGraphicsGetImageFromCurrentImageContext()!
            context.restoreGState()
            UIGraphicsEndImageContext()
        }
        return image
    }
}
