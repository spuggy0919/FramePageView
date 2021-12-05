//
//  DrawPageView.swift
//  CoreTextExample
//
//  Created by Lin Hess on 2021/10/17.
//
// ref:https://stackoverflow.com/questions/25994057/ruby-text-furigana-in-ios
import Foundation
import CoreText
import SwiftUI
import UIKit



/**
 FramePageView : Accept PlainText String or NSAttributeString to draw on UIVIEW with color.clear backgroud
                it also support vertical form
 FramePageView(inputStr: String, isUpdate: $isUpdate, pagecount: $pageCount, settings:FramePageSettings)
 @Parameter: inputStr String for render on UIView, it will be convert to NSAttributedString with Settings attribute
 @Parameter: isUpdate  true will trigger  FramePage to update,
 @Parameter: pageCount  When Input String is Draw on Frame, then the page count will return
 @Parameter: Settings: FramePageSettings  for Parser to setup attribute on String
 
   example
 
        @State private var isUpdate = false
        @State private var pageCount =  0
        @State private var settings : FramePageSettings =   FramePageSettings()
        Setting.fontSize = 28
        Setting.verticalForm = true
        Setting.layoutFlag = .reLayout // Setting Change, the layout to be drawed
        FramePageView(inputStr: "君不見黃河之水天上來，奔流到海不復回。", isUpdate: $isUpdate, pagecount: $pageCount, settings:FramePageSettings)
 
    //1. UIViewControllerRepresentable
struct ViewControllerWrap:UIViewControllerRepresentable {
    
    //2. Binaing Variable if have argument for viewcontroller
  //  @Binding var text:String
    //3
    func makeUIViewController(context: Context) ->  ViewController {
        ViewController()
    }
    //4
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //5 update realtime argument
           //  uiViewController.labelText.text = text
    }
}
*/



var pageuiview:FramePage? = nil
struct FramePageView:UIViewRepresentable {
    typealias UIViewType = FramePage
    
    let inputStr:String // -Parameter Input String
    @Binding var isUpdate:Bool   // -Parameter for Updadte view
    @Binding var pagecount:Int //POD
    let settings:FramePageSettings
    
