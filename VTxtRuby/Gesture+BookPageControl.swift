//
//  Gesture+.swift
//  FileOperation
//
//  Created by Lin Hess on 2021/10/25.
//

import SwiftUI
import CoreGraphics

enum GestureType {
    case none
    case tapped
    case left
    case right
    case up
    case down
    case edgeLeft
    case edgeRight
    case edgeUp
    case edgeDown
}

class GestureState:ObservableObject {
    // gesture active
    @Published  var gestureActive: GestureType = .none
    var action: ()->Void  = {}
    var dragMoves: Int = 0
    var offset: CGPoint = CGPoint.zero
    // swipe
    // tapped
    var tappedPosition: CGPoint = CGPoint.zero
    var tappedPositionIndex: Int = 0

    func reset(){
        gestureActive = .none
    }
    func positionIndex()->Int {
        return tappedPositionIndex
    }
    func startPosiyion()->CGPoint {
        return tappedPosition
    }
    func gestureType()->GestureType {
        return gestureActive
    }
}

extension View{
    //  let magnificationAndRotateGestureAnddraggesture = draggesture.simultaneously(with: magnificationAndRotateGesture)
      // zoom in out
    @ViewBuilder func onTapped(_ gestureState:GestureState) -> some View {
        self.gesture(tapped(gestureState))
    }
    @ViewBuilder func onSwiped(_ gestureState:GestureState, perform:@escaping ()->Void) -> some View {
        self.gesture(drag(gestureState,perform: perform))
    }
    @ViewBuilder func onSwipeAndDrag(_ gestureState:GestureState, perform:@escaping ()->Void) -> some View {
        self.gesture(tapped(gestureState))
        self.gesture(drag(gestureState,perform: perform))
    }
    //  1 | 2 | 3
    // -----------
    //  4 | 5 | 6
    // -----------
    //  7 | 8 | 9
    func areadetection(point:CGPoint)->Int {
        let dx = UIScreen.main.bounds.width
        let dy = UIScreen.main.bounds.height
        var loc:Int = 0
        if (point.x < dx/3) { loc = 1}
        else if (point.x > dx*2.0/3.0) { loc = 3}
        else   { loc = 2 }
        if (point.y < dy/3) { }
        else if (point.y > dy*2.0/3.0) { loc = loc + 6}
        else  { loc = loc + 3 }
        return loc
    }
    func tapped(_ gestureState:GestureState) ->some Gesture {
        //let viewid = self.viewid

        return TapGesture()
            .onEnded { _ in
                gestureState.tappedPositionIndex = areadetection(point:     gestureState.tappedPosition)
                      if (gestureState.dragMoves == 2){
                        if (gestureState.gestureActive != .none ){
                           // gestureState.gestureActive = .swipe
                            gestureState.action()
                            return
                        }
                        gestureState.dragMoves = 1
                        gestureState.gestureActive = .none
                         return
                      }
                      gestureState.gestureActive = .tapped
                      gestureState.action()
              }
      }
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    func drag(_ gestureState:GestureState, perform: @escaping ()->Void ) ->some Gesture {
        gestureState.action = perform

        return DragGesture(minimumDistance: 0, coordinateSpace: .global)
        .onChanged{ value in
            gestureState.gestureActive = .none
              /* TO DO need to bounding check */
        }.onEnded(){ value in
            gestureState.offset.x  = value.location.x - value.startLocation.x
            gestureState.offset.y = value.location.y - value.startLocation.y
            gestureState.dragMoves = (abs(gestureState.offset.x)<5 && abs(gestureState.offset.y)<5.0) ? 1:2
            let length = CGPointDistance(from:value.startLocation,to:value.location)
            let angle = atan(gestureState.offset.y/gestureState.offset.x)
            print("drag length \(length)")
            print("drag angle \(angle)")
                  print("drag position \(value.location)")
                print("drag offset \(gestureState.offset)")           // swip edig Pan From left to right
            gestureState.tappedPosition = value.startLocation
            print(value.translation)
            
            if value.translation.width < 0 && value.translation.height > -30 && value.translation.height < 30 {
                gestureState.gestureActive = .left
            }
            else if value.translation.width > 0 && value.translation.height > -30 && value.translation.height < 30 {
                gestureState.gestureActive = .right
            }
            else if value.translation.height < 0 && value.translation.width < 100 && value.translation.width > -100 {
                gestureState.gestureActive = .up
            }
            else if value.translation.height > 0 && value.translation.width < 100 && value.translation.width > -100 {
                gestureState.gestureActive = .down            }
            else {
                gestureState.gestureActive = .none
            }
              if (value.startLocation.x < CGFloat(30.0)  ) { //&& x > CGFloat(30.0)
                // edgePan(direction: 0) from left to right
                gestureState.gestureActive = .edgeLeft
                // Left Side swpie
               // BookReadView(book: book)
              //  perform // goto view
              }
              if (value.startLocation.x > ( UIScreen.main.bounds.width - CGFloat(30.0)) ){ //&& x <  CGFloat(-30.0)
                gestureState.gestureActive  = .edgeRight //from right to left
              }
            print(value.translation)
        }.sequenced(before: tapped(gestureState))
        
    }// 4.
}
