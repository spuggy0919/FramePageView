//
//  Settings.swift
//  VTxtRuby
//
//  Created by spuggy0919@gmail.com on 2021/12/5.
//

import Foundation
import UIKit

enum LayoutCheck {
    case colorChange     // no layout
    case pageChange      // no layout
    case fontChange      //  layout and lineSpace Kerning update
    case reLayout        //  layout
    case inputChange     //  layout with plain string
    case attrStringInput //  layout with attribute String
    case layoutDone
}
// dependent on FramePage View parameters
class FramePageSettings:ObservableObject{
    // View Transistion Control
    @Published var editing: Bool = true

    // FramePage Settings Control
    @Published var layoutFlag: LayoutCheck = .reLayout
    @Published var verticalform: Bool = true
    @Published var writingdirection: Int = 0 //0, 1,2,3
    @Published var fontSize: CGFloat = 20
    @Published var fontname: String = "Heiti TC"//
    
    @Published var lineSpacing: CGFloat = -6.0 //vertical 1/3 fontsze
    @Published var origin: CGPoint = CGPoint(x:5,y:5) //vertical 1/3 fontsze
    @Published var kerning: CGFloat = 0.0 //vertical 1/3 fontsze
    @Published var rubyonoff:Bool = false //one
    @Published var rubybaseline:CGFloat = 0.0
    @Published var colorIndex:Int = 4
    @Published var rubyfgcolor:UIColor =  UIColor(red: 240/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    @Published var fontcolor: UIColor =  UIColor(red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1)
    @Published var fontbkcolor: UIColor = UIColor.clear
    @Published var pagebrcolor: UIColor = UIColor(red: 252.0/255.0, green: 235.0/255.0, blue: 206/255.0, alpha: 1)
    @Published var expansion: Int = 0
    @Published var obliqueness: Int = 0
    @Published var inputString:String = ""
    @Published var nsAttrString:NSAttributedString = NSAttributedString(string: "")
 //   @Published var pageCnt:Int = 0
    @Published var pageCur:Int = 1
  //  @Published var isChange:Int = 0
    // delegate
    @Published var delegate:FramePageDelegate? = nil
    // debug Draw
    @Published var drawinset:CGFloat = 0
    @Published var topSafeArea:CGFloat = 0
    @Published var bottomSafeArea:CGFloat = 0
    @Published var debugDrawFrameFlag:Bool = false
    init(){}
    init(text:String, hv:Bool, fontsize:CGFloat, fontname:String, linespace:CGFloat, kerning:CGFloat, fcolor:UIColor, rbcolor:UIColor, pgColor:UIColor){
        layoutFlag = .inputChange
        inputString = text
        verticalform = hv
        fontSize = fontsize
        self.fontname = fontname
        lineSpacing = linespace
        self.kerning = kerning
        self.rubyfgcolor = rbcolor
        self.fontcolor = fcolor
        self.pagebrcolor = pgColor
    }
    func setColor(fg:UIColor, bk:UIColor, rb:UIColor){
        layoutFlag = .colorChange
        self.rubyfgcolor = rb
        self.fontcolor = fg
        self.pagebrcolor = bk
    }
    func setFontSize(fontsize:CGFloat){
        fontSize = fontsize

    }
    func setFontParameters(fontsize:CGFloat, fontname:String, linespace:CGFloat, kerning:CGFloat){
        fontSize = fontsize
        self.fontname = fontname
        lineSpacing = linespace
        self.kerning = kerning
    }
    func setInput(text:String, hv:Bool){
        layoutFlag = .inputChange
        inputString = text
        verticalform = hv
    }
    func setPageCur(pagecur:Int){
        layoutFlag = .pageChange
        pageCur = pagecur
    }
}
