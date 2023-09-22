import SwiftUI
import Combine

enum Rackets {
    case right
    case left
}

struct TouchMoveView: UIViewRepresentable {
    
    private let view = TouchMoveUIView()
    
    func makeUIView(context: UIViewRepresentableContext<TouchMoveView>) -> TouchMoveUIView {
        view
    }
    
    func updateUIView(_ uiView: TouchMoveUIView, context: UIViewRepresentableContext<TouchMoveView>) {}
    
    func touchMovePublisher() -> AnyPublisher<(point:CGPoint,racket:Rackets), Never> {
        return view.touchMoveSubject.eraseToAnyPublisher()
    }
}

class TouchMoveUIView: UIView {
    let touchMoveSubject = PassthroughSubject<(point:CGPoint,racket:Rackets), Never>()

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if location.x < self.frame.size.width / 2.0
        {
            touchMoveSubject.send((location,Rackets.left))
        } else {
            touchMoveSubject.send((location,Rackets.right))
        }
    }

     
}
