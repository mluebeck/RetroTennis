//
//  RetroTennisSnapshotTests.swift
//  RetroTennisTests
//
//  Created by Mario Rotz on 13.10.23.
//

import XCTest
import SwiftUI
@testable import RetroTennis


final class RetroTennisSnapshotTests: XCTestCase {
    var viewController: UIViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let bookDetailView = ContentView()
        viewController = UIHostingController(rootView: bookDetailView)
        viewController.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        viewController = nil
    }
    
    func testBookDetailViewOniPhone() throws {
        assert(snapshot: viewController.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
    }
}
