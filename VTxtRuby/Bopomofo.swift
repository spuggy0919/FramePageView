//
//  bopomofo.swift
//  FileOperation
//
//  Created by spuggy0919@gmail.com on 2021/11/29.
//

import Foundation
import UIKit

enum rubyParserType{
    case furikana // ｜(.+?)《(.+?)》
    case bopomofo // "([\\p{Han}]+?)[\s]*([ㄅ-ㄩ˙ˊˇˋ]{1,4})"
    case Hanpinying  // "([\\p{Han}]+?)[\n\t]*([a-z]{1,6}[1-4]?)"
    case pingyin  // "([\\p{Han}]+?)[\\n\\t]*\\(([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ]+?)\\)"
}
class rubyParser {
    var  rubyformat:rubyParserType
    var  regpattern:String
    var  parser: (String,String)->NSAttributedString // string, regString
    init(_ rformat:rubyParserType,_ regpattern:String,_ parserf: @escaping (String,String) -> NSAttributedString){
        self.rubyformat = rformat
        self.regpattern = regpattern
        self.parser = parserf
    }
}

class RubyAnnotationPattern {
    var description:String
    var pattern:String
    var format:String
    var groups:Int
    var replace:[String]
    init(_ descript:String, _ format:String, _ pattern:String, groups:Int){
        self.description = descript
        self.format = format
        self.pattern = pattern
        self.groups = groups
        self.replace = []
    }
    init(_ descript:String, _ format:String, _ pattern:String, groups:Int, replaces:[String]){
        self.description = descript
        self.format = format
        self.pattern = pattern
        self.groups = groups
        self.replace = replaces
    }
}
///        注音符號 Unicode 範圍，整理如下
///        ㄅㄆㄇ ~ ㄧㄨㄩ：\u3105-\u3129
///        二聲(ˊ)：\u02CA
///        三聲(ˇ)：\u02C7
///        四聲(ˊ)：\u02CB
///        輕聲(˙)：\u02D9
        //"([\\p{Han}]+?)[\n\t]*([a-z]{1,6}[1-4]?)
        //([\\p{Han}]+?)[\\s]*([ㄅ-ㄩ˙ˊˇˋ]{1,4})
//        "([\\p{Han}]{1})[\\u000A-\\u000D\\u0020\\u0085\\u00A0\\u1680\\u180E\\u2000-\\u200A\\u2028\\u2029\\u202F\\u205F\\u3000]*([ㄅ-ㄩ˙ˊˇˋ]{1,4})"
        //"([\\p{Han}]+?)[\\n\\t\" \"]*[\\(（]([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ1-4]+?)[\\)）]"
var rubyArray:[RubyAnnotationPattern] = [
    ///        注音符號 Unicode 範圍，整理如下
    ///        ㄅㄆㄇ ~ ㄧㄨㄩ：\u3105-\u3129
    ///        二聲(ˊ)：\u02CA
    ///        三聲(ˇ)：\u02C7
    ///        四聲(ˊ)：\u02CB
    ///        輕聲(˙)：\u02D9
    
    .init("ㄅㄆㄇㄈ拼音日文：｜漢字《ㄅㄆㄇ》","｜日《ㄖˋ》｜文《ㄨㄣˊ》","｜(.+?)《(.+?)》",groups: 2),
    .init("ㄅㄆㄇㄈ：ruby","<rb>漢</rb><rt>ㄏㄢˋ</rt>","<rb>([\\p{Han}]+?)</rb><rt>([ㄅ-ㄩ˙ˊˇˋ]{1,4})</rt>",groups: 2),
    .init("ㄅㄆㄇㄈ：半形括弧","漢(ㄏㄢˋ)字(ㄗˋ)","([\\p{Han}]+?)[\\s]*[\\(]([ㄅ-ㄩ˙ˊˇˋ]{1,4})[\\)]",groups: 2),
    .init("ㄅㄆㄇㄈ：漢ㄅㄆㄇㄈ混合","漢ㄏㄢˋ字ㄗˋ","([\\p{Han}]+?)[\\s]*([ㄅ-ㄩ˙ˊˇˋ]{1,4})",groups: 2),
    .init("拼音：ruby","<rb>漢</rb><rt>ㄏㄢˋ</rt>","<rb>([\\p{Han}]+?)</rb><rt>([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ1-4]+)</rt>",groups: 2),
    .init("拼音：半形與全形括弧","衣(yī) 裳（shang）","([\\p{Han}]+?)[\\n\\t\" \"]*[\\(（]([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ1-4]+)[\\)）]",groups: 2),
    .init("拼音：漢拼音混合","衣yī 裳 shang","([\\p{Han}]+?)[\\n\\t\" \"]*([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ1-4]+)",groups: 2),
]
class Bopomofo {
    var text:String
    var settings:FramePageSettings
    