    var uiview: UIView? = nil
    var _id:String = "FramePageView"


    

    
    func makeCoordinator() -> Coordinator {
        Coordinator( self )
    }
    //2. Binaing Variable if have argument for viewcontroller
  //  @Binding var text:String
    //3
    func makeUIView(context: Context) ->  FramePage {
     //   print("\(Context.frame())")
        let uiview =  FramePage()//
        context.coordinator.uiview = uiview
        // set hostcontroller to .clear
//        ref https://stackoverflow.com/questions/63745084/how-can-i-make-a-background-color-with-opacity-on-a-sheet-view/63745596#63745596
        DispatchQueue.main.async {
            if let parentvc = uiview.superview {
            if let hostvc = parentvc.superview {
                parentvc.isOpaque = false
                parentvc.backgroundColor?.withAlphaComponent(0.5)
                parentvc.backgroundColor = .clear
                uiview.isOpaque = false
                hostvc.backgroundColor?.withAlphaComponent(0.5)
                uiview.backgroundColor = .clear
            }
            }
        }
        uiview.delegate = context.coordinator
        pageuiview = uiview
        settings.inputString = inputStr
        uiview.makePageSettings(settings: settings)
        if (settings.layoutFlag == .attrStringInput) {
            uiview.makePageInputAttributedString(attstr: settings.nsAttrString)
        }else{
            uiview.makePageInputString(text: inputStr)
        }
 //       print("FramePageView \(inputStr)")
        settings.layoutFlag = .layoutDone //reset current state in parent
        return uiview
    }
    //4
    func updateUIView(_ uiView: FramePage, context: Context) {
        //5 update realtime argument
           //  uiViewController.labelText.text = text
           
           if (isUpdate){
            DispatchQueue.main.async {
                var reflesh = false
                  isUpdate = false
                  print("Update\(settings.layoutFlag)")
//                  print("Update\(settings.fontname)")
                if (settings.layoutFlag == .attrStringInput  || settings.layoutFlag == .inputChange || settings.layoutFlag == .reLayout){
                    uiView.makePageSettings(settings: settings)
                  // input done in setttings
                  //  attributeString = bopomofo(text: settings.inputString)
                    if (settings.layoutFlag == .inputChange) {
                        uiView.makePageInputString(text: inputStr)
                    }else{
                        uiView.makePageInputAttributedString(attstr: settings.nsAttrString)
                    }
                    settings.layoutFlag = .layoutDone
                    reflesh = true
                }
                
                if (settings.layoutFlag == .colorChange ){
                    uiView.makePageSettings(settings: settings)
                    settings.layoutFlag = .layoutDone
                    reflesh = true
                }

                if (settings.layoutFlag == .pageChange){
                    _ = uiView.makePageGoto(pageidx: settings.pageCur)
                    settings.layoutFlag = .layoutDone
                    reflesh = true
                }
//                        print("updateUIView\(settings.inputString )")
                if (reflesh) {
                    uiView.setNeedsDisplay()
                }
              //  _ = context.coordinator.getParaFromFramePage(sender: uiView)
            } //DispatchQueue
            //      isUpdate = FramePageView.pNeedUpdateChange()
           }
      //  }
     //   pageuiview?.setNeedsDisplay()
      //  print("count:\(count)cur:\(cur)")
    }
    class Coordinator:NSObject, FramePageDelegate {
        var framepageview: FramePageView
        @Binding var isUpdate:Bool   // -Parameter for Updadte view
        @Binding var pagecount:Int //POD
        @State var settings:FramePageSettings
        @State var abort:Bool = false

        var uiview: FramePage?
     //   var delegate : FramePageDelegate? = nil
        init(_ fpview:FramePageView){
            self.framepageview = fpview
            self._isUpdate = fpview.$isUpdate
            self._pagecount = fpview.$pagecount
            self.settings = fpview.settings
        }
        
        init(_ fpview:FramePageView, isUpdate:Binding<Bool>, pagecount:Binding<Int>, settings:FramePageSettings){
            self.framepageview = fpview
            self._isUpdate = isUpdate
            self._pagecount = pagecount
            self.settings = settings
        }
        func getParaFromFramePage(sender: FramePage)->Bool{
         //   framepageview.delegate = sender
            framepageview.isUpdate = (sender.layoutFlag == .reLayout || sender.layoutFlag == .pageChange)

            return true
        }
        func onLayouting(sender: FramePage, layout:Bool){
         //   framepageview.delegate = sender
        //    if (layout) {
            var pagecnt = sender.cfrange.count
            if (pagecnt == 1 &&  sender.cfrange[0].length == 0) {pagecnt = 0}
            self.pagecount = pagecnt
            framepageview.pagecount = pagecnt
       //     }
        }
        func onLayoutAbort()->Bool{
            let abortF = abort
            if (abortF) {
                abort = false
            }
          //  return abortF
            return false
        }
        func onDidLayoutComplete(sender: FramePage, pagecnt:Int){
            framepageview.pagecount = pagecnt
        }
        func onDidPageComplete(sender: FramePage, pagecur:Int){
               // self.settings.pageCur = pagecur
        }
    }
    func bopomofo(text: String)->NSAttributedString{
        let bopomofoPaser = Bopomofo(text: text, settings: self.settings)
        return bopomofoPaser.bopomofo(text: text)
    }
    // Page number functions
    static func pPageCount()-> Int{
        if let uv = pageuiview {
         return uv.makePagegGetPageCounts()
        }
        return 0
    }
}
 
protocol FramePageDelegate {
    func onLayouting(sender: FramePage, layout:Bool)->Void
    func onLayoutAbort()->Bool
    func onDidLayoutComplete(sender: FramePage,pagecnt:Int)->Void // return PageCount
    func onDidPageComplete(sender: FramePage, pagecur: Int)->Void   // return PageCur
}

