//
//  ProfileRegisterView.swift
//  Harmony
//
//  Created by 한수빈 on 7/24/24.
//

import SwiftUI

struct ProfileRegisterView: View {
    @Binding var path: [String]
    @State private var relationship: String = ""
    @State private var name: String = ""
    @State private var profileImage: Image?// = Image(systemName: "3.circle")

    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("마지막으로")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("프로필 사진을 설정해요")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text("할머니에게 보여질\n프로필 사진을 설정해 주세요.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .lineSpacing(4)
                

                Spacer()
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.gray2)
                            .frame(width: 200, height: 200)
                        
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray4)
                        }
                        
                        Image("camera")
                            .frame(width: 70, height: 70)
                            .background(Color.green)
                            .clipShape(Circle())
                            .offset(x: 70, y: 70)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                NavigationLink(destination: UserInfoEntryView(path: $path)) {
                    Text("다음")
                        .font(.pretendardSemiBold(size: 18))
                        .foregroundColor(.wh)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        //.background(!relationship.isEmpty && !name.isEmpty ? Color.mainGreen : Color.gray3)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.wh)
        }
    }

}

#Preview {
    ProfileRegisterView(path: .constant([]))
}
