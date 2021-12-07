//
//  MarkDownSimple.swift
//  VTxtRuby
//
//  Created by Lin Hess on 2021/12/6.
//
// Most of Markdown functions are not implemented , this purpose is only for to convert Heading Tag and ruby to NSAttributedString
import Foundation
import UIKit
import CoreText
import SwiftUI

enum MarkdownTag{
    case heading1 // # Heading1
    case heading2 // ## Heading2
    case heading3 // ### Heading3
    case heading4 // #### Heading4
    case heading5 // ##### Heading5
    case heading6 // ###### Heading6
    case linebreak // content  \n (trailing two more blank}
    case bold     // **Bold**
    case italics  // *italics*
    case bolditalics  // *italics*
    case ruby     // <ruby></ruby>
    case rubySub  //  <rb>
    case paragraphs // <p>
    case image // ![Tux, the Linux mascot](/assets/images/tux.png)
    case horizontalRule //
    // Block
    case codeBlock    // code block
    case listtag  // 1.aldkfa;k
    case tableBlock    // ![][]
    case quoteBlock
    case linktag

}
typealias  TagFuncTemplate  =  (MarkdownElement, TagItem,NSTextCheckingResult)->NSAttributedString
struct TagItem {
    var tag:MarkdownTag
    var description:String
    var pattern:String
    var tagfunc:TagFuncTemplate
    var argc:Int
    var argv:[Any]
    
    init (_ tag:MarkdownTag,_ desc:String,_ pat:String, _ tagf:@escaping TagFuncTemplate, _ argc:Int, _ argv:[Any]) {
        self.tag = tag
        description = desc
        pattern = pat
        tagfunc = tagf
        self.argc = argc
        self.argv = argv
    }
}
//var tagBlokcTable: [TagItem] = [  // List Table Code Block Paragraph
//    TagItem(.listtag,"^.*^\n","^[.|[0-9]",
//            MarkdownElement.tagffoo,1,["<br>"]),
//    TagItem(.codeBlock,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
//            MarkdownElement.tagffoo,1,["<br>"]),
//    TagItem(.tableBlock,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
//            MarkdownElement.tagffoo,1,["<br>"]),
//    TagItem(.paragraphs,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
//            MarkdownElement.tagffoo,1,["<br>"]),
//    TagItem(.quoteBlock,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
//            MarkdownElement.tagffoo,1,["<br>"]),
//]
var tagTable: [TagItem] = [ //^[A-Za-z].*(?:\n[A-Za-z].*)*
    TagItem(.listtag,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
            MarkdownElement.tagffoo,1,["<br>"]),
    TagItem(.linktag,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
            MarkdownElement.tagffoo,1,["<br>"]),
    TagItem(.codeBlock,"^.*^\n","^((?:(?:[ ]{4}|\\t).*(\\R|$))+)",
            MarkdownElement.tagffoo,1,["<br>"]),
    TagItem(.horizontalRule,"^.*^\n","(^[*| |-]+\\n)|(^-$\n)",
            MarkdownElement.tagfLineBreak,1,["<br>"]),
    TagItem(.linebreak,"^.*^\n","(\\)",
            MarkdownElement.tagfLineBreak,1,["<br>"]),
    TagItem(.linebreak,"\\","(\\)",
            MarkdownElement.tagfLineBreak,1,["<br>"]),
    TagItem(.linebreak,"\\s\\s\\n","(\\s\\s\\n)|(\\)",
            MarkdownElement.tagfLineBreak,1,["<br>"]),
    TagItem(.ruby,"<ruby></ruby>","<ruby>((.|\\n)*?)<\\/ruby>",
            MarkdownElement.tagfRuby,2,[0]),
    TagItem(.bolditalics,"***BoldItalic***","[\\*|_]{3}(.+?)[\\*|_]{3}",
            MarkdownElement.tagfBoldItalic,2,[36.0,2]),
    TagItem(.bold,"**Bold**","[\\*|_]{2}(.+?)[\\*|_]{2}",
            MarkdownElement.tagfBoldItalic,2,[36.0,0]),
    TagItem(.bold,"*Italic*","[\\*|_]{1}(.+?)[\\*|_]{1}",
            MarkdownElement.tagfBoldItalic,2,[36.0,1]),
    TagItem(.heading6,"###### This is an H6\n","(#{6}) (.+)[  #]*",
            MarkdownElement.tagfHeading,1,[5,"<h6>","</h6>\n"]), // fontSize, group 2+\n
    TagItem(.heading5,"##### This is an H5\n","(#{5}) (.+)[  #]*",
            MarkdownElement.tagfHeading,1,[4,"<h5>","</h5>\n"]),
    TagItem(.heading4,"#### This is an H4\n","(#{4}) (.+)[  #]*",
            MarkdownElement.tagfHeading,1,[3,"<h4>","</h4>\n"]),
    TagItem(.heading3,"### This is an H3\n","(#{3}) (.+)[ #]*",
            MarkdownElement.tagfHeading,1,[2,"<h3>","</h3>\n"]),
    TagItem(.heading2,"## This is an H2\n","(#{2}) (.+)[ #]*",
            MarkdownElement.tagfHeading,1,[1,"<h2>","</h2>\n"]),
    TagItem(.heading1,"# This is an H1\n","(#{1}) (.+)[ #]*",
            MarkdownElement.tagfHeading,1,[0,"<h1>","</h1>\n"]),
   
    // not support
  //  TagItem(.paragraphs,"This \n\n thksdhf","^[A-Za-z].*(?:\\n[A-Za-z].*)*",tagffoo,2,[0]),
]
// Simple MarkDown Parser to NSAttribute String

