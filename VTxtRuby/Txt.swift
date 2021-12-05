//
//  Txt.swift
//  
//
//  Created by spuggy0919@gmail.com on 2021/11/24.
//
//

import Foundation
import UIKit
// ruby parser
// ｜心《ㄒㄧㄣ》 // ｜(.+?)《(.+?)》
//  詩ㄕ名ㄇㄧㄥˊ // "([\\p{Han}]+?)[\s]*([ㄅ-ㄩ˙ˊˇˋ]{1,4})"
// 長(cháng) 信(xìn) 怨(yuàn) 王(wáng) 昌(chāng) 齡(líng) "([\\p{Han}]+?)[\\n\\t]*\\(([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ1-4]+?)\\)"
// 長cháng 信xìn 怨yuàn 王wáng 昌chāng 齡líng "([\\p{Han}]+?)[\\n\\t]*\\(([a-zA-Zāɑ̄ēīōūǖĀĒĪŌŪǕáɑ́éíóúǘÁÉÍÓÚǗǎɑ̌ěǐǒǔǚǍĚǏǑǓǙàɑ̀èìòùǜÀÈÌÒÙǛɑüÜ1-4]+?)\\)"



extension String {
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    func findReplace1(regex:String, replace:String) -> String{
        return self.replacingOccurrences(of: regex, with: replace, options: .regularExpression)
    }
    func findReplace(regex:String, instr:String, replace:String) -> String{
    var str = instr
        let regex = try! NSRegularExpression(pattern: regex, options: .caseInsensitive)
        str = regex.stringByReplacingMatches(in: instr, options: [], range: NSRange(0..<instr.utf16.count), withTemplate: replace)
        
        return str
    }
    
    var containsChineseCharacters: Bool {
            return self.range(of: "\\p{Han}", options: .regularExpression) != nil
        }
    //->These are *** bad words.
    /// Finds matching groups and replace them with a template using an intuitive API.
    ///
    /// This example will go through an input string and replace all occurrences of "MyGreatBrand" with "**MyGreatBrand**".
    ///
    ///     let regex = try! NSRegularExpression(pattern: #"(MyGreatBrand)"#) // Matches all occurrences of MyGreatBrand
    ///     someMarkdownDocument.replaceGroups(matching: regex, with: #"**$1**"#) // Surround all matches with **, formatting as bold text in markdown.
    ///     print(someMarkdownDocument)
    ///
    /// - Parameters:
    ///   - regex: the regex used to match groups.
    ///   - template: the template used to replace the groups. Reference groups inside your template using dollar sign symbol followed by the group number, e.g. "$1", "$2", etc.
    public mutating func replaceGroups(matching regex: NSRegularExpression, with template: String, options: NSRegularExpression.MatchingOptions = []) {
        var replacingRanges: [(subrange: Range<String.Index>, replacement: String)] = []
        let matches = regex.matches(in: self, options: options, range: NSRange(location: 0, length: utf16.count))
        for match in matches {
            var replacement: String = template
            for rangeIndex in 1 ..< match.numberOfRanges {
                let group: String = (self as NSString).substring(with: match.range(at: rangeIndex))
                replacement = replacement.replacingOccurrences(of: "$\(rangeIndex)", with: group)
            }
            replacingRanges.append((subrange: Range(match.range(at: 0), in: self)!, replacement: replacement))
        }
        for (subrange, replacement) in replacingRanges.reversed() {
            self.replaceSubrange(subrange, with: replacement)
        }
    }

    /// Finds matching groups and replace them with a template using an intuitive API.
    ///
    /// This example will go through an input string and replace all occurrences of "MyGreatBrand" with "**MyGreatBrand**".
    ///
    ///     let regex = try! NSRegularExpression(pattern: #"(MyGreatBrand)"#) // Matches all occurrences of MyGreatBrand
    ///     let result = someMarkdownDocument.replacingGroups(matching: regex, with: #"**$1**"#) // Surround all matches with **, the bold text modifier syntax in markdown.
    ///     print(result)
    ///
    /// - Parameters:
    ///   - regex: the regex used to match groups.
    ///   - template: the template used to replace the groups. Reference groups inside your template using dollar sign symbol followed by the group number, e.g. "$1", "$2", etc.
    public func replacingGroups(matching regex: NSRegularExpression, with transformationString: String) -> String {
        var mutableSelf = self
        mutableSelf.replaceGroups(matching: regex, with: transformationString)
        return mutableSelf
    }
}

extension NSAttributedString.Key {
    static let rubyAnnotation: NSAttributedString.Key = kCTRubyAnnotationAttributeName as NSAttributedString.Key
}



extension NSMutableAttributedString {
    func addAttributes(_ attrs: [NSAttributedString.Key: Any] = [:]) {
        addAttributes(attrs, range: NSRange(string.startIndex ..< string.endIndex, in: string))
    }
}

extension NSRegularExpression {
    func matches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
        return matches(in: string, options: options, range: NSRange(string.startIndex ..< string.endIndex, in: string))
    }
}

