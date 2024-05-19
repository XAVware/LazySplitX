//
//  DetailPath.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import Foundation

enum DetailPath: Identifiable, Hashable {
    var id: DetailPath { return self }
    case detail
    case subdetail
}