class MarkdownElement{
    var inputStr:String
    var atStr:NSMutableAttributedString = NSMutableAttributedString(string:"")
    var settings: FramePageSettings = FramePageSettings()
    var headingFont =  [
        UIFont.preferredFont(forTextStyle: .largeTitle),
        UIFont.preferredFont(forTextStyle: .title1),
        UIFont.preferredFont(forTextStyle: .title2),
        UIFont.preferredFont(forTextStyle: .title3),
        UIFont.preferredFont(forTextStyle: .headline),
        UIFont.preferredFont(forTextStyle: .subheadline),
        UIFont.preferredFont(forTextStyle: .subheadline),
    ]
    init(_ text:String){
        inputStr = text
        MDparser(text:text,settings)
    }
    init(_ text:String,settings: FramePageSettings){
        inputStr = text
        self.settings = settings
        MDparser(text:text,settings)
    }
    func setCustomSettings() {
        let fsize = settings.fontSize
        headingFont[0] = UIFont.systemFont(ofSize: fsize/28.0 * 41.0)
        headingFont[1] = UIFont.systemFont(ofSize: fsize/28.0 * 34.0)
        headingFont[2] = UIFont.systemFont(ofSize: fsize/28.0 * 28.0)
        headingFont[3] = UIFont.systemFont(ofSize: fsize/28.0 * 25.0)
        headingFont[4] = UIFont.systemFont(ofSize: fsize/28.0 * 22.0)
        headingFont[5] = UIFont.systemFont(ofSize: fsize/28.0 * 20.0)
        // content
        headingFont[6] = UIFont(name:settings.fontname, size: fsize/28.0 * 17.0)!
    }
    func MDparser(text:String , _ settings:FramePageSettings)  {
        self.settings = settings
        setCustomSettings()
        atStr = NSMutableAttributedString(string: text)
        // define addParagraphStyle
        for idx in 0..<tagTable.count {
            do {
                let regex = try NSRegularExpression(pattern: tagTable[idx].pattern, options: NSRegularExpression.Options.caseInsensitive)
                let matches = regex.matches(in: inputStr, options: [], range: NSRange(location: 0, length: inputStr.utf16.count)).reversed()
                // match tokens process
                for m in matches {
                    // what will be the code
                    let range0 = m.range(at:0)
//                    let range1 = m.range(at:1)
//                    let range2 = m.range(at:2)
//                    print("\(range0),\(range1),\(range2)")
                    if Range(range0, in: inputStr) != nil {
                        print("match is \(range0) \(m)")
                        _ = tagTable[idx].tagfunc(self,tagTable[idx],m) // add atrribute to attrStr
                    }
                } // for m
            } catch {
                print("\(idx):\(tagTable[idx].pattern)Error")
            }
            inputStr = atStr.string // sync string and AttributeString
        } // for idx
      //  atStr = addParagraphStyle(attributedString: atStr, settings: settings)
    } // parse
    
