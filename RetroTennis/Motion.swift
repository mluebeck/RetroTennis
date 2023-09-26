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

struct MotionParameter {
    let schrittweite : Double = 10
    var stepDuration = 0.1
    var size : CGSize = CGSize.zero
}

class Motion {
    let motionSubject = PassthroughSubject<(CGPoint,Ballposition), Never>()
    var startPosition = CGPoint(x:0,y:120)
    var endPosition = CGPoint(x:0,y:120)
    var currentPosition = CGPoint.init(x: 0, y: 0)
    var step : Double = 0
    var motionParameter = MotionParameter()
    
    func chooseRandomlyStartPosition()->StartPosition {
        if Bool.random() == true {
            return StartPosition.leftPartOfPlayfield
        } else {
            return StartPosition.rightPartOfPlayfield
        }
    }
    
    func motionPublisher(_ size:CGSize) -> AnyPublisher<(CGPoint,Ballposition), Never> {
        self.motionParameter.size = size
        return self.motionSubject.eraseToAnyPublisher()
    }
    
    func calculateNewBallTrajectoryIfHitByTheRacket(racketLeftPosition:CGPoint,racketRightPosition:CGPoint,racketDimension:CGSize) {
        let racketLeftRect = CGRect.init(x: racketLeftPosition.x-racketDimension.width/2.0,
                                         y: racketLeftPosition.y-racketDimension.height/2.0,
                                         width: racketDimension.width,
                                         height: racketDimension.height)
        
        let racketRightRect = CGRect.init(x: racketRightPosition.x-racketDimension.width/2.0,
                                          y: racketRightPosition.y-racketDimension.height/2.0,
                                          width: racketDimension.width,
                                          height: racketDimension.height)
        if CGRectContainsPoint(racketLeftRect,
                               CGPoint.init(x: self.currentPosition.x-racketDimension.width,
                                            y: self.currentPosition.y))
        {
            // Ball trifft auf den linken Schläger und prallt ab
            self.startPosition.x = self.currentPosition.x
            self.startPosition.y = self.currentPosition.y
            self.endPosition.x = self.motionParameter.size.width
            self.endPosition.y = CGFloat.random(in: 0..<self.motionParameter.size.height)
            self.step = self.motionParameter.schrittweite
   
        } else
        if CGRectContainsPoint(racketRightRect,  CGPoint.init(x: self.currentPosition.x+racketDimension.width,
                                                              y: self.currentPosition.y ))
        {
            // Ball trifft auf den rechten Schläger und prallt ab
            self.startPosition.x = self.currentPosition.x
            self.startPosition.y = self.currentPosition.y
            self.endPosition.x = 0
            self.endPosition.y = CGFloat.random(in: 0..<self.motionParameter.size.height)
            self.step = -1 * self.motionParameter.schrittweite
        }
    }
    
    func startGame() {
        self.setBallRandomStartPosition()
        self.currentPosition.x = self.startPosition.x
        self.currentPosition.y = self.startPosition.y
        self.nextStepLoopWhileRacketsDidNotMissedTheBall()
    }
    
    func nextStepLoopWhileRacketsDidNotMissedTheBall(singeStep:Bool = false) {
        self.currentPosition.x += self.step
        self.currentPosition.y = self.calculateNextBallPosition()
        if self.currentPosition.x<0  {  //  left racket missed the ball
            self.motionSubject.send((self.currentPosition,Ballposition.missedLeftRacket))
        } else
        if self.currentPosition.x>self.motionParameter.size.width { //  right racket missed the ball
            self.motionSubject.send((self.currentPosition,Ballposition.missedRightRacket))
             
        } else {
            self.motionSubject.send((self.currentPosition,Ballposition.isInPlayfield))
            if singeStep==false {
                DispatchQueue.main.asyncAfter(deadline: .now()+self.motionParameter.stepDuration, execute: {
                    self.nextStepLoopWhileRacketsDidNotMissedTheBall()
                })
            }
        }
    }
    
    // funktion zum Errechnen der nächsten Position
    func calculateNextBallPosition()->CGFloat {
        let steigung = (self.endPosition.y - self.startPosition.y) / (self.endPosition.x - self.startPosition.x)
        let b = self.startPosition.y - steigung*self.startPosition.x
        return self.currentPosition.x * steigung + b
    }
    
    func setBallRandomStartPosition() {
        if self.chooseRandomlyStartPosition() == .leftPartOfPlayfield {
            self.startPosition.x = CGFloat.random(in: 0..<self.motionParameter.size.width/2.0)
            self.startPosition.y = CGFloat.random(in: 0..<self.motionParameter.size.height)
            self.endPosition.x = self.motionParameter.size.width
            self.endPosition.y = CGFloat.random(in: 0..<self.motionParameter.size.height)
            self.step = self.motionParameter.schrittweite
        } else {
            self.startPosition.x = CGFloat.random(in: self.motionParameter.size.width/2.0+1..<self.motionParameter.size.width)
            self.startPosition.y = CGFloat.random(in: 0..<self.motionParameter.size.height)
            self.endPosition.x = 0
            self.endPosition.y = CGFloat.random(in: 0..<self.motionParameter.size.height)
            self.step = -1 * self.motionParameter.schrittweite
        }
    }
}
