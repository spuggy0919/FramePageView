//
//  ContentView.swift
//  VTxtRuby
//
//  Created by spuggy0919@gmail.com on 2021/12/5.
//

import SwiftUI

struct ContentView: View {

    @State private var isUpdate = false
    @State private var pageCount:Int  = 0
    @State private var fontSize:CGFloat  = 30
    @State var pageCur:Int = 1

    
    @StateObject var  gestureState:GestureState =  GestureState()
    
    //Wheel Picker
    @State var pickerShow:Bool = true
    @State var selection:Int = 0
    
    @ObservedObject private var Settings = FramePageSettings()

    let sw = UIScreen.main.bounds.width
    let sh = UIScreen.main.bounds.height

    var body: some View {
        GeometryReader { geometry in
        ZStack{

            Form{

                Picker("TXT Samples", selection: $selection) {
                    ForEach(0..<txtSamples.count, id: \.self) { select in
                        Text(txtSamples[select].description)
                    }
                }.pickerStyle(WheelPickerStyle())
                .onTapGesture {
                    pickerShow.toggle() // swip up to show picker
                    // new selection
                    Settings.inputString = txtSamples[selection].text
                    settingPageView(false, .inputChange)
                }
            } // form
            .background(Color.gray)
            .zIndex( (pickerShow) ? 1 : -2)
            .offset(y: sh/2 )
            
            // Page Background View, maybe Image
            Color.init(Settings.pagebrcolor)
                .frame(width:sw, height:sh)
                .edgesIgnoringSafeArea(.all)
                .zIndex(-1)
            
            // Page View 
            FramePageView(inputStr: txtSamples[selection].text, isUpdate: $isUpdate, pagecount: $pageCount, settings:Settings)
             .padding(20) // padding should before frame
             .frame(width:sw, height: geometry.frame(in: .local).size.height - Settings.topSafeArea - Settings.bottomSafeArea)
             .background(Color.clear)
                 .zIndex(0)
             .onSwiped(gestureState, perform:swipedAction) //add drag will impact the scroll
             .onTapped(gestureState) //add drag will impact the scroll
            
        } // ZStack
        } // GeometryReader
    } // body
    
    // for  gesture action
    func swipedAction()->Void {
        switch gestureState.gestureType() {
        case .left:
            VPagePrev()
        case .right:
            VPageNext()
        case .down:
            break
        case .up:
            pickerShow.toggle()
            break
        case .edgeRight:  do {
            break

        }         // swip from left side
        case .edgeLeft: do {
          //  hiddenCurView = true
            break

         // swip from right side
        }
        default:
            break

        }
        tappedAction()
        gestureState.reset()
    }

    
    func tappedAction() {
    //    return
        if (gestureState.gestureType() == .tapped) {
           switch gestureState.positionIndex() {
            case 1: VPageNext()
            case 2: do {
                fontSize += 5
                if (fontSize > 80) {fontSize = 80}
                settingPageView(false,.reLayout)
                break
            }
            case 3: VPagePrev()
            case 4: VPageNext()
            case 5:do{
                Settings.verticalform.toggle()
                settingPageView(false,.reLayout)
                break

            }
            case 6: VPagePrev()
            case 7: VPageNext()
            case 8: //self.showPageControl.toggle()
                fontSize -= 5
                if (fontSize < 20) {fontSize = 20}
                settingPageView(false,.reLayout)

            case 9: VPagePrev()
            default:
                gestureState.reset()

            }
            gestureState.reset()
        }
     //   return EmptyView() //Text("").isHidden(true,remove: true)
    } // body
    func VPageNext(){
        (Settings.verticalform) ? pageNext() :  pagePrev()
    }
    func VPagePrev(){
        (Settings.verticalform ) ? pagePrev() :  pageNext()
    }

    func pagePrev(){

        if (pageCur  < 1) {pageCur = 1; return}
        pageCur = pageCur - 1
        settingPageView(false,.pageChange)

       // isViewChange = FramePageView.pNeedUpdateChange()
    }
    func pageNext(){

        if (pageCur  >= pageCount) { pageCur = pageCount ; return}
        
        pageCur = pageCur + 1
        settingPageView(false,.pageChange)
    }
    func pageGoto(pageno:Int){
        var pno = pageno
        if (pno < 1)  {pno = 1}
        if (pno > pageCount  ) { pno =  pageCount }
      //  pagecur = FramePageView.pPageGoto(page:pno)
        pageCur = pno
        settingPageView(false,.pageChange)

    }
    func settingPageView(_ editingflag:Bool,_ layout:LayoutCheck){
    //      count += 1
   //     var fontnameArray =  ["Heiti TC","楷書","宋體"]

        Settings.setFontSize(fontsize: fontSize)
        Settings.layoutFlag = layout
     //   Settings.rubyfgcolor = UIColor(Color.yellow)

        Settings.pageCur = pageCur

        if (layout == .inputChange || layout == .reLayout) {
            Settings.layoutFlag = .attrStringInput
            Settings.nsAttrString = bopomofo(text: Settings.inputString, settings: Settings)
            Settings.pageCur = 1
        }
        isUpdate = !editingflag // change FramePageView State to settingSet
        // **NOTE**: page count is too late for foreground
        // need to wait layout complete

    }
    func bopomofo(text: String, settings:FramePageSettings)->NSAttributedString{
        let bopomofoPaser = Bopomofo(text: text, settings: settings)
        return bopomofoPaser.bopomofo(text: text)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