    /// define tagfffunc to add attribute to string
    // temple function
    static func tagffoo(_ mdobj:MarkdownElement,_ tagItem:TagItem,_ match:NSTextCheckingResult)->NSAttributedString{
        let att = NSAttributedString(string: "")
        return att
    }
    
    static func tagfHeading(_ mdobj:MarkdownElement,_ tagItem:TagItem,_ match:NSTextCheckingResult)->NSAttributedString{
        let attstr = mdobj.atStr
        let text = attstr.string
        let settings = mdobj.settings
// (#{6}) (.+?)[ #]*\n range0 is whole match, range1 is ### range2 is Heading...
//        let range0 = Range(match.range(at: 0), in: text).map({ String(text[$0]) })
//        let range1 = Range(match.range(at: 1), in: text).map({ String(text[$0]) })
        if Range(match.range(at: 2), in: text).map({ String(text[$0]) }) != nil{
           // inStr = inStr()
            let range = match.range(at: 2)
          //  let nsRange  = NSMakeRange(range.location, range.length)
            let aStr = NSAttributedString(attributedString: attstr)
            let subAttStr = aStr.attributedSubstring(from: range)
            let headAttStr = NSMutableAttributedString(attributedString: subAttStr)
            let font = mdobj.headingFont[tagItem.argv[0] as! Int]
            
            headAttStr.chnageFontSize(font:font, size:font.pointSize, color: settings.fontcolor)
             
            let patstr = mdobj.addParagraphStyle(attributedString: headAttStr,settings: settings)

        attstr.replaceCharacters(in: match.range(at: 0), with: patstr)
        }
        mdobj.atStr = attstr
        return attstr
    }
    static func tagfBoldItalic(_ mdobj:MarkdownElement,_ tagItem:TagItem,_ match:NSTextCheckingResult)->NSAttributedString{
        let attstr = mdobj.atStr
        let text = attstr.string
/// **(.+?)**  range 0  is whole match,
///         range1 is  Bold String
        if Range(match.range(at: 1), in: text).map({ String(text[$0]) }) != nil{
            let range = match.range(at: 1)
         //   let nsRange  = NSMakeRange(range.location, range.length)
            // get SubString to be modified attribute
            let aStr = NSAttributedString(attributedString: attstr)
            let subAttStr = aStr.attributedSubstring(from: range)
            let headAttStr = NSMutableAttributedString(attributedString: subAttStr)

            let uifont = UIFont.systemFont(ofSize: mdobj.headingFont[6].pointSize)
            headAttStr.addAttributes([
                .font: (tagItem.tag == .bold) ? uifont.bold(): (tagItem.tag == .italics) ? uifont.italics():  uifont.boldItalics()
                ])
            attstr.replaceCharacters(in: match.range(at: 0), with: headAttStr)
        }
        mdobj.atStr = attstr
        return attstr
    }
    static func tagfLineBreak(_ mdobj:MarkdownElement,_ tagItem:TagItem,_ match:NSTextCheckingResult)->NSAttributedString{
        let attstr = mdobj.atStr
        let text = attstr.string
/// **(.+?)**  range 0  is whole match,
///         range1 is  Bold String
        if Range(match.range(at: 1), in: text).map({ String(text[$0]) }) != nil{
            let headAttStr = NSMutableAttributedString(string: "\n")

            attstr.replaceCharacters(in: match.range(at: 0), with: headAttStr)
        }
        mdobj.atStr = attstr
        return attstr
    }
    static func tagfRuby(_ mdobj:MarkdownElement,_ tagItem:TagItem,_ match:NSTextCheckingResult)->NSAttributedString{
        let pattern = "<rb>([\\p{Han}]+?)<\\/rb><rt>([ㄅ-ㄩ˙ˊˇˋ]{1,4})<\\/rt>"

        let attstr = mdobj.atStr
        let text = attstr.string
        let settings = mdobj.settings
/// <ruby>(.|\\n)*?<\\/ruby>  range 0  is whole match,
///                   range1 is  ruby Sub String
        if let range1 = Range(match.range(at: 1), in: text).map({ String(text[$0]) }){
            let headAttStr = mdobj.rubyAnnotation( range1, pattern)
            let patstr = mdobj.addParagraphStyle(attributedString: headAttStr,settings: settings)
            attstr.replaceCharacters(in: match.range(at: 0), with: patstr)
        }
        mdobj.atStr = attstr
        return attstr
    }
    // ruby only true will add addParagraphStyle
    func rubyAnnotation (_ text: String, _ pattern:String)->NSMutableAttributedString{
        let rubysizefactor: CGFloat = 0.4 //0.333333333
        let fsize = headingFont[6].pointSize
        if (text == "" ) {return NSMutableAttributedString(string:"")}
        let attributedString = NSMutableAttributedString(string: text)
        for result in try! NSRegularExpression(pattern: pattern ).matches(in: text).reversed() {
            if let string = Range(result.range(at: 1), in: text).map({ String(text[$0]) }),
                let ruby = Range(result.range(at: 2), in: text).map({ String(text[$0]) }) {
      //          print("string\(string):\(ruby)")
                let annotation = CTRubyAnnotationCreateWithAttributes(.center, //CTRubyAlignment
                    // https://searchcode.com/file/331657127/Demo/System_Frameworks_iOS11/CoreText.framework/Headers/CTRubyAnnotation.h/
                        (settings.verticalform) ?.auto:.none,
                        //CTRubyOverhang kCTRubyOverhangNone
                        (settings.verticalform) ?.interCharacter:.before, //CTRubyPosition
                    ruby as CFString,
                    [
                        kCTRubyAnnotationSizeFactorAttributeName:rubysizefactor ,// 0.5
                        kCTForegroundColorAttributeName: settings.rubyfgcolor,
                        kCTVerticalFormsAttributeName:  settings.verticalform,
                        kCTBaselineOffsetAttributeName : (settings.verticalform) ? settings.rubybaseline: (settings.rubybaseline - fsize / 6.5),
//                        kCTBaselineOffsetAttributeName : (settings.verticalform) ? settings.rubybaseline:
//                            (settings.rubybaseline - UIFont.preferredFont(forTextStyle: .headline).pointSize * 1.0/4.0),
                    ] as CFDictionary)
         //       if (!rubyonoff) { // if true ruby is added
                    let annotatedString = NSAttributedString(string: string, attributes: [
                        .rubyAnnotation: annotation,
                    ])
                    attributedString.replaceCharacters(in: result.range, with: annotatedString)
                attributedString.addAttributes([
                    .font: UIFont(name: settings.fontname, size: settings.fontSize)!,
                ])
            }
        }

        return attributedString
    }
    func addWholeAttributes(attributedString:NSMutableAttributedString, settings:FramePageSettings) -> NSMutableAttributedString{
        attributedString.addAttributes([
        //    .font: UIFont(name: settings.fontname, size: settings.fontSize)!,
            .foregroundColor: settings.fontcolor,
            .backgroundColor: settings.fontbkcolor,
          //  .expansion: settings.expansion, // CGFloat
            //.obliqueness: 20.0, //obliqueness, // CGFloat
            .kern: settings.kerning,    // CGFloat
         //   .writingDirection: writingdirection,
            .verticalGlyphForm: settings.verticalform,
            //.link                 //
            //.ligature             //Int
            //.markedClauseSegment:  //Int
            //.cursor             //NSCursor
            //.obliqueness          //CGFloat
            //.shadow:10,              //NSShadow
            //.superscript           //Int
            //.paragraphStyle       //NSParagraphStyle
            //.writingdirection        //0LRE 1RLE 2LRO 3RLO
            // NSFontAttributeName                设置字体属性，默认值：字体：Helvetica(Neue) 字号：12
            // NSForegroundColorAttributeNam      设置字体颜色，取值为 UIColor对象，默认值为黑色
            // NSBackgroundColorAttributeName     设置字体所在区域背景颜色，取值为 UIColor对象，默认值为nil, 透明色
            // NSLigatureAttributeName            设置连体属性，取值为NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
            // NSKernAttributeName                设定字符间距，取值为 NSNumber 对象（整数），正值间距加宽，负值间距变窄
            // NSStrikethroughStyleAttributeName  设置删除线，取值为 NSNumber 对象（整数）
            // NSStrikethroughColorAttributeName  设置删除线颜色，取值为 UIColor 对象，默认值为黑色
            // NSUnderlineStyleAttributeName      设置下划线，取值为 NSNumber 对象（整数），枚举常量 NSUnderlineStyle中的值，与删除线类似
            // NSUnderlineColorAttributeName      设置下划线颜色，取值为 UIColor 对象，默认值为黑色
            // NSStrokeWidthAttributeName         设置笔画宽度，取值为 NSNumber 对象（整数），负值填充效果，正值中空效果
            // NSStrokeColorAttributeName         填充部分颜色，不是字体颜色，取值为 UIColor 对象
            // NSShadowAttributeName              设置阴影属性，取值为 NSShadow 对象
            // NSTextEffectAttributeName          设置文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用：
            // NSBaselineOffsetAttributeName      设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
            // NSObliquenessAttributeName         设置字形倾斜度，取值为 NSNumber （float）,正值右倾，负值左倾
            // NSExpansionAttributeName           设置文本横向拉伸属性，取值为 NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
            // NSWritingDirectionAttributeName    设置文字书写方向，从左向右书写或者从右向左书写
            // NSVerticalGlyphFormAttributeName   设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
            // NSLinkAttributeName                设置链接属性，点击后调用浏览器打开指定URL地址
            // NSAttachmentAttributeName          设置文本附件,取值为NSTextAttachment对象,常用于文字图片混排
            // NSParagraphStyleAttributeName      设置文本段落排版格式，取值为 NSParagraphStyle 对象
            //   NSParagraphStyleAttributeName 段落的风格（设置首行，行间距，对齐方式什么的）看自己需要什么属性，写什么
        ])
        return attributedString
    }
    func addParagraphStyle(attributedString:NSMutableAttributedString, settings:FramePageSettings) -> NSMutableAttributedString{
        let setfsize = CGFloat(headingFont[6].pointSize)
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()

        // *** set LineSpacing property in points ***
        // https://developer.apple.com/documentation/uikit/nsparagraphstyle
        paragraphStyle.lineSpacing = (settings.verticalform) ? settings.lineSpacing-10.0 :(settings.lineSpacing - setfsize/6.0)// Whatever line spacing you want in points
        paragraphStyle.alignment = .justified
      //  paragraphStyle.firstLineHeadIndent = settings.fontSize * 1
        paragraphStyle.paragraphSpacing = setfsize * 0.6
      //  paragraphStyle.baseWritingDirection = .leftToRight
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
     //   let uifont = fontArray[1].italicFont(size: settings.fontSize)
        return addWholeAttributes(attributedString: attributedString, settings: settings)

    }
}
    
