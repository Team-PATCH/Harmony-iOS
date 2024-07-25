//
//  RoutineReactionInputView.swift
//  Harmony
//
//  Created by 조다은 on 7/25/24.
//

import SwiftUI

struct RoutineReactionInputView: View {
    @State var dailyRoutine: DailyRoutine
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel

    @State private var newReaction: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()

            TextField("댓글을 입력해주세요.", text: $newReaction)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: {
                if !newReaction.isEmpty {
                    viewModel.addReactionToRoutine(to: dailyRoutine, content: newReaction)
                    newReaction = ""
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("작성 완료")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
            }

            Spacer()
        }
        .frame(height: 376)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct RoutineReactionRow: View {
    let author: String
    let comment: String
    let imageName: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(imageName)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(author)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    let viewModel = RoutineViewModel()
    let dailyRoutine = DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: Date(),
        completedPhoto: nil,
        completedTime: nil,
        createdAt: Date(),
        updatedAt: nil,
        deletedAt: nil
    )
    return RoutineReactionInputView(dailyRoutine: dailyRoutine, viewModel: viewModel)
}