let 心經筆記="""
心經筆記  作者 Spuggy 修改于二○○九年五月十五日


本文

佛經裡的遊子吟。

心經是「般若波羅密多心經」的簡稱，和大悲咒、觀世音菩薩普門品、金剛經都是民間流傳極廣的佛教經文，其譯本眾多名稱也多有差異，但所說的都是指般若波羅密多，即是到彼岸的大智慧，心經是般若經文的摘要重點，雖短短貳百六十字，所提及的般若層次橫跨時間空間生理及心理，足以讓人終身受用、咀嚼玩味，但從日常生活中體會又很平實，沒什麼密秘可言，若把它想成慈母對他鄉的遊子循循善誘便格外親切。 (不會唸可以買齊豫唱經給你聽-快樂行 所以會快樂)，

下面先抄寫經文：

心ㄒㄧㄣ經ㄐㄧㄥ注ㄓㄨˋ音ㄧㄣ版ㄅㄢˇ
般ㄅㄛ若ㄖㄜˇ波ㄅㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ心ㄒㄧㄣ經ㄐㄧㄥ唐ㄊㄤˊ三ㄙㄢ藏ㄗㄤˋ法ㄈㄚˇ師ㄕ玄ㄒㄩㄢˊ奘ㄗㄤˋ奉ㄈㄥˋ詔ㄓㄠ譯ㄧˋ
觀ㄍㄨㄢ自ㄗˋ在ㄗㄞˋ菩ㄆㄨˊ薩ㄙㄚˋ行ㄒㄧㄥˊ深ㄕㄣ般ㄅㄛ若ㄖㄜˇ波ㄅㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ時ㄕˊ照ㄓㄠˋ見ㄐㄧㄢˋ五ㄨˇ蘊ㄩㄣˋ皆ㄐㄧㄝ空ㄎㄨㄥ度ㄉㄨˋ一ㄧˊ切ㄑㄧㄝˋ苦ㄎㄨˇ厄ㄜˋ
舍ㄕㄜˋ利ㄌㄧˋ子ㄗˇ色ㄙㄜˋ不ㄅㄨˋ異ㄧˋ空ㄎㄨㄥ空ㄎㄨㄥ不ㄅㄨˊ異ㄧˋ色ㄙㄜˋ色ㄙㄜˋ即ㄐㄧˊ是ㄕˋ空ㄎㄨㄥ空ㄎㄨㄥ即ㄐㄧˊ是ㄕˋ色ㄙㄜˋ受ㄕㄡˋ想ㄒㄧㄤˇ行ㄒㄧㄥˊ識ㄕˋ亦ㄧˋ復ㄈㄨˋ如ㄖㄨˊ是ㄕˋ
舍ㄕㄜˋ利ㄌㄧˋ子ㄗˇ是ㄕˋ諸ㄓㄨ法ㄈㄚˇ空ㄎㄨㄥ相ㄒㄧㄤˋ不ㄅㄨˋ生ㄕㄥ不ㄅㄨˊ滅ㄇㄧㄝˋ不ㄅㄨˋ垢ㄍㄡˋ不ㄅㄨˊ淨ㄐㄧㄥˋ不ㄅㄨˋ增ㄗㄥ不ㄅㄨˋ減ㄐㄧㄢˇ是ㄕˋ故ㄍㄨˋ空ㄎㄨㄥ中ㄓㄨㄥ無ㄨˊ色ㄙㄜˋ無ㄨˊ受ㄕㄡˋ想ㄒㄧㄤˇ行ㄒㄧㄥˊ識ㄕˋ無ㄨˊ眼ㄧㄢˇ耳ㄦˇ鼻ㄅㄧˊ舌ㄕㄜˊ身ㄕㄣ意ㄧˋ無ㄨˊ色ㄙㄜˋ聲ㄕㄥ香ㄒㄧㄤ味ㄨㄟˋ觸ㄔㄨˋ法ㄈㄚˇ無ㄨˊ眼ㄧㄢˇ界ㄐㄧㄝˋ乃ㄋㄞˇ至ㄓˋ無ㄨˊ意ㄧˋ識ㄕˋ界ㄐㄧㄝˋ無ㄨˊ無ㄨˊ明ㄇㄧㄥˊ亦ㄧˋ無ㄨˊ無ㄨˊ明ㄇㄧㄥˊ盡ㄐㄧㄣˋ乃ㄋㄞˇ至ㄓˋ無ㄨˊ老ㄌㄠˇ死ㄙˇ亦ㄧˋ無ㄨˊ老ㄌㄠˇ死ㄙˇ盡ㄐㄧㄣˋ無ㄨˊ苦ㄎㄨˇ集ㄐㄧˊ滅ㄇㄧㄝˋ道ㄉㄠˋ無ㄨˊ智ㄓˋ亦ㄧˋ無ㄨˊ得ㄉㄜˊ以ㄧˇ無ㄨˊ所ㄙㄨㄛˇ得ㄉㄜˊ故ㄍㄨˋ
菩ㄆㄨˊ提ㄊㄧˊ薩ㄙㄚˋ埵ㄉㄨㄛˇ依ㄧ般ㄅㄛ若ㄖㄜˇ波ㄆㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ故ㄍㄨˋ心ㄒㄧㄣ無ㄨˊ罣ㄍㄨㄚˋ礙ㄞˋ無ㄨˊ罣ㄍㄨㄚˋ礙ㄞˋ故ㄍㄨˋ無ㄨˊ有ㄧㄡˇ恐ㄎㄨㄥˇ怖ㄅㄨˋ遠ㄩㄢˇ離ㄌㄧˊ顛ㄉㄧㄢ倒ㄉㄠˇ夢ㄇㄥˋ想ㄒㄧㄤˇ究ㄐㄧㄡˋ竟ㄐㄧㄥˋ涅ㄋㄧㄝˋ槃ㄆㄢˊ
三ㄙㄢ世ㄕˋ諸ㄓㄨ佛ㄈㄛˊ依ㄧ般ㄅㄛ若ㄖㄜˇ波ㄆㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ故ㄍㄨˋ得ㄉㄛˊ阿ㄚ耨ㄋㄡˋ多ㄉㄨㄛ羅ㄌㄨㄛˊ三ㄙㄢ藐ㄇㄧㄠˇ三ㄙㄢ菩ㄆㄨˊ提ㄊㄧˊ
故ㄍㄨˋ知ㄓ般ㄅㄛ若ㄖㄜˇ波ㄅㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ是ㄕˋ大ㄉㄚˋ神ㄕㄣˊ咒ㄓㄡˋ是ㄕˋ大ㄉㄚˋ明ㄇㄧㄥˊ咒ㄓㄡˋ是ㄕˋ無ㄨˊ上ㄕㄤˋ咒ㄓㄡˋ是ㄕˋ無ㄨˊ等ㄉㄥˇ等ㄉㄥˇ咒ㄓㄡˋ能ㄋㄥˊ除ㄔㄨˊ一ㄧˊ切ㄑㄧㄝˋ苦ㄎㄨˇ真ㄓㄣ實ㄕˊ不ㄅㄨˋ虛ㄒㄩ
故ㄍㄨˋ說ㄕㄨㄛ般ㄅㄛ若ㄖㄜˇ波ㄅㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ咒ㄓㄡˋ即ㄐㄧˊ說ㄕㄨㄛ咒ㄓㄡˋ曰ㄩㄝ
揭ㄐㄧㄝ諦ㄉㄧˋ揭ㄐㄧㄝ諦ㄉㄧˋ波ㄅㄛ羅ㄌㄨㄛˊ揭ㄐㄧㄝ諦ㄉㄧˋ波ㄅㄛ羅ㄌㄨㄛˊ僧ㄙㄥ揭ㄐㄧㄝ諦ㄉㄧˋ菩ㄆㄨˊ提ㄊㄧˊ薩ㄙㄚˋ婆ㄆㄨㄛˊ訶ㄏㄜ
摩ㄇㄛˊ訶ㄏㄜ般ㄅㄛ若ㄖㄜˇ波ㄅㄛ羅ㄌㄨㄛˊ蜜ㄇㄧˋ多ㄉㄨㄛ(三ㄙㄢ稱ㄔㄥ)

關鍵辭(Keyword)淺釋
般若 梵音，大智慧，佛性。
波羅密多
    梵音，到彼岸，心念有如海中波浪，靜(健康)時像春風輕拂的湖面，惱(生病)時像颱風滔滔巨浪，到彼岸意指心處於平靜無念的層次，非言語可形容的一片靜又能照知一切。
觀自在
    一說觀世音，或指能察覺到自性。
菩薩
    覺悟的智者
五蘊
    指色、受、想、行、識五種陰影，蘊是聚積的意思，遮掩住大智慧的烏雲。五是上述五種分類。
苦厄
    指世間所有的事物皆無常(Impermanent)不恆久，所以都是苦，如生(birth)、老(old age)、病(illness)、死(death)…等。
    舍利子
    舍利弗，世尊十大弟子，智慧第一。
色受想行識
    在人身(或有情)中的五種聚積性質(property)，色是物質(matter)，受是感受(feel)，想是想像(thought)，行是行動(action)，識是認識分別(recognition or consciousness)。
不生不滅  不垢不淨  不增不減
    佛性(或稱一切種智、本來面目、禪宗指月的月亮)的本質。生命根本驅動的能量(這樣比喻狹隘些)，有如電腦有硬體、軟體、軔體還有電能，電腦不知由電驅動(好比駭客任務(Matrix)的情節)。
空中無色  無受想行識
    色是物質，現今物理在物質的標準模型(Standard Model)中，電子質子中子都是由夸克構成，可以和能量互相變換，電子與原子核間更有一相對的空無，在絕對的空間時間物質可以說存在，也可以說不存在；而受想行識也是如此。
無眼耳鼻舌身意  無色聲香味觸法  無眼界  乃至無意識界
    指根、塵、識十八界空間(space)的互動，人(廣義是有情，泛指宇宙間各種生命形態)與週遭環境互動的空間模型(model)，根是眼、耳、鼻、舌、身、意，人的各種感知器官(Sesnor or perception)。塵指色、聲、香、味、觸、法，是外在影響我們的種種事物的輸入(Input)，識指眼界、耳界、鼻界、舌界、身界至意識界，是人對根塵接觸後交互作用下了了分別(recognition)，簡單比喻為人腦的反應聯想(Associative Memory)，無指跳脫這種根塵識的糾纏。
無無明  亦無無明盡  乃至無老死  亦無老死盡
    十二因緣時間(time)軸上的變化，是過去世(past)現在世(now)未來世(future)的三世因果關係，或視為一生的十二階段或狀態(state)，即無明(ignorance)、行(action)、識consciousness)、名色(object)、六入(six sense organs)、觸(contact)、受(Sensation)、愛(desire)、取(clinging)、有(existence)、生(birth)、老死(old age and death)，無指不受三世因果時間軸上的束縛。。
無苦集滅道
    四諦(The Four Noble Truths)苦、集、滅、道，苦是迷失的結果而集 (汲汲營營)是迷失的原因，收集了很多書卻不知如何讀如何整理，或有了煙癮(集)想戒也戒不了身體也變差了(苦)。所以世尊第一次說法便指明世間的因果是苦集，必須藉著由道來成就寂滅。為何要追求寂滅？因為世間只有苦集，成就滅才能離苦得樂。很難理解可能是沒有癮頭，要知道初戀很爽(集)，但失戀了又有些傷感(苦)，須要時間療傷(道)，才能再熱戀(是集不是滅)，最終成情「剩」(滅)。
無智亦無得
    當回歸到本來自性，你的智慧不是增長只是悟起(Enlightment)，那是本來便擁有的，不要有得到的竊喜心不然又要失去了。
菩提薩埵
    菩提是覺，薩埵是有情(眾生)。
罣礙
    想捉住所有，卻怎知不能擁有，還再想便是牽掛了。
恐怖
    是指生死輪迴之事恐怖。
顛倒
    四顛倒，凡夫有四顛倒，認為一切都是恆常(forever)、認苦為樂、身不淨以為淨、以四大假合身為我。二乘四倒，常計無常、樂計為無樂、無我顛倒、無淨顛倒。好像過由不及。
夢想
    夢想有四因，前事起因，日有所思夜有所夢，福報感天天人入夢，生病四大不調惡夢。人生一場夢。
    涅槃
    有餘涅槃或無餘涅槃，分別指有無色身相續，兩者都已寂滅，不被苦惱拘絆。
阿耨多羅三藐三菩提
    指無上正等覺，宇宙之真理無不知。
揭諦揭諦  波羅揭諦  波羅僧揭諦  菩提薩婆訶
    梵音，走吧走吧，到彼岸去，一快到彼岸去，好成就無上菩提。


白話譯文
 (譯文的開始要設立一個場景，想像你是舍利弗，懂得世尊所說的一切心心契合，世尊像個慈父對你循循善誘，你已經聽了許多道理五蘊四諦十二因緣十八界，是一個大智慧者但還未到達目的地，世尊仍叮嚀你什麼才是究竟。然後聽聽齊豫唱經給你聽-快樂行 所以會快樂，情緒培養好後，才繼續往下看)

觀世音菩薩，心處在智慧平靜的當下，身中的烏雲消散，苦也殞滅。
舍利弗，物質和空是一樣的，何以物質阻礙你呢？受想行識也是如此性質。
舍利弗，絕對的真理是空相且存在，不會生起滅去，沒有垢淨，也沒有增減，
        不被五蘊遮蔽，
        不會捲入十八界空間法則的漩渦，
        不受十二因緣法時間的禁錮
        更不被世間四諦的苦集迷惑。
覺悟的眾生，因智慧平靜的當下，遠離了巔倒夢想，再也不會牽掛，不會驚恐。
三世的古佛，因智慧平靜的當下，能盡知宇宙一切真理。
般若波羅蜜多，能神清氣爽，滌心淨慮，昇華你的心靈，除卻一切苦難是真實的。
所以說
    觀心關心吧，到寂靜地，一起到寂靜地去，讓眾生覺醒吧。

方法
１    背熟心經原文。如何背分七段聯想字記憶，背完後要丟掉下列文詞，當做我沒說(如筏喻者，法尚應捨，何況非法)。
觀行照度
舍五蘊皆空
舍諸法空相不無五蘊十八界十二因緣四諦無智無得
菩提薩埵
三世諸佛
神明上等
揭諦揭諦  波羅揭諦  波羅僧揭諦  菩提薩婆訶
２    每天找個固定時間，大聲唸幾遍。
３    逛夜市或血拼(Shopping)時，試著默唸完整，當察覺思緒被眉美(帥哥)吸引或唸錯時，請從頭(Reset)開始再唸，看看自己那天才能一字不漏且不被打斷地唸完(260字而已，不難吧)。(專注靜心)
４    有空再深入了解四念住、十二因緣、止觀、淨土、禪宗…等修行法門。

後語
本文寫作目的，對象是對佛學有興趣但又不知如何入手，或以為佛學只有木魚槃聲，另一方面自己也作個整理，文中任何解譯引喻都是指月，所以白話譯文可能和原文有不一致的地方，讀者若要深入蠱狗一搜便一缸子不須我來多話了。最近坊間出了很多心經的書[7]有空去買來看。
讀經重要不是在解釋或讀懂，而是在實踐、在悟及如何在生活中體會，所以有別於以往解譯經文特加入方法一節。
有一說是觀世音對舍利弗說法，此處以世尊為主在突顯慈父角色。有點可惜若世間沒有宗教的藩籬，國文課的文選遊子吟便是它了。

發表於 空山靈語
      空山靈語
      http://spuggy0919.blogspot.com/p/blog-page.html

參考書目：
１    佛學講義 高觀如著 圓明出版社
２    Talking About Buddhism 高田佳人著 James M. Varadaman, Jr. 譯 講談社出版
３    佛學小辭點典 釋開心法師 倡印
４    光與物質小站
５    心經句解 施清文著
６    佛報恩網心經
７    般若波羅蜜多心經講錄  弘一大師著 戊寅三月講于溫陵大開元寺
８    粒子冒險奇境

"""
let Poempingyin = """

長(cháng) 信(xìn) 怨(yuàn) 王(wáng) 昌(chāng) 齡(líng)
奉(fèng) 帚(zhǒu) 平(píng) 明(míng) 金(jīn) 殿(diàn) 開(kāi)， 且(qiě) 將(jiāng) 團(tuán) 扇(shàn) 共(gòng) 徘(pái)徊(huái)。
玉(yù) 顏(yán) 不(bù) 及(jí) 寒(hán) 鴉(yā) 色(sè)， 猶(yóu) 帶(dài) 昭(zhāo) 陽(yáng) 日(rì) 影(yǐng) 來(lái)。

清(qīng) 平(píng) 調(diào) 三(sān) 首(shǒu) 之(zhī) 一(yī) 李(lǐ) 白(bái)
雲(yún) 想(xiǎng) 衣(yī) 裳(shang) 花(huā) 想(xiǎng) 容(róng)， 春(chūn) 風(fēng) 拂(fú) 檻(jiàn) 露(lù) 華(huá) 濃(nóng)。
若(ruò) 非(fēi) 群(qún) 玉(yù) 山(shān) 頭(tóu) 見(jiàn)， 會(huì) 向(xiàng) 瑤(yáo) 台(tái) 月(yuè) 下(xià) 逢(féng)。
清(qīng) 平(píng) 調(diào) 三(sān) 首(shǒu) 之(zhī) 二(èr) 李(lǐ) 白(bái)
一(yī) 枝(zhī) 紅(hóng) 艷(yàn) 露(lù) 凝(níng) 香(xiāng)， 雲(yún) 雨(yǔ) 巫(wū) 山(shān) 枉(wǎng) 斷(duàn) 腸(cháng)。
借(jiè) 問(wèn) 漢(hàn) 宮(gōng) 誰(shuí) 得(dé) 似(sì)？ 可(kě) 憐(lián) 飛(fēi) 燕(yàn) 倚(yǐ) 新(xīn) 妝(zhuāng)。
清(qīng) 平(píng) 調(diào) 三(sān) 首(shǒu) 之(zhī) 三(sān) 李(lǐ) 白(bái)
名(míng) 花(huā) 傾(qīng) 國(guó) 兩(liǎng) 相(xiāng) 歡(huān)，常(cháng) 得(dé) 君(jūn) 王(wáng) 帶(dài) 笑(xiào) 看(kàn)。
解(jiě) 釋(shì) 春(chūn) 風(fēng) 無(wú) 限(xiàn) 恨(hèn)， 沈(shěn) 香(xiāng) 亭(tíng) 北(běi) 倚(yǐ) 闌(lán) 干(gān)。


金(jīn) 縷(lǚ) 衣(yī) 杜(dù) 秋(qiū) 娘(niáng)
勸(quàn) 君(jūn) 莫(mò) 惜(xī) 金(jīn) 縷(lǚ) 衣(yī)， 勸(quàn) 君(jūn) 惜(xī) 取(qǔ) 少(shào) 年(nián)時(shí)。
花( huā) 開(kāi) 堪(kān) 折(zhé)直(zhí) 須(xū) 折(zhé)， 莫(mò) 待(dài) 無(wú) 花(huā) 空(kōng) 折(zhé) 枝(zhī)！

來源：https://twgreatdaily.com/B8SGxGwBJleJMoPMJttD.html
"""