let testMDString = """
# -<ruby><rb>將</rb><rt>ㄐㄧㄤ</rt><rb>進</rb><rt>ㄐㄧㄣˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt></ruby>-
##  <ruby><rb>將</rb><rt>ㄐㄧㄤ</rt><rb>進</rb><rt>ㄐㄧㄣˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt></ruby>
###  <ruby><rb>將</rb><rt>ㄐㄧㄤ</rt><rb>進</rb><rt>ㄐㄧㄣˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt></ruby>
####  <ruby><rb>將</rb><rt>ㄐㄧㄤ</rt><rb>進</rb><rt>ㄐㄧㄣˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt></ruby>
#  <ruby><rb>又</rb><rt>ㄧㄡˋ</rt><rb>作</rb><rt>ㄗㄨㄛˋ</rt>《<rb>惜</rb><rt>ㄒㄧ</rt><rb>罇</rb><rt>ㄗㄨㄣ</rt><rb>空</rb><rt>ㄎㄨㄥ</rt></ruby>
# <ruby><rb>將</rb><rt>ㄐㄧㄤ</rt><rb>進</rb><rt>ㄐㄧㄣˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt></ruby>
## <ruby><rb>又</rb><rt>ㄧㄡˋ</rt><rb>作</rb><rt>ㄗㄨㄛˋ</rt>《<rb>惜</rb><rt>ㄒㄧ</rt><rb>罇</rb><rt>ㄗㄨㄣ</rt><rb>空</rb><rt>ㄎㄨㄥ</rt></ruby>

<ruby><rb>作</rb><rt>ㄗㄨㄛˋ</rt><rb>者</rb><rt>ㄓㄜˇ</rt>：<rb>李</rb><rt>ㄌㄧˇ</rt><rb>白</rb><rt>ㄅㄞˊ</rt>　<rb>唐</rb><rt>ㄊㄤˊ</rt>
<rb>君</rb><rt>ㄐㄩㄣ</rt><rb>不</rb><rt>ㄅㄨˋ</rt><rb>見</rb><rt>ㄐㄧㄢˋ</rt><rb>黃</rb><rt>ㄏㄨㄤˊ</rt><rb>河</rb><rt>ㄏㄜˊ</rt><rb>之</rb><rt>ㄓ</rt><rb>水</rb><rt>ㄕㄨㄟˇ</rt><rb>天</rb><rt>ㄊㄧㄢ</rt><rb>上</rb><rt>ㄕㄤˋ</rt><rb>來</rb><rt>ㄌㄞˊ</rt>，<rb>奔</rb><rt>ㄅㄣ</rt><rb>流</rb><rt>ㄌㄧㄡˊ</rt><rb>到</rb><rt>ㄉㄠˋ</rt><rb>海</rb><rt>ㄏㄞˇ</rt><rb>不</rb><rt>ㄅㄨˋ</rt><rb>復</rb><rt>ㄈㄨˋ</rt><rb>回</rb><rt>ㄏㄨㄟˊ</rt>。
<rb>君</rb><rt>ㄐㄩㄣ</rt><rb>不</rb><rt>ㄅㄨˋ</rt><rb>見</rb><rt>ㄐㄧㄢˋ</rt><rb>高</rb><rt>ㄍㄠ</rt><rb>堂</rb><rt>ㄊㄤˊ</rt><rb>明</rb><rt>ㄇㄧㄥˊ</rt><rb>鏡</rb><rt>ㄐㄧㄥˋ</rt><rb>悲</rb><rt>ㄅㄟ</rt><rb>白</rb><rt>ㄅㄞˊ</rt><rb>髮</rb><rt>ㄈㄚˋ</rt>，<rb>朝</rb><rt>ㄔㄠˊ</rt><rb>如</rb><rt>ㄖㄨˊ</rt><rb>青</rb><rt>ㄑㄧㄥ</rt><rb>絲</rb><rt>ㄙ</rt><rb>暮</rb><rt>ㄇㄨˋ</rt><rb>成</rb><rt>ㄔㄥˊ</rt><rb>雪</rb><rt>ㄒㄩㄝˇ</rt>。
<rb>人</rb><rt>ㄖㄣˊ</rt><rb>生</rb><rt>ㄕㄥ</rt><rb>得</rb><rt>ㄉㄜˊ</rt><rb>意</rb><rt>ㄧˋ</rt><rb>須</rb><rt>ㄒㄩ</rt><rb>盡</rb><rt>ㄐㄧㄣˇ</rt><rb>歡</rb><rt>ㄏㄨㄢ</rt>，<rb>莫</rb><rt>ㄇㄛˋ</rt><rb>使</rb><rt>ㄕˇ</rt><rb>金</rb><rt>ㄐㄧㄣ</rt><rb>樽</rb><rt>ㄗㄨㄣ</rt><rb>空</rb><rt>ㄎㄨㄥ</rt><rb>對</rb><rt>ㄉㄨㄟˋ</rt><rb>月</rb><rt>ㄩㄝˋ</rt>。
<rb>天</rb><rt>ㄊㄧㄢ</rt><rb>生</rb><rt>ㄕㄥ</rt><rb>我</rb><rt>ㄨㄛˇ</rt><rb>材</rb><rt>ㄘㄞˊ</rt><rb>必</rb><rt>ㄅㄧˋ</rt><rb>有</rb><rt>ㄧㄡˇ</rt><rb>用</rb><rt>ㄩㄥˋ</rt>，<rb>千</rb><rt>ㄑㄧㄢ</rt><rb>金</rb><rt>ㄐㄧㄣ</rt><rb>散</rb><rt>ㄙㄢˋ</rt><rb>盡</rb><rt>ㄐㄧㄣˇ</rt><rb>還</rb><rt>ㄏㄞˊ</rt><rb>復</rb><rt>ㄈㄨˋ</rt><rb>來</rb><rt>ㄌㄞˊ</rt>。
<rb>烹</rb><rt>ㄆㄥ</rt><rb>羊</rb><rt>ㄧㄤˊ</rt><rb>宰</rb><rt>ㄗㄞˇ</rt><rb>牛</rb><rt>ㄋㄧㄡˊ</rt><rb>且</rb><rt>ㄑㄧㄝˇ</rt><rb>爲</rb><rt>ㄨㄟˋ</rt><rb>樂</rb><rt>ㄌㄜˋ</rt>，<rb>會</rb><rt>ㄏㄨㄟˋ</rt><rb>須</rb><rt>ㄒㄩ</rt><rb>一</rb><rt>ㄧ</rt><rb>飲</rb><rt>ㄧㄣˇ</rt><rb>三</rb><rt>ㄙㄢ</rt><rb>百</rb><rt>ㄅㄞˇ</rt><rb>杯</rb><rt>ㄅㄟ</rt>。
<rb>岑</rb><rt>ㄘㄣˊ</rt><rb>夫</rb><rt>ㄈㄨ</rt><rb>子</rb><rt>˙ㄗ</rt>，<rb>丹</rb><rt>ㄉㄢ</rt><rb>丘</rb><rt>ㄑㄧㄡ</rt><rb>生</rb><rt>ㄕㄥ</rt>。<rb>將</rb><rt>ㄐㄧㄤ</rt><rb>進</rb><rt>ㄐㄧㄣˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt>，<rb>杯</rb><rt>ㄅㄟ</rt><rb>莫</rb><rt>ㄇㄛˋ</rt><rb>停</rb><rt>ㄊㄧㄥˊ</rt>。
<rb>與</rb><rt>ㄩˇ</rt><rb>君</rb><rt>ㄐㄩㄣ</rt><rb>歌</rb><rt>ㄍㄜ</rt><rb>一</rb><rt>ㄧ</rt><rb>曲</rb><rt>ㄑㄩ</rt>，<rb>請</rb><rt>ㄑㄧㄥˇ</rt><rb>君</rb><rt>ㄐㄩㄣ</rt><rb>爲</rb><rt>ㄨㄟˋ</rt><rb>我</rb><rt>ㄨㄛˇ</rt><rb>傾</rb><rt>ㄑㄧㄥ</rt><rb>耳</rb><rt>ㄦˇ</rt><rb>聽</rb><rt>ㄊㄧㄥ</rt>。
<rb>鐘</rb><rt>ㄓㄨㄥ</rt><rb>鼓</rb><rt>ㄍㄨˇ</rt><rb>饌</rb><rt>ㄓㄨㄢˋ</rt><rb>玉</rb><rt>ㄩˋ</rt><rb>不</rb><rt>ㄅㄨˋ</rt><rb>足</rb><rt>ㄗㄨˊ</rt><rb>貴</rb><rt>ㄍㄨㄟˋ</rt>，<rb>但</rb><rt>ㄉㄢˋ</rt><rb>願</rb><rt>ㄩㄢˋ</rt><rb>長</rb><rt>ㄓㄤˇ</rt><rb>醉</rb><rt>ㄗㄨㄟˋ</rt><rb>不</rb><rt>ㄅㄨˋ</rt><rb>願</rb><rt>ㄩㄢˋ</rt><rb>醒</rb><rt>ㄒㄧㄥˇ</rt>。
<rb>古</rb><rt>ㄍㄨˇ</rt><rb>來</rb><rt>ㄌㄞˊ</rt><rb>聖</rb><rt>ㄕㄥˋ</rt><rb>賢</rb><rt>ㄒㄧㄢˊ</rt><rb>皆</rb><rt>ㄐㄧㄝ</rt><rb>寂</rb><rt>ㄐㄧˋ</rt><rb>寞</rb><rt>ㄇㄛˋ</rt>，<rb>惟</rb><rt>ㄨㄟˊ</rt><rb>有</rb><rt>ㄧㄡˇ</rt><rb>飲</rb><rt>ㄧㄣˇ</rt><rb>者</rb><rt>ㄓㄜˇ</rt><rb>留</rb><rt>ㄌㄧㄡˊ</rt><rb>其</rb><rt>ㄑㄧˊ</rt><rb>名</rb><rt>ㄇㄧㄥˊ</rt>。
<rb>陳</rb><rt>ㄔㄣˊ</rt><rb>王</rb><rt>ㄨㄤˊ</rt><rb>昔</rb><rt>ㄒㄧ</rt><rb>時</rb><rt>ㄕˊ</rt><rb>宴</rb><rt>ㄧㄢˋ</rt><rb>平</rb><rt>ㄆㄧㄥˊ</rt><rb>樂</rb><rt>ㄌㄜˋ</rt>，<rb>斗</rb><rt>ㄉㄡˋ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt><rb>十</rb><rt>ㄕˊ</rt><rb>千</rb><rt>ㄑㄧㄢ</rt><rb>恣</rb><rt>ㄗˋ</rt><rb>歡</rb><rt>ㄏㄨㄢ</rt><rb>謔</rb><rt>ㄒㄩㄝˋ</rt>。
<rb>主</rb><rt>ㄓㄨˇ</rt><rb>人</rb><rt>ㄖㄣˊ</rt><rb>何</rb><rt>ㄏㄜˊ</rt><rb>為</rb><rt>ㄨㄟˋ</rt><rb>言</rb><rt>ㄧㄢˊ</rt><rb>少</rb><rt>ㄕㄠˇ</rt><rb>錢</rb><rt>ㄑㄧㄢˊ</rt>？<rb>徑</rb><rt>ㄐㄧㄥˋ</rt><rb>須</rb><rt>ㄒㄩ</rt><rb>沽</rb><rt>ㄍㄨ</rt><rb>取</rb><rt>ㄑㄩˇ</rt><rb>對</rb><rt>ㄉㄨㄟˋ</rt><rb>君</rb><rt>ㄐㄩㄣ</rt><rb>酌</rb><rt>ㄓㄨㄛˊ</rt>。
<rb>五</rb><rt>ㄨˇ</rt><rb>花</rb><rt>ㄏㄨㄚ</rt><rb>馬</rb><rt>ㄇㄚˇ</rt>，<rb>千</rb><rt>ㄑㄧㄢ</rt><rb>金</rb><rt>ㄐㄧㄣ</rt><rb>裘</rb><rt>ㄑㄧㄡˊ</rt>。
<rb>呼</rb><rt>ㄏㄨ</rt><rb>兒</rb><rt>ㄦˊ</rt><rb>將</rb><rt>ㄐㄧㄤ</rt><rb>出</rb><rt>ㄔㄨ</rt><rb>換</rb><rt>ㄏㄨㄢˋ</rt><rb>美</rb><rt>ㄇㄟˇ</rt><rb>酒</rb><rt>ㄐㄧㄡˇ</rt>，<rb>與</rb><rt>ㄩˇ</rt><rb>爾</rb><rt>ㄦˇ</rt><rb>同</rb><rt>ㄊㄨㄥˊ</rt><rb>銷</rb><rt>ㄒㄧㄠ</rt><rb>萬</rb><rt>ㄨㄢˋ</rt><rb>古</rb><rt>ㄍㄨˇ</rt><rb>愁</rb><rt>ㄔㄡˊ</rt>。</ruby>

# This is an H1 **Bold**
## This is an -H2-3Italc-
### This is *Italics* an H3-3
#### This is ***BoldItalics*** an H4-3
##### This is an H5-3
###### This is an H6-3 ###########

###### **Bold** *Italics* ***BoldItalics***



"""



