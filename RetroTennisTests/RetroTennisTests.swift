//
//  RetroTennisTests.swift
//  RetroTennisTests
//
//  Created by Mario Rotz on 15.03.23.
//

import XCTest
import Combine

@testable import RetroTennis

final class RetroTennisTests: XCTestCase {
    var publisher : AnyCancellable?
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        self.publisher = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_leftRacketMissedTheBall() {
        
        let playfieldSize = CGSize(width: 1000, height: 1000)
        
        let racketLeftPosition = CGPoint(x: 10, y: 300)
        let racketRightPosition = CGPoint(x: -100, y: -100)
        
        let racketDimension = CGSize(width: 10, height: 30)
        
       
        let motion = Motion()
        motion.motionParameter.size = playfieldSize
        motion.startPosition.x = playfieldSize.width-10
        motion.startPosition.y = 100
        motion.currentPosition = CGPoint(x: motion.startPosition.x + racketDimension.width, y:motion.startPosition.y)
        motion.endPosition.x = 0
        motion.endPosition.y = 100
        motion.step = motion.motionParameter.schrittweite * -1.0
             
        motion.calculateNewBallTrajectoryIfHitByTheRacket(racketLeftPosition: racketLeftPosition, racketRightPosition: racketRightPosition, racketDimension: racketDimension)
         
        XCTAssertEqual(motion.endPosition.x, 0)
        XCTAssertEqual(motion.endPosition.y, 100," t")
        XCTAssertEqual(motion.step,motion.motionParameter.schrittweite * -1.0)
        
        
        
    }
    
    func test_rightRacketMissedTheBall() {
        let playfieldSize = CGSize(width: 1000, height: 1000)
        
        let racketLeftPosition = CGPoint(x: -110, y: -300)
        let racketRightPosition = CGPoint(x: playfieldSize.width-10, y: 300)
        
        let racketDimension = CGSize(width: 10, height: 30)
        
       
        let motion = Motion()
        motion.motionParameter.size = playfieldSize
        motion.startPosition.x = racketRightPosition.x
        motion.startPosition.y = racketRightPosition.y
        motion.currentPosition = CGPoint(x: motion.startPosition.x  , y:motion.startPosition.y)
        motion.endPosition.x = playfieldSize.width
        motion.endPosition.y = 100
        motion.step = motion.motionParameter.schrittweite
             
        motion.calculateNewBallTrajectoryIfHitByTheRacket(racketLeftPosition: racketLeftPosition, racketRightPosition: racketRightPosition, racketDimension: racketDimension)
         
        XCTAssertEqual(motion.endPosition.x, playfieldSize.width)
        XCTAssertEqual(motion.endPosition.y,100)
        XCTAssertEqual(motion.step,motion.motionParameter.schrittweite )
    }
    
    func test_ballHitsRightRacket() {
        let playfieldSize = CGSize(width: 1000, height: 1000)
        
        let racketLeftPosition = CGPoint(x: -1110, y: -1300)
        let racketRightPosition = CGPoint(x: playfieldSize.width-10, y: 100)
        
        let racketDimension = CGSize(width: 10, height: 30)
        
       
        let motion = Motion()
        motion.motionParameter.size = playfieldSize
        motion.startPosition.x = racketRightPosition.x
        motion.startPosition.y = racketRightPosition.y
        motion.currentPosition = CGPoint(x: motion.startPosition.x - racketDimension.width, y:motion.startPosition.y)
        motion.endPosition.x = playfieldSize.width
        motion.endPosition.y = 100
        motion.step = motion.motionParameter.schrittweite
             
        motion.calculateNewBallTrajectoryIfHitByTheRacket(racketLeftPosition: racketLeftPosition, racketRightPosition: racketRightPosition, racketDimension: racketDimension)
         
        XCTAssertEqual(motion.endPosition.x, 0)
        XCTAssertTrue(motion.endPosition.y>=0)
        XCTAssertEqual(motion.step,motion.motionParameter.schrittweite * -1.0 )
    }
    
    func test_ballHitsLeftRacket() {
        let playfieldSize = CGSize(width: 1000, height: 1000)
        
        let racketLeftPosition = CGPoint(x: 10, y: 300)
        let racketRightPosition = CGPoint(x: -100, y: -100)
        
        let racketDimension = CGSize(width: 10, height: 30)
        
       
        let motion = Motion()
        motion.motionParameter.size = playfieldSize
        motion.startPosition.x = racketLeftPosition.x
        motion.startPosition.y = racketLeftPosition.y
        motion.currentPosition = CGPoint(x: motion.startPosition.x + racketDimension.width   , y:motion.startPosition.y)
        motion.endPosition.x = 0
        motion.endPosition.y = 100
        motion.step = motion.motionParameter.schrittweite * -1.0
             
        motion.calculateNewBallTrajectoryIfHitByTheRacket(racketLeftPosition: racketLeftPosition, racketRightPosition: racketRightPosition, racketDimension: racketDimension)
         
        XCTAssertEqual(motion.endPosition.x, playfieldSize.width)
        XCTAssertTrue(motion.endPosition.y>=0)
        XCTAssertEqual(motion.step,motion.motionParameter.schrittweite  )
    }
     
    func test_calculateNextBallPosition() {
        let motion = Motion()
        motion.startPosition = CGPoint(x: 0, y: 100)
        motion.endPosition = CGPoint(x:300,y:400)
        motion.currentPosition = CGPoint(x:100,y:0)
        let steigung = (motion.endPosition.y - motion.startPosition.y) / (motion.endPosition.x - motion.startPosition.x)
        let result = motion.currentPosition.x * steigung + motion.startPosition.y - steigung*motion.startPosition.x
        XCTAssertEqual(motion.calculateNextBallPosition(),result)
    }
    
    func test_nextStepLoop_leftRacketMissedTheBall() {
        let motion = Motion()
        let exp = expectation(description: "Wait for request")
        self.publisher = motion.motionPublisher(CGSize(width: 1000, height: 1000)).sink(receiveValue: {  (_,gameEnding) in
            XCTAssertTrue(gameEnding == .missedLeftRacket)
            exp.fulfill()
        })
        motion.currentPosition = CGPoint(x: 0, y: 0)
        motion.step = motion.motionParameter.schrittweite * -1.0
        motion.nextStepLoopWhileRacketsDidNotMissedTheBall(singeStep: true)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_nextStepLoop_rightRacketMissedTheBall() {
        let motion = Motion()
 
        let exp = expectation(description: "Wait for request")
        self.publisher = motion.motionPublisher(CGSize(width: 1000, height: 1000)).sink(receiveValue: {  (_,gameEnding) in
            XCTAssertTrue(gameEnding == .missedRightRacket)
            exp.fulfill()
        })
        motion.currentPosition = CGPoint(x: motion.motionParameter.size.width, y: 0)
        motion.step = motion.motionParameter.schrittweite
        motion.nextStepLoopWhileRacketsDidNotMissedTheBall(singeStep: true)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_nextStepLoop_BallStillInPlayfield() {
        let motion = Motion()
        let exp = expectation(description: "Wait for request")
        self.publisher = motion.motionPublisher(CGSize(width: 1000, height: 1000)).sink(receiveValue: {  (_,gameEnding) in
            XCTAssertTrue(gameEnding == .isInPlayfield)
            exp.fulfill()
        })
        motion.currentPosition = CGPoint(x: motion.motionParameter.size.width/2.0, y: 0)
        motion.step = motion.motionParameter.schrittweite
        motion.nextStepLoopWhileRacketsDidNotMissedTheBall(singeStep: true)
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    

}