let 蜀道難pingyin = """
詩名: 蜀 道 難
作者: 李 白 　　 詩體: 樂 府
詩文:
噫
yi1    吁
xu1    戲
hu1    （
左
口
右
戲
）
，
危
wei2    乎
hu1    高
gao1    哉
zai1    ，
蜀
shu3    道
dao4    之
zhi1    難
nan2    難
nan2    於
yu2    上
shang4    青
qing1    天
tian1    。
蠶
can2    叢
cong2    及
ji2    魚
yu2    鳧
fu2    ，
開
kai1    國
guo2    何
he2    茫
mang2    然
ran2    。
爾
er3    來
lai2    四
si4    萬
wan4    八
ba1    千
qian1    歲
sui4    ，
乃
shi3    與
yu3    秦
qin2    塞
sai4    通
tong1    人
ren2    煙
yan1    。
西
xi1    當
dang1    太
tai4    白
bo2    有
you3    鳥
niao3    道
dao4    ，
可
ke3    以
yi3    橫
heng2    絕
jue2    峨
e2    眉
mei2    巔
dian1    。
地
di4    崩
beng1    山
shan1    摧
cui1    壯
zhuang4    士
shi4    死
si3    ，
然
ran2    後
hou4    天
tian1    梯
ti1    石
shi2    棧
zhan4    方
xiang1    鉤
gou1    連
lian2    。
上
shang4    有
you3    六
lu4    龍
long2    回
hui2    日
ri4    之
zhi1    高
gao1    標
biao1    ，
下
xia4    有
you3    衝
chong1    波
bo1    逆
ni4    折
zhe2    之
zhi1    迴
hui2    川
chuan1    。
黃
huang2    鶴
he4    之
zhi1    飛
fei1    尚
shang4    不
bu4    得
de2    過
，
猿
yuan2    猱
nao2    欲
yu4    度
du4    愁
chou2    攀
pan1    緣
yuan2    。
青
qing1    泥
ni2    何
he2    盤
pan2    盤
pan2    ，
百
bo2    步
bu4    九
jiu3    折
zhe2    縈
ying2    巖
yan2    巒
luan2    。
捫
men2    參
can1    歷
li4    井
jing3    仰
yang3    脅
xie2    息
xi2    ，
以
yi3    手
shou3    撫
fu3    膺
ying1    坐
zuo4    長
chang2    歎
tan4    。
問
wen4    君
jun1    西
xi1    遊
you2    何
he2    時
shi2    還
huan2    ，
畏
wei4    途
tu2    巉
chan2    巖
yan2    不
bu4    可
ke3    攀
pan1    。
但
dan4    見
jian4    悲
bei1    鳥
niao3    號
hao2    古
gu3    木
mu4    ，
雄
xiong2    飛
fei1    從
ci2    雌
cong2    繞
rao4    林
lin2    間
jian1    。
又
you4    聞
wen2    子
zi3    規
gui1    啼
ti2    夜
ye4    月
yue4    ，
愁
chou2    空
kong1    山
shan1    。
蜀
shu3    道
dao4    之
zhi1    難
nan2    難
nan2    於
yu2    上
shang4    青
qing1    天
tian1    ，
使
shi3    人
ren2    聽
ting1    此
ci3    凋
diao1    朱
zhu1    顏
yan2    。
連
lian2    峰
feng1    去
qu4    天
tian1    不
bu4    盈
ying2    尺
chi3    ，
枯
ku1    松
song1    倒
dao4    挂
gua4    倚
yi3    絕
jue2    壁
bi4    。
飛
fei1    湍
tuan1    瀑
pu4    流
liu2    爭
zheng1    喧
xuan1    豗
hui1    ，
砯
ping1    崖
yai2    轉
zhuan3    石
shi2    萬
wan4    壑
huo4    雷
lei2    。
其
qi2    險
xian3    也
ye3    如
ru2    此
ci3    ，
嗟
jie1    爾
er3    遠
yuan3    道
dao4    之
zhi1    人
ren2    ，
胡
hu2    為
wei2    乎
hu1    來
lai2    哉
zai1    。
劍
jian4    閣
ge2    崢
zheng1    嶸
rong2    而
er2    崔
cui1    嵬
wei2    ，
一
yi1    夫
fu1    當
dang1    關
guan1    ，
萬
wan4    夫
fu1    莫
mo4    開
kai1    。
所
suo3    守
shou3    或
huo4    匪
fei3    親
qin1    ，
化
hua4    為
wei2    狼
lang2    與
yu3    豺
chai2    。
朝
zhao1    避
bi4    猛
meng3    虎
hu3    ，
夕
xi4    避
bi4    長
chang2    蛇
she2    。
磨
mo2    牙
ya2    吮
shun3    血
xie4    ，
殺
sha1    人
ren2    如
ru2    麻
ma2    。
錦
jin3    城
cheng2    雖
sui1    云
yun2    樂
le4    ，
不
bu4    如
ru2    早
zao3    還
huan2    家
jia1    。
蜀
shu3    道
dao4    之
zhi1    難
nan2    難
nan2    於
yu2    上
shang4    青
qing1    天
tian1    ，
側
ce4    身
shen1    西
xi1    望
wang4    長
chang2    咨
zi1    嗟
jie1    。
來源：http://cls.lib.ntu.edu.tw/300/ALL/ALLFRAME.htm

"""
let 蜀道難 = """
詩ㄕ名ㄇㄧㄥˊ: 蜀ㄕㄨˇ 道ㄉㄠˋ 難ㄋㄢˊ
作ㄗㄨㄛˋ者ㄓㄜˇ: 李ㄌㄧˇ 白ㄅㄞˊ 　　 詩ㄕ體ㄊㄧˇ: 樂ㄩㄝˋ 府ㄈㄨˇ
詩ㄕ文ㄨㄣˊ:
噫ㄧ吁ㄒㄩ    戲ㄏㄨ（左口右戲），
危ㄨㄟˊ乎ㄏㄨ高ㄍㄠ哉ㄗㄞ，
蜀
ㄕㄨˇ    道
ㄉㄠˋ    之
ㄓ    難
ㄋㄢˊ    難
ㄋㄢˊ    於
ㄩˊ    上
ㄕㄤˋ    青
ㄑㄧㄥ    天
ㄊㄧㄢ    。
蠶
ㄘㄢˊ    叢
ㄘㄨㄥˊ    及
ㄐㄧˊ    魚
ㄩˊ    鳧
ㄈㄨˊ    ，
開
ㄎㄞ    國
ㄍㄨㄛˊ    何
ㄏㄜˊ    茫
ㄇㄤˊ    然
ㄖㄢˊ    。
爾
ㄦˇ    來
ㄌㄞˊ    四
ㄙˋ    萬
ㄨㄢˋ    八
ㄅㄚ    千
ㄑㄧㄢ    歲
ㄙㄨㄟˋ    ，
乃
ㄕˇ    與
ㄩˇ    秦
ㄑㄧㄣˊ    塞
ㄙㄞˋ    通
ㄊㄨㄥ    人
ㄖㄣˊ    煙
ㄧㄢ    。
西
ㄒㄧ    當
ㄉㄤ    太
ㄊㄞˋ    白
ㄅㄛˊ    有
ㄧㄡˇ    鳥
ㄋㄧㄠˇ    道
ㄉㄠˋ    ，
可
ㄎㄜˇ    以
ㄧˇ    橫
ㄏㄥˊ    絕
ㄐㄩㄝˊ    峨
ㄜˊ    眉
ㄇㄟˊ    巔
ㄉㄧㄢ    。
地
ㄉㄧˋ    崩
ㄅㄥ    山
ㄕㄢ    摧
ㄘㄨㄟ    壯
ㄓㄨㄤˋ    士
ㄕˋ    死
ㄙˇ    ，
然
ㄖㄢˊ    後
ㄏㄡˋ    天
ㄊㄧㄢ    梯
ㄊㄧ    石
ㄕˊ    棧
ㄓㄢˋ    方
ㄒㄧㄤ    鉤
ㄍㄡ    連
ㄌㄧㄢˊ    。
上
ㄕㄤˋ    有
ㄧㄡˇ    六
ㄌㄨˋ    龍
ㄌㄨㄥˊ    回
ㄏㄨㄟˊ    日
ㄖˋ    之
ㄓ    高
ㄍㄠ    標
ㄅㄧㄠ    ，
下
ㄒㄧㄚˋ    有
ㄧㄡˇ    衝
ㄔㄨㄥ    波
ㄅㄛ    逆
ㄋㄧˋ    折
ㄓㄜˊ    之
ㄓ    迴
ㄏㄨㄟˊ    川
ㄔㄨㄢ    。
黃
ㄏㄨㄤˊ    鶴
ㄏㄜˋ    之
ㄓ    飛
ㄈㄟ    尚
ㄕㄤˋ    不
ㄅㄨˋ    得
ㄉㄜˊ    過
，
猿
ㄩㄢˊ    猱
ㄋㄠˊ    欲
ㄩˋ    度
ㄉㄨˋ    愁
ㄔㄡˊ    攀
ㄆㄢ    緣
ㄩㄢˊ    。
青
ㄑㄧㄥ    泥
ㄋㄧˊ    何
ㄏㄜˊ    盤
ㄆㄢˊ    盤
ㄆㄢˊ    ，
百
ㄅㄛˊ    步
ㄅㄨˋ    九
ㄐㄧㄡˇ    折
ㄓㄜˊ    縈
ㄧㄥˊ    巖
ㄧㄢˊ    巒
ㄌㄨㄢˊ    。
捫
ㄇㄣˊ    參
ㄘㄢ    歷
ㄌㄧˋ    井
ㄐㄧㄥˇ    仰
ㄧㄤˇ    脅
ㄒㄧㄝˊ    息
ㄒㄧˊ    ，
以
ㄧˇ    手
ㄕㄡˇ    撫
ㄈㄨˇ    膺
ㄧㄥ    坐
ㄗㄨㄛˋ    長
ㄔㄤˊ    歎
ㄊㄢˋ    。
問
ㄨㄣˋ    君
ㄐㄩㄣ    西
ㄒㄧ    遊
ㄧㄡˊ    何
ㄏㄜˊ    時
ㄕˊ    還
ㄏㄨㄢˊ    ，
畏
ㄨㄟˋ    途
ㄊㄨˊ    巉
ㄔㄢˊ    巖
ㄧㄢˊ    不
ㄅㄨˋ    可
ㄎㄜˇ    攀
ㄆㄢ    。
但
ㄉㄢˋ    見
ㄐㄧㄢˋ    悲
ㄅㄟ    鳥
ㄋㄧㄠˇ    號
ㄏㄠˊ    古
ㄍㄨˇ    木
ㄇㄨˋ    ，
雄
ㄒㄩㄥˊ    飛
ㄈㄟ    從
ㄘˊ    雌
ㄘㄨㄥˊ    繞
ㄖㄠˋ    林
ㄌㄧㄣˊ    間
ㄐㄧㄢ    。
又
ㄧㄡˋ    聞
ㄨㄣˊ    子
ㄗˇ    規
ㄍㄨㄟ    啼
ㄊㄧˊ    夜
ㄧㄝˋ    月
ㄩㄝˋ    ，
愁
ㄔㄡˊ    空
ㄎㄨㄥ    山
ㄕㄢ    。
蜀
ㄕㄨˇ    道
ㄉㄠˋ    之
ㄓ    難
ㄋㄢˊ    難
ㄋㄢˊ    於
ㄩˊ    上
ㄕㄤˋ    青
ㄑㄧㄥ    天
ㄊㄧㄢ    ，
使
ㄕˇ    人
ㄖㄣˊ    聽
ㄊㄧㄥ    此
ㄘˇ    凋
ㄉㄧㄠ    朱
ㄓㄨ    顏
ㄧㄢˊ    。
連
ㄌㄧㄢˊ    峰
ㄈㄥ    去
ㄑㄩˋ    天
ㄊㄧㄢ    不
ㄅㄨˋ    盈
ㄧㄥˊ    尺
ㄔˇ    ，
枯
ㄎㄨ    松
ㄙㄨㄥ    倒
ㄉㄠˋ    挂
ㄍㄨㄚˋ    倚
ㄧˇ    絕
ㄐㄩㄝˊ    壁
ㄅㄧˋ    。
飛
ㄈㄟ    湍
ㄊㄨㄢ    瀑
ㄆㄨˋ    流
ㄌㄧㄡˊ    爭
ㄓㄥ    喧
ㄒㄩㄢ    豗
ㄏㄨㄟ    ，
砯
ㄆㄧㄥ    崖
ㄧㄞˊ    轉
ㄓㄨㄢˇ    石
ㄕˊ    萬
ㄨㄢˋ    壑
ㄏㄨㄛˋ    雷
ㄌㄟˊ    。
其
ㄑㄧˊ    險
ㄒㄧㄢˇ    也
ㄧㄝˇ    如
ㄖㄨˊ    此
ㄘˇ    ，
嗟
ㄐㄧㄝ    爾
ㄦˇ    遠
ㄩㄢˇ    道
ㄉㄠˋ    之
ㄓ    人
ㄖㄣˊ    ，
胡
ㄏㄨˊ    為
ㄨㄟˊ    乎
ㄏㄨ    來
ㄌㄞˊ    哉
ㄗㄞ    。
劍
ㄐㄧㄢˋ    閣
ㄍㄜˊ    崢
ㄓㄥ    嶸
ㄖㄨㄥˊ    而
ㄦˊ    崔
ㄘㄨㄟ    嵬
ㄨㄟˊ    ，
一
ㄧ    夫
ㄈㄨ    當
ㄉㄤ    關
ㄍㄨㄢ    ，
萬
ㄨㄢˋ    夫
ㄈㄨ    莫
ㄇㄛˋ    開
ㄎㄞ    。
所
ㄙㄨㄛˇ    守
ㄕㄡˇ    或
ㄏㄨㄛˋ    匪
ㄈㄟˇ    親
ㄑㄧㄣ    ，
化
ㄏㄨㄚˋ    為
ㄨㄟˊ    狼
ㄌㄤˊ    與
ㄩˇ    豺
ㄔㄞˊ    。
朝
ㄓㄠ    避
ㄅㄧˋ    猛
ㄇㄥˇ    虎
ㄏㄨˇ    ，
夕
ㄒㄧˋ    避
ㄅㄧˋ    長
ㄔㄤˊ    蛇
ㄕㄜˊ    。
磨
ㄇㄛˊ    牙
ㄧㄚˊ    吮
ㄕㄨㄣˇ    血
ㄒㄧㄝˋ    ，
殺
ㄕㄚ    人
ㄖㄣˊ    如
ㄖㄨˊ    麻
ㄇㄚˊ    。
錦
ㄐㄧㄣˇ    城
ㄔㄥˊ    雖
ㄙㄨㄟ    云
ㄩㄣˊ    樂
ㄌㄜˋ    ，
不
ㄅㄨˋ    如
ㄖㄨˊ    早
ㄗㄠˇ    還
ㄏㄨㄢˊ    家
ㄐㄧㄚ    。
蜀
ㄕㄨˇ    道
ㄉㄠˋ    之
ㄓ    難
ㄋㄢˊ    難
ㄋㄢˊ    於
ㄩˊ    上
ㄕㄤˋ    青
ㄑㄧㄥ    天
ㄊㄧㄢ    ，
側
ㄘㄜˋ    身
ㄕㄣ    西
ㄒㄧ    望
ㄨㄤˋ    長
ㄔㄤˊ    咨
ㄗ    嗟
ㄐㄧㄝ    。
來源：http://cls.lib.ntu.edu.tw/300/ALL/ALLFRAME.htm

"""
let 心經注音1 = """
｜心《ㄒㄧㄣ》｜經《ㄐㄧㄥ》｜注《ㄓㄨˋ》｜音《ㄧㄣ》｜版《ㄅㄢˇ》
｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》｜心《ㄒㄧㄣ》｜經《ㄐㄧㄥ》　｜唐《ㄊㄤˊ》｜三《ㄙㄢ》｜藏《ㄗㄤˋ》｜法《ㄈㄚˇ》｜師《ㄕ》｜玄《ㄒㄩㄢˊ》｜奘《ㄗㄤ　ˋ》｜奉《ㄈㄥˋ》｜詔《ㄓㄠ》｜譯《ㄧˋ》
　｜觀《ㄍㄨㄢ》｜自《ㄗˋ》｜在《ㄗㄞˋ》｜菩《ㄆㄨˊ》｜薩《ㄙㄚˋ》　｜行《ㄒㄧㄥˊ》｜深《ㄕㄣ》｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》｜時《ㄕˊ》　｜照《ㄓㄠˋ》｜見《ㄐㄧㄢˋ》｜五《ㄨˇ》｜蘊《ㄩㄣˋ》｜皆《ㄐㄧㄝ》｜空《ㄎㄨㄥ》　｜度《ㄉㄨˋ》｜一《ㄧˊ》｜切《ㄑㄧㄝˋ》｜苦《ㄎㄨˇ》｜厄《ㄜˋ》
　｜舍《ㄕㄜˋ》｜利《ㄌㄧˋ》｜子《ㄗˇ》　｜色《ㄙㄜˋ》｜不《ㄅㄨˋ》｜異《ㄧˋ》｜空《ㄎㄨㄥ》　｜空《ㄎㄨㄥ》｜不《ㄅㄨˊ》｜異《ㄧˋ》｜色《ㄙㄜˋ》　｜色《ㄙㄜˋ》｜即《ㄐㄧˊ》｜是《ㄕˋ》｜空《ㄎㄨㄥ》　｜空《ㄎㄨㄥ》｜即《ㄐㄧˊ》｜是《ㄕˋ》｜色《ㄙㄜˋ》　｜受《ㄕㄡˋ》｜想《ㄒㄧㄤˇ》｜行《ㄒㄧㄥˊ》｜識《ㄕˋ》　｜亦《ㄧˋ》｜復《ㄈㄨˋ》｜如《ㄖㄨˊ》｜是《ㄕˋ》
　｜舍《ㄕㄜˋ》｜利《ㄌㄧˋ》｜子《ㄗˇ》　｜是《ㄕˋ》｜諸《ㄓㄨ》｜法《ㄈㄚˇ》｜空《ㄎㄨㄥ》｜相《ㄒㄧㄤˋ》　｜不《ㄅㄨˋ》｜生《ㄕㄥ》｜不《ㄅㄨˊ》｜滅　《ㄇㄧㄝˋ》｜不《ㄅㄨˋ》｜垢《ㄍㄡˋ》｜不《ㄅㄨˊ》｜淨　《ㄐㄧㄥˋ》｜不《ㄅㄨˋ》｜增《ㄗㄥ》｜不《ㄅㄨˋ》｜減《ㄐㄧㄢˇ》　｜是《ㄕˋ》｜故《ㄍㄨˋ》｜空《ㄎㄨㄥ》｜中《ㄓㄨㄥ》｜無《ㄨˊ》｜色《ㄙㄜˋ》　｜無《ㄨˊ》｜受《ㄕㄡˋ》｜想《ㄒㄧㄤˇ》｜行《ㄒㄧㄥˊ》｜識《ㄕˋ》　｜無《ㄨˊ》｜眼《ㄧㄢˇ》｜耳《ㄦˇ》｜鼻《ㄅㄧˊ》｜舌《ㄕㄜˊ》｜身《ㄕㄣ》｜意《ㄧˋ》　｜無《ㄨˊ》｜色《ㄙㄜˋ》｜聲《ㄕㄥ》｜香《ㄒㄧㄤ》｜味《ㄨㄟˋ》｜觸《ㄔㄨˋ》｜法《ㄈㄚˇ》　｜無《ㄨˊ》｜眼《ㄧㄢˇ》｜界《ㄐㄧㄝˋ》　｜乃《ㄋㄞˇ》｜至《ㄓˋ》｜無《ㄨˊ》｜意《ㄧˋ》｜識《ㄕˋ》｜界《ㄐㄧㄝˋ》　｜無《ㄨˊ》｜無《ㄨˊ》｜明《ㄇㄧㄥˊ》　｜亦《ㄧˋ》｜無《ㄨˊ》｜無《ㄨˊ》｜明《ㄇㄧㄥˊ》｜盡《ㄐㄧㄣˋ》　｜乃《ㄋㄞˇ》｜至《ㄓˋ》｜無《ㄨˊ》｜老《ㄌㄠˇ》｜死《ㄙˇ》　｜亦《ㄧˋ》｜無《ㄨˊ》｜老《ㄌㄠˇ》｜死《ㄙˇ》｜盡《ㄐㄧㄣˋ》　｜無《ㄨˊ》｜苦《ㄎㄨˇ》｜集《ㄐㄧˊ》｜滅《ㄇㄧㄝˋ》｜道《ㄉㄠˋ》　｜無《ㄨˊ》｜智《ㄓˋ》｜亦《ㄧˋ》｜無《ㄨˊ》｜得《ㄉㄜˊ》　｜以《ㄧˇ》｜無《ㄨˊ》｜所《ㄙㄨㄛˇ》｜得《ㄉㄜˊ》｜故《ㄍㄨˋ》
　｜菩《ㄆㄨˊ》｜提《ㄊㄧˊ》｜薩《ㄙㄚˋ》｜埵《ㄉㄨㄛˇ》　｜依《ㄧ》｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄆㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》｜故《ㄍㄨˋ》　｜心《ㄒㄧㄣ》｜無《ㄨˊ》｜罣《ㄍㄨㄚˋ》｜礙《ㄞˋ》　｜無《ㄨˊ》｜罣《ㄍㄨㄚˋ》｜礙《ㄞˋ》｜故《ㄍㄨˋ》　｜無《ㄨˊ》｜有《ㄧㄡˇ》｜恐《ㄎㄨㄥˇ》｜怖《ㄅㄨˋ》　｜遠《ㄩㄢˇ》｜離《ㄌㄧˊ》｜顛《ㄉㄧㄢ》｜倒《ㄉㄠˇ》｜夢《ㄇㄥˋ》｜想《ㄒㄧㄤˇ》　｜究《ㄐㄧㄡˋ》｜竟《ㄐㄧㄥˋ》｜涅《ㄋㄧㄝˋ》｜槃《ㄆㄢˊ》
　｜三《ㄙㄢ》｜世《ㄕˋ》｜諸《ㄓㄨ》｜佛《ㄈㄛˊ》　｜依《ㄧ》｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄆㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》｜故《ㄍㄨˋ》　｜得《ㄉㄛˊ》｜阿《ㄚ》｜耨《ㄋㄡˋ》｜多《ㄉㄨㄛ》｜羅《ㄌㄨㄛˊ》｜三《ㄙㄢ》｜藐《ㄇㄧㄠˇ》｜三《ㄙㄢ》｜菩《ㄆㄨˊ》｜提《ㄊㄧˊ》
　｜故《ㄍㄨˋ》｜知《ㄓ》｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》　｜是《ㄕˋ》｜大《ㄉㄚˋ》｜神《ㄕㄣˊ》｜咒《ㄓㄡˋ》　｜是《ㄕˋ》｜大《ㄉㄚˋ》｜明《ㄇㄧㄥˊ》｜咒《ㄓㄡˋ》　｜是《ㄕˋ》｜無《ㄨˊ》｜上《ㄕㄤˋ》｜咒《ㄓㄡˋ》　｜是《ㄕˋ》｜無《ㄨˊ》｜等《ㄉㄥˇ》｜等《ㄉㄥˇ》｜咒《ㄓㄡˋ》　｜能《ㄋㄥˊ》｜除《ㄔㄨˊ》｜一《ㄧˊ》｜切《ㄑㄧㄝˋ》｜苦《ㄎㄨˇ》　｜真《ㄓㄣ》｜實《ㄕˊ》｜不《ㄅㄨˋ》｜虛《ㄒㄩ》
　｜故《ㄍㄨˋ》｜說《ㄕㄨㄛ》｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》｜咒《ㄓㄡˋ》　｜即《ㄐㄧˊ》｜說《ㄕㄨㄛ》｜咒《ㄓㄡˋ》｜曰《ㄩㄝ》
　｜揭《ㄐㄧㄝ》｜諦《ㄉㄧˋ》｜揭《ㄐㄧㄝ》｜諦《ㄉㄧˋ》　｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜揭《ㄐㄧㄝ》｜諦《ㄉㄧˋ》　｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜僧《ㄙㄥ》｜揭《ㄐㄧㄝ》｜諦《ㄉㄧˋ》　｜菩《ㄆㄨˊ》｜提《ㄊㄧˊ》｜薩《ㄙㄚˋ》｜婆《ㄆㄨㄛˊ》｜訶《ㄏㄜ》
　｜摩《ㄇㄛˊ》｜訶《ㄏㄜ》｜般《ㄅㄛ》｜若《ㄖㄜˇ》｜波《ㄅㄛ》｜羅《ㄌㄨㄛˊ》｜蜜《ㄇㄧˋ》｜多《ㄉㄨㄛ》(｜三《ㄙㄢ》｜稱《ㄔㄥ》)

"""

