//
//  Motion.swift
//  RetroTennis
//
//  Created by Mario Rotz on 13.05.23.
//

import Combine
import UIKit 


enum Ballposition {
    case missedLeftRacket
    case missedRightRacket
    case isInPlayfield
}

enum StartPosition {
    case leftPartOfPlayfield
    case rightPartOfPlayfield
}

class Motion {
    let motionSubject = PassthroughSubject<(CGPoint,Ballposition), Never>()
    let schrittweite : Double = 10
    var stepDuration = 0.1
    var step : Double = 0
    var startPosition = CGPoint(x:0,y:120)
    var endPosition = CGPoint(x:0,y:120)
    var currentPosition = CGPoint.init(x: 0, y: 0)
    var size : CGSize = CGSize.zero
    
    func chooseRandomlyStartPosition()->StartPosition {
        if Bool.random() == true {
            return StartPosition.leftPartOfPlayfield
        } else {
            return StartPosition.rightPartOfPlayfield
        }
    }
    
    func motionPublisher(_ size:CGSize) -> AnyPublisher<(CGPoint,Ballposition), Never> {
        self.size = size
        return self.motionSubject.eraseToAnyPublisher()
    }
    
    func coordinateWith(racketLeft:CGPoint,racketRight:CGPoint,racketDimension:CGSize) {
        let racketLeftRect = CGRect.init(x: racketLeft.x-racketDimension.width/2.0,
                                         y: racketLeft.y-racketDimension.height/2.0,
                                         width: racketDimension.width,
                                         height: racketDimension.height)
        
        let racketRightRect = CGRect.init(x: racketRight.x-racketDimension.width/2.0,
                                          y: racketRight.y-racketDimension.height/2.0,
                                          width: racketDimension.width,
                                          height: racketDimension.height)
        if CGRectContainsPoint(racketLeftRect,
                               CGPoint.init(x: self.currentPosition.x-racketDimension.width,
                                            y: self.currentPosition.y))
        {
            self.startPosition.x = self.currentPosition.x
            self.startPosition.y = self.currentPosition.y
            self.endPosition.x = self.size.width
            self.endPosition.y = CGFloat.random(in: 0..<self.size.height)
            self.step = self.schrittweite
   
        }
        if CGRectContainsPoint(racketRightRect,  CGPoint.init(x: self.currentPosition.x+racketDimension.width,
                                                              y: self.currentPosition.y ))
        {
            // Ball trifft auf den rechten Schläger und prallt ab
            self.startPosition.x = self.currentPosition.x
            self.startPosition.y = self.currentPosition.y
            self.endPosition.x = 0
            self.endPosition.y = CGFloat.random(in: 0..<self.size.height)
            self.step = -1 * self.schrittweite
        }
    }
    
    func start() {
        self.setBallRandomStartPosition()
        self.currentPosition.x = self.startPosition.x
        self.currentPosition.y = self.startPosition.y
        self.nextStep()
    }
    
    func nextStep() {
        self.currentPosition.x += self.step
        self.currentPosition.y = self.f()
        if self.currentPosition.x<0  {
            self.motionSubject.send((self.currentPosition,Ballposition.missedLeftRacket))
            return
        } else {
            self.motionSubject.send((self.currentPosition,Ballposition.isInPlayfield))
        }
        if self.currentPosition.x>self.size.width {
            self.motionSubject.send((self.currentPosition,Ballposition.missedRightRacket))
            return
        } else {
            self.motionSubject.send((self.currentPosition,Ballposition.isInPlayfield))
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+self.stepDuration, execute: {
            self.nextStep()
        })
    }
    
    // funktion zum Errechnen der nächsten Position
    func f()->CGFloat {
        let steigung = (self.endPosition.y - self.startPosition.y) / (self.endPosition.x - self.startPosition.x)
        let b = self.startPosition.y - steigung*self.startPosition.x
        return self.currentPosition.x * steigung + b
    }
    
    func setBallRandomStartPosition() {
        if self.chooseRandomlyStartPosition() == .leftPartOfPlayfield {
            self.startPosition.x = CGFloat.random(in: 0..<self.size.width/2.0)
            self.startPosition.y = CGFloat.random(in: 0..<self.size.height)
            self.endPosition.x = self.size.width
            self.endPosition.y = CGFloat.random(in: 0..<self.size.height)
            self.step = self.schrittweite
        } else {
            self.startPosition.x = CGFloat.random(in: self.size.width/2.0+1..<self.size.width)
            self.startPosition.y = CGFloat.random(in: 0..<self.size.height)
            self.endPosition.x = 0
            self.endPosition.y = CGFloat.random(in: 0..<self.size.height)
            self.step = -1 * self.schrittweite
        }
    }
}
