//
//  MyButton.swift
//  xc
//
//  Created by 谢国锐 on 18/4/11.
//  Copyright © 2018年 谢国锐. All rights reserved.
//
//https://www.jianshu.com/p/d23a8234729c
import UIKit

class MyButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.*/
    override func draw(_ rect: CGRect) {
        // Drawing code
        // button标题的偏移量 上（＋下－上）、左（＋右－左）、下（－下）、右（－右）
        self.titleEdgeInsets = UIEdgeInsetsMake((self.imageView?.frame.size.height)!+5, -(self.imageView?.bounds.size.width)!, 0,0);
        // button图片的偏移量
        self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel!.frame.size.width/2, (self.titleLabel?.frame.size.height)!+5, -(self.titleLabel?.frame.size.width)!/2);
        
    }
 

}