let 李白將進酒="""
將ㄐㄧㄤ進ㄐㄧㄣˋ酒ㄐㄧㄡˇ
又ㄧㄡˋ作ㄗㄨㄛˋ《惜ㄒㄧˊ罇ㄗㄨㄣ空ㄎㄨㄥ》
作ㄗㄨㄛˋ者ㄓㄜˇ：李ㄌㄧˇ白ㄅㄞˊ　唐ㄊㄤˊ
君ㄐㄩㄣ不ㄅㄨˋ見ㄐㄧㄢˋ黃ㄏㄨㄤˊ河ㄏㄜˊ之ㄓ水ㄕㄨㄟˇ天ㄊㄧㄢ上ㄕㄤˋ來ㄌㄞˊ，奔ㄅㄣ流ㄌㄧㄡˊ到ㄉㄠˋ海ㄏㄞˇ不ㄅㄨˋ復ㄈㄨˋ回ㄏㄨㄟˊ。
君ㄐㄩㄣ不ㄅㄨˋ見ㄐㄧㄢˋ高ㄍㄠ堂ㄊㄤˊ明ㄇㄧㄥˊ鏡ㄐㄧㄥˋ悲ㄅㄟ白ㄅㄞˊ髮ㄈㄚˇ，朝ㄓㄠ如ㄖㄨˊ青ㄑㄧㄥ絲ㄙ暮ㄇㄨˋ成ㄔㄥˊ雪ㄒㄩㄝˇ。
人ㄖㄣˊ生ㄕㄥ得ㄉㄜˊ意ㄧˋ須ㄒㄩ盡ㄐㄧㄣˋ歡ㄏㄨㄢ，莫ㄇㄛˋ使ㄕˇ金ㄐㄧㄣ樽ㄗㄨㄣ空ㄎㄨㄥ對ㄉㄨㄟˋ月ㄩㄝˋ。
天ㄊㄧㄢ生ㄕㄥ我ㄨㄛˇ材ㄘㄞˊ必ㄅㄧˋ有ㄧㄡˇ用ㄩㄥˋ，千ㄑㄧㄢ金ㄐㄧㄣ散ㄙㄢˋ盡ㄐㄧㄣˋ還ㄏㄞˊ復ㄈㄨˋ來ㄌㄞˊ。
烹ㄆㄥ羊ㄧㄤˊ宰ㄗㄞˇ牛ㄋㄧㄡˊ且ㄑㄧㄝˇ爲ㄨㄟˊ樂ㄌㄜˋ，會ㄏㄨㄟˋ須ㄒㄩ一ㄧ飲ㄧㄣˇ三ㄙㄢ百ㄅㄞˇ杯ㄅㄟ。
岑ㄘㄣˊ夫ㄈㄨ子ㄗˇ，丹ㄉㄢ丘ㄑㄧㄡ生ㄕㄥ。將ㄐㄧㄤ進ㄐㄧㄣˋ酒ㄐㄧㄡˇ，杯ㄅㄟ莫ㄇㄛˋ停ㄊㄧㄥˊ。
與ㄩˇ君ㄐㄩㄣ歌ㄍㄜ一ㄧ曲ㄑㄩ，請ㄑㄧㄥˇ君ㄐㄩㄣ爲ㄨㄟˋ我ㄨㄛˇ側ㄘㄜˋ耳ㄦˇ聽ㄊㄧㄥ。
鐘ㄓㄨㄥ鼓ㄍㄨˇ饌ㄓㄨㄢˋ玉ㄩˋ不ㄅㄨˋ足ㄗㄨˊ貴ㄍㄨㄟˋ，但ㄉㄢˋ願ㄩㄢˋ長ㄔㄤˊ醉ㄗㄨㄟˋ不ㄅㄨˋ願ㄩㄢˋ醒ㄒㄧㄥˇ。
古ㄍㄨˇ來ㄌㄞˊ聖ㄕㄥˋ賢ㄒㄧㄢˊ皆ㄐㄧㄝ寂ㄐㄧˊ寞ㄇㄛˋ，惟ㄨㄟˊ有ㄧㄡˇ飲ㄧㄣˇ者ㄓㄜˇ留ㄌㄧㄡˊ其ㄑㄧˊ名ㄇㄧㄥˊ。
陳ㄔㄣˊ王ㄨㄤˊ昔ㄒㄧˊ時ㄕˊ宴ㄧㄢˋ平ㄆㄧㄥˊ樂ㄌㄜˋ，斗ㄉㄡˋ酒ㄐㄧㄡˇ十ㄕˊ千ㄑㄧㄢ恣ㄗˋ歡ㄏㄨㄢ謔ㄒㄩㄝˋ。
主ㄓㄨˇ人ㄖㄣˊ何ㄏㄜˊ為ㄨㄟˋ言ㄧㄢˊ少ㄕㄠˇ錢ㄑㄧㄢˊ？徑ㄐㄧㄥˋ須ㄒㄩ沽ㄍㄨ取ㄑㄩˇ對ㄉㄨㄟˋ君ㄐㄩㄣ酌ㄓㄨㄛˊ。
五ㄨˇ花ㄏㄨㄚ馬ㄇㄚˇ，千ㄑㄧㄢ金ㄐㄧㄣ裘ㄑㄧㄡˊ。呼ㄏㄨ兒ㄦˊ將ㄐㄧㄤ出ㄔㄨ換ㄏㄨㄢˋ美ㄇㄟˇ酒ㄐㄧㄡˇ，與ㄩˇ爾ㄦˇ同ㄊㄨㄥˊ銷ㄒㄧㄠ萬ㄨㄢˋ古ㄍㄨˇ愁ㄔㄡˊ。
"""