    init(text:String,settings:FramePageSettings){
        self.text = text
        self.settings = settings
    }
    // parser here
    func stripSpace(_ text:String) -> String{ //\\r\\f\\p{Z}
        // "^\\s*" trimming leading whitespace
        let text_1 = text.findReplace1(regex: "<ruby>", replace: "")
        let text_2 = text_1.findReplace1(regex: "</ruby>", replace: "")
        let text1 = text_2.findReplace1(regex: "^\\s*", replace: "")
        let text2 = text1.findReplace1(regex: "(\\r?\\n|\\r)+", replace: "\n")
       // let text3 = text2.findReplace1(regex: "([　]{2})", replace: "")   //全形空白, instr: text1
        return text2
    //    text.findReplace(regex: "([　]+)", instr: text, replace: "")
      //  text.findReplace(regex: "([\\p{Han}]+?)[\\s]+", instr: text, replace: "")
    }
    func detectRubyAnnotation(_ text:String) -> String?{
        for i in 0..<rubyArray.count {
            do {
                let input = text
                let regex = try NSRegularExpression(pattern: rubyArray[i].pattern, options: NSRegularExpression.Options.caseInsensitive)
                let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

                if let match = matches.first {
                    let range = match.range(at:1) // bug for pingying
                    if let swiftRange = Range(range, in: input) {
                        _ = input[swiftRange]
                        return rubyArray[i].pattern
                    }
                }
            } catch {
                // regex was bad!
            }
        }
        return nil
    }
    func bopomofo(text: String)->NSAttributedString{
        let rubysizefactor: CGFloat = 0.4 //0.333333333
        if (text == "" ) {return NSAttributedString(string:"")}
        let text = stripSpace(text)
        let attributedString = NSMutableAttributedString(string: text)
        if let pattern = detectRubyAnnotation(text) {
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
                        kCTBaselineOffsetAttributeName : (settings.verticalform) ? settings.rubybaseline: (settings.rubybaseline - CGFloat(settings.fontSize)*1.0/4.0),
                    ] as CFDictionary)
         //       if (!rubyonoff) { // if true ruby is added
                    let annotatedString = NSAttributedString(string: string, attributes: [
                        .rubyAnnotation: annotation,
                    ])
                    attributedString.replaceCharacters(in: result.range, with: annotatedString)

            //    }
            }

        }
    } // pattern detect if
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()

        // *** set LineSpacing property in points ***
        // https://developer.apple.com/documentation/uikit/nsparagraphstyle
        paragraphStyle.lineSpacing = (settings.verticalform) ? settings.lineSpacing-10.0 :(settings.lineSpacing - (CGFloat(settings.fontSize)/6.0))// Whatever line spacing you want in points
        paragraphStyle.alignment = .justified
      //  paragraphStyle.firstLineHeadIndent = settings.fontSize * 1
        paragraphStyle.paragraphSpacing = settings.fontSize * 0.6
      //  paragraphStyle.baseWritingDirection = .leftToRight
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
     //   let uifont = fontArray[1].italicFont(size: settings.fontSize)
        attributedString.addAttributes([
            .font: UIFont(name: settings.fontname, size: settings.fontSize)!,
            .foregroundColor: settings.fontcolor,
            .backgroundColor: settings.fontbkcolor,
            .expansion: settings.expansion, // CGFloat
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
        
}
