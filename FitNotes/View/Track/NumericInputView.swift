//
//  NumericInputView.swift
//  FitNotes
//
//  Created by xiscorossello on 30/12/2023.
//

import SwiftUI

struct NumericInputView: View {
    
    @Binding var value: Double?
    
    let title: String
    let incrementAmount: Double
    
    @FocusState var focus;
    
    var body: some View {
        
        
        VStack(spacing: 4) {
            Text(title)
            HStack(spacing: 0) {
                Button(action: {
                    if (value == nil) { return }
                    value! -= incrementAmount
                    hideKeyboard()
                }) {
                    Image(systemName: "minus")
                        .frame(width: 60, height: 75)
                        .background(.tertiary, in: .rect(cornerRadii: RectangleCornerRadii(topLeading: 10, bottomLeading: 10, bottomTrailing: 0, topTrailing: 0 )))
                }
                
                
                TextField("-", value: $value, formatter: doubleFormatter)
                    .focused($focus)
                    .onTapGesture {
                        if (!focus) {
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .frame(width: 80, height: 75)
                    .contentShape(.rect)
                    .background(.tertiary.opacity(0.2))
                
                
                Button(action: {
                    if (value == nil) { return }
                    value! += incrementAmount
                    hideKeyboard()
                }) {
                    Image(systemName: "plus")
                        .frame(width: 60, height: 75)
                        .background(.tertiary, in: .rect(cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: 0, bottomTrailing: 10, topTrailing: 10 )))
                }
            }
        }
    }
}