class FramePage:UIView{
    var id:String = "FramePage"
    var layoutFlag: LayoutCheck = .reLayout
    var verticalform: Bool = true

    var inputText:String = ""
    var attributeString:NSAttributedString = NSAttributedString(string:"")

//  var pageCount:Int=cfrange,count
    var cfrange:[CFRange] = [] // the astr for each frame
    var curpage = 0
    

//  Draw Frame
    var drawrect:CGRect = CGRect.zero // UIView Size after CGTransform
    var drawinset:CGFloat = 0.0 // UIView Size after CGTransform
    var drawpath:CGPath = CGPath(rect:CGRect(x: 0,y: 0,width: 10,height: 10),transform: nil)
    
// delagate, suppose to be notified layoutDone
    var delegate:FramePageDelegate?
    
    // debug Draw
    var debugDrawFrameFlag:Bool = true

// Settings for Parser
    var settings:FramePageSettings? = nil
    


    
    func makePageInputString(text:String){
        if (text != ""){
            attributeString = bopomofo(text: text)
            layoutFlag = .reLayout // relayout to count pages
         //--  isNeedsDisplay = true
            _ = makePagecfrange()
        }
    }

    func makePageInputAttributedString(attstr:NSAttributedString){
        attributeString = attstr
        layoutFlag = .reLayout // relayout to count pages
        //--  isNeedsDisplay = true
        _ = makePagecfrange()

    }

    func InternalmakePageInputStringWithParser(text:String, fromparser:(String)->NSAttributedString){
        attributeString = fromparser(text)
        layoutFlag = .reLayout // relayout to count pages
        //--  isNeedsDisplay = true
        _ = makePagecfrange()
    }
    func makePageSettings(settings:FramePageSettings)  {
        self.settings = settings

        layoutFlag = settings.layoutFlag
        verticalform = settings.verticalform

        
        debugDrawFrameFlag = settings.debugDrawFrameFlag
        drawrect     = self.frame

        inputText = settings.inputString
        curpage = settings.pageCur - 1 // internal index from 0...pageCount-1
        if (layoutFlag == .inputChange || layoutFlag == .reLayout || layoutFlag == .colorChange) {
            if (layoutFlag == .inputChange || layoutFlag == .colorChange) {
               // attributeString = bopomofo(text: inputText) move to up level
                // call bopomofo Paser to convert to NSAttributedString
            }
            if (layoutFlag != .inputChange) {
                layoutFlag = .reLayout
                _ = makePagecfrange() //done by Input
            }
        }
    }

    
    func makePagegGetPageCounts() -> Int {
            return cfrange.count
    }
    func makePageCurrent()->Int{
        _ = makePageByIndex(index:curpage)
        //--   isNeedsDisplay = true // user request force to refresh
        return curpage + 1 // page num from 1 to cfrange.count
   }
    func makePageNext()->Int{
        if (curpage+1 > cfrange.count || cfrange.count == 0){
            return curpage + 1
        }
        _ = makePageByIndex(index:curpage + 1)
        return curpage + 1 // page num from 1 to cfrange.count
    }
    func makePagePrev()->Int{
        if (curpage-1 < 0 || cfrange.count == 0){
            curpage = 0
            return curpage + 1
        }
        _ = makePageByIndex(index:curpage-1)
        return curpage + 1 // page num from 1 to cfrange.count

    }
    func makePageGoto(pageidx:Int)->Int{
        let page = pageidx-1
        if (page < 0 || page >= cfrange.count || cfrange.count == 0){
            return curpage + 1 // out of range no change
        }
        _ = makePageByIndex(index:page)
        return curpage + 1 // page num from 1 to cfrange.count

    }
    func makePagecfrange() -> Int {
        if (layoutFlag == .reLayout) {
            if (frame.size == CGSize.zero) {
                return 0
            }
            
     //       _ = ContentCFRages(rect: frame,attstr:attributeString)
            _ = self.pagingRanges1(rect: frame,attrString:self.attributeString)
        }
        return cfrange.count
    }
    // internal function
    func makePageByIndex(index:Int) -> Int {
      //  if (cfrange.count == 0){
        var nindex = index
        if (nindex >= cfrange.count) {
            nindex = cfrange.count - 1
        }
        if (nindex < cfrange.count) {
            let aMString = NSMutableAttributedString(attributedString:attributeString)
            
        let aString =  aMString.attributedSubstring(from:NSMakeRange( cfrange[nindex].location,cfrange[nindex].length)) //as! NSAttributedString
            //--            if (curpage != nindex) { isNeedsDisplay = true}
            curpage = nindex
            _ = drawPageWithTransform(rect: drawrect,attstr:aString)
            return curpage+1
        }
        return 0
    }
    
