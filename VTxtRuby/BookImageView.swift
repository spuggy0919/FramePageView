//
//  BookImageView.swift
//  FileOperation
//
//  Created by Lin Hess on 2021/10/30.
//

import SwiftUI

struct BookImageView: View {
    // argument
    @State var book:BookFile
    @Binding var isShowImgView:Bool

    @State var isViewChange:Bool = true
    @State var isViewUpdate:Bool = true
 //   @State var chappages:Int = 1
    @StateObject var  gestureState:GestureState =  GestureState()

    let colors:[UIColor] = [UIColor(red: 240.0/255.0, green: 230.0/255.0, blue: 110/255.0, alpha: 1),.red, .purple, .orange, .blue, .black, .darkGray, .white]
    @State var coloridx:Int = 0
    @State var hiddenCurView:Bool = false
//https://stackoverflow.com/questions/56513568/ios-swiftui-pop-or-dismiss-view-programmatically
    @Environment(\.presentationMode)  var PresentationMode:Binding<PresentationMode>
 
    let sw = UIScreen.main.bounds.width
    let sh = UIScreen.main.bounds.height
    
    @State var showPageControl:Bool = false
    @State var show:Bool = false
    @State var isUpdate:Bool = false
    @State var fontSize:Double = 30
    @State var fontIndex:Int = 0
    @State var lineSpace:Double = 0
    @State var kerning:Double = 0
    @State var verticalflag:Bool = true
    @State var colorIndex:Int = 4
    @State var pageCur:Double = 1
    @State var pageCount:Int = 10
    @State var chapCur:Int = 1
    @State var debugInfo:Bool = false
    @State var topSafeArea:CGFloat = 47
    @State var bottomSafeArea:CGFloat = 34
//left
    @State var pageCount1:Int = 10
    @State var isUpdatePageDecorate:Bool = false
    @EnvironmentObject var userSettings: UserSettings

//    init(book:BookFile, isShow){
//      //  var book1 = book
//      //  book1.readContent()
//        self._book = State(initialValue: book1)
//        self._book = State(initialValue: book1)
//    }
    
