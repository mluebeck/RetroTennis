//
//  Helper Extensions.swift
//  RetroTennisTests
//
//  Created by Mario Rotz on 21.10.23.
//


public extension Double {
   func rad2deg( /* input range: 0 - 2pi */ ) -> Double /* output range: 0-360 degrees */{
       return self * 180 / .pi
   }
   
   func deg2rad( /* input range: 0-360 degrees */ ) -> Double /* output range: 0-2*pi */
   {
       return self * .pi / 180
   }
}