    // ruby parser move out
    func bopomofo(text: String)->NSAttributedString{
        let bopomofoPaser = Bopomofo(text: text, settings: self.settings!)
        return bopomofoPaser.bopomofo(text: text)
    }



    // Bug when font size change the pagecur will out of order
    
    // draw functions parameters
    // Rect: draw frame
    // verticalform : flag for vertical horizontal
    // drawpath for layout path
    // nsattributeString for layout
    // cfrange range of each page
    // pagecur current page
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let attstr = attributeString

        
        var aString = NSMutableAttributedString(attributedString: attstr)

        if (layoutFlag == .reLayout || layoutFlag == .inputChange) {
            if let delegator =  self.delegate {
                delegator.onLayouting(sender: self, layout: true)
            }

            if (layoutFlag == .reLayout || layoutFlag == .inputChange) {
                _ = self.pagingRanges1(rect: rect,attrString:self.attributeString)

                self.layoutFlag = .layoutDone
                if let delegator =  self.delegate {
                    delegator.onLayouting(sender: self, layout: false)
                    delegator.onDidLayoutComplete(sender: self, pagecnt: self.cfrange.count)
                }
            }

            
        }

        
        if (cfrange.count != 0 ){
            if (curpage < 0) {
                curpage =  0
            }
            if (curpage >= cfrange.count) {curpage =  cfrange.count-1}
            if (cfrange.count != 0) {
                if (aString.length > cfrange[curpage].length) {
                aString =  aString.attributedSubstring(from: NSMakeRange(cfrange[curpage].location,cfrange[curpage].length)) as! NSMutableAttributedString
                }

                _ = drawPageWithTransform(rect: rect,attstr:aString)
            }
        }
        if let delegator =  self.delegate {
            delegator.onDidPageComplete(sender: self, pagecur: curpage)
        }
    }

    func pagingRanges1(rect:CGRect, attrString:NSAttributedString) -> Bool {
        let rectpath = drawLayoutFrame(rect:rect)
        
            cfrange = []
            let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
            // Screen display area
          //  let path = CGPath(rect: rect, transform: nil)
            var range = CFRangeMake(0, 0)
            var rangeOffset = 0
        
            repeat{
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(rangeOffset, 0), rectpath, nil)
                range = CTFrameGetVisibleStringRange(frame)
                cfrange.append(CFRange(location:rangeOffset, length:range.length))
                print("\(cfrange.count):drawframe range\(range)")
                rangeOffset += range.length
                if let delegator =  self.delegate {
                  //  delegator.onLayouting(sender: self, layout: true)
//                    delegator.onDidLayoutComplete(sender: self, pagecnt: cfrange.count)
                    if (delegator.onLayoutAbort()){
                        break
                    }
                }
            }while(rangeOffset < attrString.length)
            if let delegator =  self.delegate {
                delegator.onLayouting(sender: self, layout: false)
                delegator.onDidLayoutComplete(sender: self, pagecnt: cfrange.count)
                layoutFlag = .layoutDone
            }
            return cfrange.count != 0
    }

    func pagingRanges(rect:CGRect, attrString:NSAttributedString) -> Bool {
            cfrange = []

            let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
            // Screen display area
          //  let path = CGPath(rect: rect, transform: nil)
            var range = CFRangeMake(0, 0)
            var rangeOffset = 0
        let render = UIGraphicsImageRenderer(size:rect.size)
        _ = render.image { ctx in
            let context = ctx.cgContext
            _ = PSetTransBeforeDraw(context:context ,rect:rect,verticalflag:verticalform)
            repeat{
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(rangeOffset, 0), drawpath, nil)
                range = CTFrameGetVisibleStringRange(frame)
                cfrange.append(CFRange(location:rangeOffset, length:range.length))
                print("\(cfrange.count):drawframe range\(range)")
                rangeOffset += range.length
                if let delegator =  self.delegate {
                  //  delegator.onLayouting(sender: self, layout: true)
//                    delegator.onDidLayoutComplete(sender: self, pagecnt: cfrange.count)
                    if (delegator.onLayoutAbort()){
                        break
                    }
                }
            }while(rangeOffset < attrString.length)
        if let delegator =  self.delegate {
            delegator.onLayouting(sender: self, layout: false)
            delegator.onDidLayoutComplete(sender: self, pagecnt: cfrange.count)
        }
            _ = PSetTransAfterDraw(context:context ,rect:rect,verticalflag:verticalform)
        }
            return cfrange.count != 0
    }

    func ContentCFRages(rect:CGRect,attstr:NSAttributedString)-> Bool{
        if (rect == CGRect.zero) {return false}

        var aString = NSMutableAttributedString(attributedString: attstr)
        var len = attstr.length
        var loc = 0
        cfrange = []
        let render = UIGraphicsImageRenderer(size:rect.size)
        _ = render.image { ctx in
            let context = ctx.cgContext
            _ = PSetTransBeforeDraw(context:context ,rect:rect,verticalflag:verticalform)
            while  len  > 0 {
                let range = draw_PWidthoutTrans(context:context ,attstr:NSAttributedString(attributedString:aString))
                loc += range.length
                len -= range.length
                print("\(cfrange.count):drawframe range\(range)")
                if (len >= 0 && range.length>0) {
                    cfrange.append(CFRange(location: loc-range.length, length: range.length))
                    aString =  aString.attributedSubstring(from: NSMakeRange(range.length,len)) as! NSMutableAttributedString
                }else{
                    break
                }
                if let delegator =  self.delegate {
                  //  delegator.onLayouting(sender: self, layout: true)
//                    delegator.onDidLayoutComplete(sender: self, pagecnt: cfrange.count)
                    if (delegator.onLayoutAbort()){
                        break
                    }
                }
            }
            if let delegator =  self.delegate {
                delegator.onLayouting(sender: self, layout: false)
                delegator.onDidLayoutComplete(sender: self, pagecnt: cfrange.count)
            }
            _ = PSetTransAfterDraw(context:context ,rect:rect,verticalflag:verticalform)
        }
        return cfrange.count != 0
    }
