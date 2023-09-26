//
//  ContentView.swift
//  RetroTennis
//
//  Created by Mario Rotz on 15.03.23.
//

import SwiftUI
import Combine



struct WhiteView: UIViewRepresentable {
    typealias UIViewType = UIView
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
        
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct RacketView : UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
        
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct Ball : UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
        
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.width / 2
        path.move(to: CGPoint(x: x, y: rect.minY))
        path.addLine(to: CGPoint(x: x, y: rect.maxY))
        return path
    }
}

struct BlackView: UIViewRepresentable {
    typealias UIViewType = UIView
    func makeUIView(context: Context) -> UIView {
        // Return MyView instance.
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
        
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ContentView: View {
    
    let blackViewEdges = CGFloat(4)
    let ballRadius = 14.0
    let racketDimension = CGSize(width: 10, height: 60)
    
    var motion = Motion()
    
    @State private var buttonText : String = "PRESS TO PLAY"
    @State private var touchMoveView = TouchMoveView()
    @State private var leftRacketPosition = CGPoint(x: 10, y: 120)
    @State private var rightRacketPosition = CGPoint(x:10, y:120)
    @State private var ballPosition = CGPoint(x: -100, y: -100)
    @State private var scoreLeft : Int  = 0
    @State private var scoreRight : Int = 0
    @State private var isHidden = false

    var body: some View {
        GeometryReader {
            screengeometry in
            ZStack {
                WhiteView()
                
                GeometryReader {
                    playfieldgeometry in
                    BlackView().padding(EdgeInsets(top: self.blackViewEdges, leading: self.blackViewEdges, bottom: self.blackViewEdges, trailing: self.blackViewEdges))
                    DottedLine()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash:[5])).foregroundColor(.white)
                    touchMoveView
                        .onReceive(touchMoveView.touchMovePublisher()) {  // touch event erhalten und die Bewegung in Position des rechten oder linken Schlägers umrechnen
                            data in
                            let halfHeight = (self.racketDimension.height/2.0 + self.blackViewEdges)
                            var y = data.point.y
                            if y<halfHeight {
                                y = halfHeight
                            } else
                            if y>screengeometry.size.height-halfHeight {
                                y = screengeometry.size.height-halfHeight
                            }
                            if data.racket == Racket.leftRacket {
                                self.leftRacketPosition.y = y
                            } else {
                                self.rightRacketPosition.y = y
                            }
                            self.rightRacketPosition.x = screengeometry.size.width-10
                        }
                    RacketView().frame(width: self.racketDimension.width,height: self.racketDimension.height).position(CGPoint.init(x: 10, y: self.leftRacketPosition.y))
                    RacketView().frame(width: self.racketDimension.width,height: self.racketDimension.height).position(CGPoint.init(x: screengeometry.size.width-10, y: self.rightRacketPosition.y))
                    Ball().frame(width: self.ballRadius,height:self.ballRadius)
                        .position(self.ballPosition)
                        .opacity(self.isHidden ? 1.0 : 0.0)
                        .onReceive(self.motion.motionPublisher(playfieldgeometry.size))
                    {
                        // die momentane Position des Balls erhalten und die Meldung erhalten, ob der Ball ausserhalb des Spielfelds ist.
                        (ballPosition,gameEnding) in
                        self.ballPosition = ballPosition
                        switch gameEnding {
                        case .missedLeftRacket:
                            self.scoreRight += 1
                            self.buttonText = "PLAYER 2 WINS\n\n PRESS TO PLAY"
                            self.isHidden = false
                        case .missedRightRacket:
                            self.scoreLeft += 1
                            self.buttonText = "PLAYER 1 WINS\n\n PRESS TO PLAY"
                            self.isHidden = false
                        case .isInPlayfield:
                            self.motion.calculateNewBallTrajectoryIfHitByTheRacket(racketLeftPosition: self.leftRacketPosition,
                                                       racketRightPosition: self.rightRacketPosition,
                                                       racketDimension: racketDimension)
                        }
                        
                    }
                }
                VStack{
                    HStack(alignment: .top, content: {
                        Spacer()
                        Text("\(self.scoreLeft)")
                            .font(Font.custom("pixeboy", size: 80))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(self.scoreRight)")
                            .font(Font.custom("pixeboy", size: 80))
                            .foregroundColor(.white)
                        Spacer()
                    }).padding(.top,20)
                    Spacer()
                }
                
                
                Button(action: {
                    self.isHidden = !self.isHidden
                    self.motion.startGame()
                })
                {
                    HStack {
                        Text(self.buttonText)
                            .font(Font.custom("pixeboy", size: 40))
                            .foregroundColor(.white)
                    }
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(16)
                }.opacity(self.isHidden ? 0.0 : 1.0)
            } // ZStack
        } // Geo
    } // body
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
