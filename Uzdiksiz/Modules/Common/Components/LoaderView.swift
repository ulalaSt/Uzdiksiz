//
//  LoaderView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//
import SwiftUI

struct LoaderView: View {
    let text: String
    
    var body: some View {
        ProgressView(text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 34/255, green: 40/255, blue: 52/255).ignoresSafeArea())
    }
}