func drawCoordinateSystem(_ context:CGContext){
    /* Set the width for the line */
    context.setLineWidth(5.0)
    /* Set the color that we want to use to draw the line */
    UIColor.red.set()
    /* Start the line at this point */
    context.move(to: CGPoint(x: 0.0,y: 0.0))
    /* And end it at this point */
    context.addLine(to: CGPoint(x: 50.0,y: 0.0))
    /* Use the context's current color to draw the line */
    context.strokePath()
    /* Set the color that we want to use to draw the line */
    UIColor.blue.set()
    /* Start the line at this point */
    context.move(to: CGPoint(x: 0.0,y: 0.0))
    /* And end it at this point */
    context.addLine(to: CGPoint(x: 0.0,y: 50.0))
    /* Use the context's current color to draw the line */
    context.strokePath()
}
func insetRect(_ rect: CGRect)->CGRect{
    var rectt = rect
    if (verticalform){
        rectt.origin.x = rectt.origin.x //+ drawinset //+ topSafeArea
        rectt.origin.y = rectt.origin.y  //+ drawinset
        rectt.size.width = rectt.size.width //- drawinset *  2 //- topSafeArea - bottomSafeArea
        rectt.size.height = rectt.size.height //- drawinset * 2
    }else{
        rectt.origin.x = rectt.origin.x //+ drawinset
        rectt.origin.y = rectt.origin.y //+ drawinset // + bottomSafeArea
        rectt.size.width = rectt.size.width //- drawinset *  2
        rectt.size.height = rectt.size.height //- drawinset * 2  //- topSafeArea - bottomSafeArea

    }
    return rectt
}
func drawLayoutFrame(rect:CGRect) ->CGPath{
    var rectm:CGRect = rect
    let  t = rectm.size.width
    rectm.size.width = rectm.size.height
    rectm.size.height = t
    drawrect = insetRect(verticalform ? rectm : rect)

    drawpath = CGPath(rect: drawrect,  transform: nil) //originalrect
    return drawpath
}
func PSetTransBeforeDraw(context:CGContext,rect:CGRect,verticalflag:Bool)->CGRect{
        UIGraphicsPushContext(context) // save

    drawpath = drawLayoutFrame(rect:rect)


    if (verticalform) {
        // transform matrix
          //  drawrect.size.width = +1.0 * drawrect.size.width
            context.scaleBy(x: 1, y: -1)
            context.rotate(by: -.pi/2 )
            context.translateBy(x:  0.0 * rect.height,
                                 y:  0.0)

        }else {
       //     drawrect.size.height =   1.0 * drawrect.size.height
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x:  0.0 * rect.height,
                                 y:  -1.0 * rect.height)
         }
    if (debugDrawFrameFlag) {
        drawCoordinateSystem(context)
    }

 
        
        return  drawrect
    }
    func PSetTransAfterDraw(context:CGContext,rect:CGRect,verticalflag:Bool)->CGRect{

    
        if (verticalform) {
            context.translateBy(x:  0.0 * rect.height,
                                y:  0.0 * rect.height)
            context.rotate(by: +.pi/2 )
            context.scaleBy(x: 1, y: -1)

        } else {

            context.translateBy(x:  0.0 * rect.height,
                                 y:  +1.0 * rect.height)
            context.scaleBy(x: 1, y: -1)
        }

        UIGraphicsPopContext()
        return  drawrect
    }
