//
//  SearchBarView.swift
//  Harmony
//
//  Created by 한범석 on 7/17/24.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    @State var isEditing = false
    var onCancel: () -> Void
    
    var body: some View {
        HStack {
            TextField("찾고 싶은 추억을 검색하세요😊", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal, 10)
                .onTapGesture {
                    withAnimation {
                        isEditing = true
                    }
                }
                .onSubmit {
                    onCancel()
                }
            if isEditing {
                Button(action: {
                    isEditing = false
                    searchText = ""
                    onCancel()
                    UIApplication.shared.endEditing()
                }, label: {
                    Text("Cancel")
                })
                .padding(.trailing, 15)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isEditing)
            }
        }
        .animation(.snappy, value: isEditing)
    }
}

#Preview {
    SearchBar(searchText: .constant("Swift"), onCancel: {})
}
