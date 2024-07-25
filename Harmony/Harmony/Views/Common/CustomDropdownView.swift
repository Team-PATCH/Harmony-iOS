//
//  CustomDropdownView.swift
//  Harmony
//
//  Created by 한수빈 on 7/24/24.
//

import SwiftUI

struct CustomDropdownView: View {
    @Binding var selected: String
    @Binding var isOpen: Bool
    let list: [String]
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isOpen.toggle()
                }
            }) {
                HStack {
                    Text(selected)
                        .font(.pretendardSemiBold(size: 18))
                    Spacer()
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.bl)
                .padding()
                .background(Color.gray1)
                .cornerRadius(10)
            }
            
            if isOpen {
                VStack(spacing: 0) {
                    ForEach(list, id: \.self) { role in
                        Button(action: {
                            selected = role
                            isOpen = false
                        }) {
                            Text(role)
                                .font(.pretendardSemiBold(size: 18))
                                .foregroundColor(.bl)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(role == selected ? Color.gray2 : Color.gray1)
                        }
                    }
                }
                .background(Color.gray1)
                .cornerRadius(10)
                .offset(y: -10)
            }
        }
    }
}


#Preview {
    CustomDropdownView(selected: .constant("d"), isOpen: .constant(true), list: ["a","b","d"])
}