func draw_PWithTrans(context:CGContext,rect:CGRect,attstr:NSAttributedString)-> CFRange{
    drawrect = PSetTransBeforeDraw(context:context,rect: rect, verticalflag: verticalform)

        let range = draw_PWidthoutTrans(context:context,attstr:attstr)
      // if possible  context.CGAffineTransform.identity
        _ = PSetTransAfterDraw(context:context,rect:rect,verticalflag:verticalform)


        return range
        
    }// draw_Horizontal
    func draw_PWidthoutTrans(context:CGContext,attstr:NSAttributedString)-> CFRange{

        // set coretext layout
        let framesetter = CTFramesetterCreateWithAttributedString(attstr)

        let frame = CTFramesetterCreateFrame(framesetter, CFRange(), drawpath  , nil)
        let range = CTFrameGetVisibleStringRange(frame)
      //  CTFrameDraw(frame, context) get range don't need to draw
        return range
        
    }
    
// original context of UIView
    func PageSetTransformBeforeDraw(rect:CGRect,verticalflag:Bool)->CGRect{
       
           guard let context = UIGraphicsGetCurrentContext() else {
           return CGRect.zero
       }
       UIGraphicsPushContext(context) // save

        drawpath = drawLayoutFrame(rect:rect)

        if (verticalform) {
       // transform matrix
         //  drawrect.size.width = +1.0 * drawrect.size.width
           context.scaleBy(x: 1, y: -1)
           context.rotate(by: -.pi/2 )
           context.translateBy(x:  0.0 * rect.height,
                                y:  0.0)

       }else {
      //     drawrect.size.height =   1.0 * drawrect.size.height
           context.scaleBy(x: 1, y: -1)
           context.translateBy(x:  0.0 * rect.height,
                                y:  -1.0 * rect.height)
        }
        if (debugDrawFrameFlag) {
            drawCoordinateSystem(context)
        }
//       let rectpath = CGPath(rect:CGRect(x: 150,y: 100,width: 100,height: 100),transform: nil)
//       let inverted = UIBezierPath(rect: CGRect(origin: CGPoint(x: 0,y: fontSize/2), size: CGSize(width: (drawrect.width ), height: drawrect.height - fontSize/2)))
//       inverted.append(UIBezierPath(cgPath: rectpath).reversing())
       drawpath = CGPath(rect: drawrect,  transform: nil) //originalrect
        if (debugDrawFrameFlag) {
            let inset = drawinset
            drawinset = 5
            drawpath = drawLayoutFrame(rect:rect)
            context.addPath(drawpath)
            context.setStrokeColor((UIColor.blue).cgColor)
            context.setLineWidth(1.0)
            context.strokePath()
            drawinset = inset
            drawpath = drawLayoutFrame(rect:rect)
            context.addPath(drawpath)
            context.setStrokeColor((UIColor.red).cgColor)
            context.strokePath()
        }
     //  drawpath = inverted.cgPath

       
       return  drawrect
   }
   func PageSetTransformAfterDraw(rect:CGRect,verticalflag:Bool)->CGRect{
       guard let context = UIGraphicsGetCurrentContext() else {
           return CGRect.zero
       }
       // check bound fill view background
//       var rectm:CGRect = rect
//       let  t = rectm.size.width
//       rectm.size.width = rectm.size.height
//       rectm.size.height = t
    //   drawrect = insetRect(verticalform ? rectm : rect)


       if (verticalform) {
           context.translateBy(x:  0.0 * rect.height,
                               y:  0.0 * rect.height)
           context.rotate(by: +.pi/2 )
           context.scaleBy(x: 1, y: -1)
       // transform matrix
       } else {
//            context.translateBy(x:  (verticalform) ? 0.0: 1.0 * drawrect.width,
//                                y:  1.0 * drawrect.height)
//            context.scaleBy(x: 1, y: -1)
//            // transform matrix
//            context.rotate(by: .pi / 2)
           context.translateBy(x:  0.0 * rect.height,
                                y:  +1.0 * rect.height)
           context.scaleBy(x: 1, y: -1)
//            context.translateBy(x:   -0.5 * rect.width,
//                                y:  -0.5 * rect.height)
//
       }

       UIGraphicsPopContext()
       return  drawrect
   }
   func drawPageWithTransform(rect:CGRect,attstr:NSAttributedString)-> CFRange{
       drawrect = PageSetTransformBeforeDraw(rect: rect, verticalflag: verticalform)

       let range = draw_PageWidthoutTransform(attstr:attstr)
     // if possible  context.CGAffineTransform.identity
       _ = PageSetTransformAfterDraw(rect:rect,verticalflag:verticalform)


       return range
       
   }// draw_Horizontal
   func draw_PageWidthoutTransform(attstr:NSAttributedString)-> CFRange{
       guard let context = UIGraphicsGetCurrentContext() else {
           return CFRange(location: 0, length: 0)
       }
       // set coretext layout
       let framesetter = CTFramesetterCreateWithAttributedString(attstr)

    let frame = CTFramesetterCreateFrame(framesetter, CFRange(), drawpath  , nil)
       let range = CTFrameGetVisibleStringRange(frame)
       CTFrameDraw(frame, context)
       return range
       
   }
}