    var body: some View {
    
        let Settings =  userSettings.imgViewSettings
        let leftSettings =  userSettings.pageLeftSettings
 //       let rightSettings =  userSettings.pageRightSettings
//        let fontColor = colorArray[Settings.colorIndex].fgColor
        let pageColor = colorArray[Settings.colorIndex].bkColor
        
        GeometryReader { geometry in
            ZStack{
                // status bar
//                Color.init(UIColor(pageColor))
                Rectangle().fill(pageColor)
                    .frame(width:sw, height:sh)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(-1)
                    .animation(.linear)// home indicator dark


//                // 頁眉
//                HStack{
//                    Text("\(book.chaptitle)")
//                }.font(.system(size: 12))
//                .background(Color.clear)
//                .foregroundColor(colorArray[colorIndex].fgColor)
//                .frame(height:18)
//                .border(Color.purple, width: 1)
//                .offset(y:-sh/2 + geometry.safeAreaInsets.top + 30)
//                .zIndex(0.1)
           //    內文
                    // FramePageView Image
 //             VStack{
               FramePageView(inputStr: book.content, isUpdate: $isUpdate, pagecount: $pageCount, settings:Settings)
                .padding(20) // padding should before frame
                .frame(width:sw, height: geometry.frame(in: .local).size.height - Settings.topSafeArea - Settings.bottomSafeArea)
                .background(Color.clear)
                    .zIndex(0)
                .onSwiped(gestureState, perform:swipedAction) //add drag will impact the scroll
                .onTapped(gestureState) //add drag will impact the scroll
                //   .rotationEffect(.degrees(45))
//                if (gestureState.gestureActive == .tapped) {
//                    TappedView().zIndex(1)
//                }
//                else if (gestureState.gestureActive != .none) {SwipedView().zIndex(1)
//                }

//                }.zIndex(0)

                // left side
 //               VStack{
                FramePageView(inputStr: book.chaptitle, isUpdate: $isUpdatePageDecorate, pagecount: $pageCount1, settings:leftSettings)
                  //  .frame(widthheight:sh)
                    .frame(width:20, height: geometry.frame(in: .local).size.height - Settings.topSafeArea - Settings.bottomSafeArea)
    //                .frame(width:20, height: sh - Settings.topSafeArea - Settings.bottomSafeArea)
                    .offset(x:-sw/2 + 10)                     .zIndex(0.1)
                    .onSwiped(gestureState, perform:swipedAction) //add drag will impact the scroll
                    .onTapped(gestureState) //add drag will impact the scroll
//                    if (gestureState.gestureType() == .tapped) {TappedView().zIndex(1)}
//                    else if (gestureState.gestureType() != .none) {SwipedView().zIndex(1)}

//                }//.zIndex(0.1)

//                .onSwiped(gestureState, perform:swipedAction) //add drag will impact the scroll
//                .onTapped(gestureState) //add drag will impact the scroll

                
                // 頁腳
                HStack{
                    Text("-\(Int(pageCur))/\(self.pageCount)-") //
                   // Text("\(Int(chapCur))/\(chapCount())")
                }.font(.system(size: 12))
                .background(Color.clear)
                .foregroundColor(colorArray[colorIndex].fgColor)
                .frame(height:18)
            //    .border(Color.purple, width: 1)
                .offset(y:sh/2 - Settings.bottomSafeArea - 18/2 - 1)
                .zIndex(0.1)
     // page slider control
//                VStack{
//                    ButtonSliderButtonView(
//                        slidecount: $pageCur,
//                        pageCount: pageCount, // it is DOuble
//                        chapCount: book.chapCount,
//                        chapCur: chapCur,
//                        sysImage1: "backward", degree1:0, action1: chapPrev,
//                        sysImage2:"play",  degree2:180, action2: pagePrev,
//                        sysImage3:"play",  degree3:0, action3: pageNext,
//                        sysImage4:"forward",  degree4:0, action4: chapNext,
//                        layout:.pageChange, callback: settingViewCallback)
//                        .rotationEffect(.degrees(verticalflag ? Double(180):0))
//                   //     .padding(.vertical)
//                    } // VStack
//                    .animation(.linear)
//                    .frame(height:80)
//                    .padding(.top)
//                    .background(colorArray[colorIndex].stColor)
//                    .foregroundColor(colorArray[colorIndex].fgColor)
//                    .opacity(0.9)
//                    .offset(y:(self.showPageControl && pageCount != 0) ? (sh/2 - Settings.bottomSafeArea - 80 / 2) : sh)
//                    .zIndex(1)
                
                // Settinngs  slider
                    SettingsView(isShowView: $show, colorIndex:$colorIndex, fontSize: $fontSize, lineSpace: $lineSpace, kerning: $kerning , verticalflag: $verticalflag, fontIndex: $fontIndex, pageCur:$pageCur, pagecount:pageCount,callback:settingViewCallback)
                        .frame(height:220)
                        .offset(y: self.show ?   sh/2 - 220/2 - Settings.bottomSafeArea  : sh)
                        .zIndex(2)
                        .opacity(debugInfo ? 0.6 :1)
//                        .overlay(
//                            GeometryReader(content: { geometry in
//                                VStack{
//                                    Text(geometry.frame(in: .global).debugDescription)
//                                    Text(geometry.safeAreaInsets.debugDescription)
//                                }
//                                    .background(Color.yellow)
//                                    .opacity(debugInfo ? 0.6 :0)
//                            })
//                        )
                //.background(Color(UIColor.label.withAlphaComponent(self.show ? 0: 0)).edgesIgnoringSafeArea(.all))

                // information text
                VStack{
                    // bindings
                    Text("wxh\(sw)-\(sh)")
                    Text("top\(Settings.topSafeArea)")
                    Text("bottom\(Settings.bottomSafeArea)")
                    Text("\(Int(pageCur))/\(pageCount)")
                    Text("FontSize:\(Int(fontSize))")
                    Text("lineSpace:\(Int(lineSpace))")
                    Text("kerning:\(Int(kerning))")
                    if (verticalflag) {
                        Text( "verticalflag")
                    }else{
                        Text( "Horiaontal")
                    }
                    Text("fontName:\(Settings.fontname)")
                    Button(action: {
                        self.debugInfo.toggle()
                     //   settingViewCallback(false, .reLayout)
                    }) {
                    Text("Hide").padding(.vertical).padding(.horizontal,25).foregroundColor(.black)
                    }
                    .background(LinearGradient(gradient: .init(colors: [Color("Color"),Color("Color1")]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
                    .background(Color.clear)

                //    Text(self.selected).padding(.top)
                }
                .foregroundColor(Color.red)
                .background(Color.clear) // *****
                .opacity(0.8)
                .offset(y: -140)
                .zIndex(debugInfo ? 1 : -1)
                .isHidden(!self.debugInfo)
// button page clicks
//                HStack{
//                    Button( action: pageNext){
//                        Text("<<<")
//                            .frame( width: UIScreen.main.bounds.width*2/5, height: UIScreen.main.bounds.height - 90)
//                          //  .border(Color.purple, width: 5)
//                    }
//
//                    Text("\(Int(pageCur))/\(self.pageCount)")
//                        .frame(width: sw/5, height: sh - 90)
//                        .font(.title2)
//                    Button( action: pagePrev){
//                        Text(">>>")
//                            .frame( width: sw*2/5, height: sh - 90)
//                           // .border(Color.purple, width: 5)
//                    }
//                }.background(Color.clear,alignment:.top)
//                .foregroundColor(Color.clear)
//                .zIndex(1)
                // gesture
            } // ZStack
             .navigationBarHidden(true)
             .hiddenNavigationBarStyle()
//            .background(Color("Color2").edgesIgnoringSafeArea(.all))
             .animation(.default)

             .onAppear(){
          //      if (gestureState.swipeDir == -1){
    //                isViewUpdate = false
    //                chapcur = book.chapCur
    //                pagecur = book.pageCur
    //                chapGoto(chapno: chapcur)
    //                pageGoto(pageno: pagecur)
    //                _ = BookReadView(book: book)
                
             //   }
                 //onTappedAction()
            } // onApear
            .onLoad {
            //    print("onLoad bounds\(UIScreen.main.bounds)")
            //    #if TESTING_
                // read is delay
             //   let settings = userSettings.imgViewSettings
    //            settings.inputString = book.content
    //            settings.font = UIFont(name: "TW-Sung-98_1", size:30)
    //            settings.lineSpacing = 18.0
              //  settingSet()
                if (book.ext == "txt" && book.content == "") {
                    book.readContent()
                }else{
                    chapCur = book.chapCur
                    chapGoto(chapno: chapCur)
                }
                pageCur = Double(book.pageCur)
    //            settings.pageCur = 1
    //            settings.layoutFlag = .inputChange
    //            isUpdate.toggle()
                settingViewCallback(false,.inputChange)
             //   chapGoto(chapno: chapcur)
              //  pageGoto(pageno: pagecur)
            } // onload
//            // button click bottom
//                HStack{
//                    Button("<<<", action: pageNext)
//                    Button("\(Int(pageCur))/\(self.pageCount)"){
//
//
//                    }
//                    Button(">>>", action: pagePrev)
//                    Button("<<<", action: chapNext)
//                    Button("\(chapCur)/\(self.chapCount())") {
//
//                    }
//                    Button(">>>", action: chapPrev)
//                }.font(.callout)
            } // GeometryReader
           .edgesIgnoringSafeArea(.all)
        
    } // body
    func settingViewCallback(_ editingflag:Bool,_ layout:LayoutCheck){
    //      count += 1
   //     var fontnameArray =  ["Heiti TC","楷書","宋體"]
        let Settings =  userSettings.imgViewSettings

        Settings.layoutFlag = layout
        Settings.fontname = fontArray[fontIndex].fontName
        Settings.fontSize = CGFloat(Int(fontSize))
        Settings.lineSpacing = CGFloat(Int(lineSpace)) +
                        fontArray[fontIndex].linespacing
        Settings.colorIndex = colorIndex
        Settings.fontcolor = UIColor(colorArray[colorIndex].fgColor)
        Settings.pagebrcolor = UIColor(colorArray[colorIndex].bkColor)
        Settings.rubyfgcolor = UIColor(colorArray[colorIndex].rbColor)
//        Settings.font = UIFont(name: Settings.fontname, size:  Settings.fontSize)
        Settings.kerning = CGFloat(Int(kerning)) +
                           fontArray[fontIndex].kerning
        Settings.rubybaseline = 0.0 + fontArray[fontIndex].rubybase
        Settings.verticalform = verticalflag
        Settings.inputString = book.content
        Settings.pageCur = Int(pageCur)
        Settings.debugDrawFrameFlag = debugInfo
        if (layout == .inputChange) {
            Settings.layoutFlag = .attrStringInput
            Settings.nsAttrString = bopomofo(text: Settings.inputString, settings: Settings)
        }
        isUpdate = !editingflag // change FramePageView State to settingSet

        // page decorate
        userSettings.pageLeftSettings.inputString = book.chaptitle
        userSettings.pageRightSettings.inputString = book.chaptitle
        userSettings.syncPageParameter(fsize: 12)

        isUpdatePageDecorate = !editingflag // change FramePageView State to settingSet

    //    print("settingViewCallback=\(count)=\(flag)")
    }
    func bopomofo(text: String, settings:FramePageSettings)->NSAttributedString{
        let bopomofoPaser = Bopomofo(text: text, settings: settings)
        return bopomofoPaser.bopomofo(text: text)
    }
    // for  BookReadView transition by Vieews
    func swipedAction()->Void {
        switch gestureState.gestureType() {
        case .left:
            VPagePrev()
        case .right:
            VPageNext()
        case .down:
            self.show = false
            self.showPageControl = false

        case .up:
            self.show = true
            self.showPageControl = false
        case .edgeRight:  do {
          //  hiddenCurView = true
        //    self.PresentationMode.wrappedValue.dismiss()
            isShowImgView.toggle()
        }         // swip from left side
        case .edgeLeft: do {
          //  hiddenCurView = true
        //    self.PresentationMode.wrappedValue.dismiss()
            isShowImgView.toggle()

         //   FileFolderNavigator(books:bookLibrary)         // swip from right side
        }
        default:
            break

        }
        tappedAction()
        gestureState.reset()
    }
//    func tappedAction()-> some View{
//        DispatchQueue.main.async {
//            onTappedAction()
//        }
//        return EmptyView() //Text("").isHidden(true,remove: true)
//    }
    func tappedAction() {
    //    return
        if (gestureState.gestureType() == .tapped) {
            var one = 0
            if (self.show)  {
                one += 1
                self.show.toggle()
                return
            }
            
            switch gestureState.positionIndex() {
            case 1: VPageNext()
            case 2: do {
                #if DEBUG
                self.debugInfo.toggle()
                settingViewCallback(false,.colorChange)
                #endif
                self.show.toggle() //increaseFontSize()
            }
            case 3: VPagePrev()
            case 4: VPageNext()
            case 5:do{
                 //   self.show.toggle()
                    self.showPageControl = false
            }
            case 6: VPagePrev()
            case 7: VPageNext()
            case 8: self.showPageControl.toggle()
            case 9: VPagePrev()
            default:
                gestureState.reset()

            }
            gestureState.reset()
        }
     //   return EmptyView() //Text("").isHidden(true,remove: true)
    }
//    func onFontColorChange(){
//        let settings = userSettings.imgViewSettings
//        self.coloridx = (self.coloridx+1)%self.colors.count
//        settings.fontcolor = self.colors[coloridx]
//        settingSet()
//        isViewChange.toggle()
//    }
//    func onRubyColorChange(){
//        let settings = userSettings.imgViewSettings
//        self.coloridx = (self.coloridx+1)%self.colors.count
//        settings.rubyfgcolor = self.colors[coloridx]
//        settingSet()
//        isViewChange.toggle()
//
//    }
//    func onPageColorChange(){
//        let settings = userSettings.imgViewSettings
//        self.coloridx = (self.coloridx+1)%self.colors.count
//        settings.pagebrcolor = self.colors[coloridx]
//        settingSet()
//        isViewChange.toggle()
//
//    }
//    func toggleHV(){
//       let settings = userSettings.imgViewSettings
//       settings.verticalform.toggle()
//       settingSet()
//
//    }
//    func toggleW(){
//       let settings = userSettings.imgViewSettings
//       settings.writingdirection = (settings.writingdirection+1) % 4
//       settingSet()
//        isViewChange.toggle()
//
//    }
//    func increaseFontSize(){
//        let settings = userSettings.imgViewSettings
//        settings.fontSize += 1.0
//        if (settings.fontSize > 60){
//            settings.fontSize = 60
//        }
//        settings.font = UIFont(name:settings.fontname, size:settings.fontSize)
//        settingSet()
//        print("fontsize:\(settings.fontSize)")
//    }
//    func decreaseFontSize(){
//        let settings = userSettings.imgViewSettings
//        settings.fontSize -= 1.0
//        if (settings.fontSize < 15){
//            settings.fontSize = 15
//        }
//        settings.font = UIFont(name:settings.fontname, size:settings.fontSize)
//        settingSet()
//        print("fontsize:\(settings.fontSize)")
//
//    }
//    func increaseLineSpace(){
//        let settings = userSettings.imgViewSettings
//        settings.lineSpacing += 1.0
//        if (settings.lineSpacing > 30){
//            settings.lineSpacing = 30
//        }
//        settingSet()
//        print("lineSpacing:\(settings.lineSpacing)")
//
//    }
//    func decreaseLineSpace(){
//        let settings = userSettings.imgViewSettings
//        settings.lineSpacing -= 1.0
//        if (settings.lineSpacing < -30){
//            settings.lineSpacing = -30
//        }
//        settingSet()
//        print("lineSpacing:\(settings.lineSpacing)")
//
//    }
//    func increaserubybaseline(){
//        let settings = userSettings.imgViewSettings
//        settings.rubybaseline += 1.0
//        if (settings.rubybaseline > 30){
//            settings.rubybaseline = 30
//        }
//        settingSet()
//        print("rubybaseline:\(settings.rubybaseline)")
//
//    }
//    func decreaserubybaseline(){
//        let settings = userSettings.imgViewSettings
//        settings.rubybaseline -= 1.0
//        if (settings.rubybaseline < -30){
//            settings.rubybaseline = -30
//        }
//        settingSet()
//        print("rubybaseline:\(settings.rubybaseline)")
//
//    }
//    func increaseKerning(){
//        let settings = userSettings.imgViewSettings
//        settings.kerning += 1
//        if (settings.kerning > 30){
//            settings.kerning = 30
//        }
//        settingSet()
//        print("kerning:\(settings.kerning)")
//
//    }
//    func decreaseKerning(){
//        let settings = userSettings.imgViewSettings
//        settings.kerning -= 1
//        if (settings.kerning < -30){
//            settings.kerning = -30
//        }
//        settingSet()
//        print("kerning:\(settings.kerning)")
//
//    }
//    func increaseExpansion(){
//        let settings = userSettings.imgViewSettings
//        settings.expansion += 1
//        if (settings.expansion > 20){
//            settings.expansion = 20
//        }
//        settingSet()
//
//    }
//    func decreaseExpansion(){
//        let settings = userSettings.imgViewSettings
//        settings.expansion -= 1
//        if (settings.expansion < -20){
//            settings.expansion = -20
//        }
//        settingSet()
//
//    }
//    func increaseObligueness(){
//        let settings = userSettings.imgViewSettings
//        settings.obliqueness += 1
//        if (settings.obliqueness > 20){
//            settings.obliqueness = 20
//        }
//        settingSet()
//
//    }
//    func decreaseObliqueness(){
//        let settings = userSettings.imgViewSettings
//        settings.obliqueness -= 1
//        if (settings.obliqueness < -20){
//            settings.obliqueness = -20
//        }
//        settingSet()
//
//    }
//    func settingSet(){
//        let settings = userSettings.imgViewSettings
//        settings.layoutFlag = .reLayout
//        isUpdate = true
//    }
    func VPageNext(){
        (verticalflag) ? pageNext() :  pagePrev()
    }
    func VPagePrev(){
        (verticalflag) ? pagePrev() :  pageNext()
    }
    func VChapNext(){
        (verticalflag) ?  chapPrev() : chapNext()
    }
    func VChapPrev(){
        (verticalflag) ?   chapNext() : chapPrev()
    }
    func pagePrev(){
        if (book.ext == "updb" && chapCur != 1 && pageCur == 1.0 ) {
            chapPrev() // BUG chapter is not ready for counting pageCount
                        // so next statement will fail
            // wait for cfrange is not zero
        //    DispatchQueue.global(qos:.background).async{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let settings = userSettings.imgViewSettings
         //       let pcount = pageCount //&& pageCount == pcount
                while (settings.layoutFlag == .inputChange ){
                    _ = FramePageView.pPageCount()
                }
                
                pageGoto(pageno:pageCount) // to do need pageframe update COunt
            }
            return
        }
        if (Int(pageCur) == 1) {return}
        pageCur = pageCur - 1.0
        settingViewCallback(false,.pageChange)

       // isViewChange = FramePageView.pNeedUpdateChange()
    }
    func pageNext(){
        if (book.ext == "updb" && chapCur < chapCount() && Int(pageCur) >= pageCount) {
            pageCur = 1
            chapNext()
        //    pageGoto(pageno:1)
            return
        }
        if (Int(pageCur) == pageCount) {return}

        pageCur = pageCur + 1
        settingViewCallback(false,.pageChange)
    }
    func pageGoto(pageno:Int){
        var pno = pageno
        if (pno < 1)  {pno = 1}
        if (pno > pageCount  ) { pno =  pageCount }
      //  pagecur = FramePageView.pPageGoto(page:pno)
        pageCur = Double(pno)
        settingViewCallback(false,.pageChange)


    }
//    func pageCount()->Int{
//        return FramePageView.pPageCount()
//    }
    func chapCount()->Int{
        if (book.ext == "txt") {return 1}
        return book.chapRange.count-1
    }

    func chapNext(){
        if (book.ext == "txt" || chapCur == chapCount()) {return}
        // read content
        chapCur = chapCur + 1
        pageCur = 1
        chapGoto(chapno: chapCur)

    }
    func chapPrev(){
        if (book.ext == "txt" || chapCur == 1) {return}
        chapCur = chapCur - 1
        chapGoto(chapno: chapCur)
    }
    func chapGoto(chapno:Int){
        // read chap content and layout
        if(book.ext == "txt") {
            return
        }
        book.readChapterContent(chap:chapno)
        book.chapCur = chapno
    //    pageCur = 1
        settingViewCallback(false,.inputChange)
    }
}
//struct BookImageView_Previews: PreviewProvider {
//    @State var isShow:Bool = false
//    static var previews: some View {
//        BookImageView(book:bookLibrary[0],isShowImgView:$isShow)
//
//    }
//}
