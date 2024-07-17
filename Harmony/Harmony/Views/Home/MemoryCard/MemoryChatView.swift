//
//  MemoryChatView.swift
//  Harmony
//
//  Created by 한범석 on 7/17/24.
//

import SwiftUI

struct MemoryChatView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(message.date)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            HStack {
                                if message.sender == "모니" {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text(message.message)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    Spacer()
                                } else {
                                    Spacer()
                                    Text(message.message)
                                        .padding()
                                        .background(Color.green.opacity(0.6))
                                        .cornerRadius(10)
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
            }
            HStack {
                NavigationLink(destination: Text("이어서 대화하기 뷰")) {
                    Text("이어서 대화하기")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("대화 전체 보기")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MemoryChatView(messages: dummyChatMessages)
}
