//
//  ProjectListView.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI
import SwURL
import FASwiftUI

struct ProjectListView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var userService: UserService = UserService()
    @ObservedObject var avatarService: AvatarService = AvatarService()
    @ObservedObject var projectListViewModel = ProjectListViewModel()
    @State var showForm = false
    @State var showAlert = false
    @State var showProfileSheet = false
    @State var fullName = ""
    
    init(authService: AuthService) {
        self.authService = authService
        guard let uid = authService.user?.uid else {
            return
        }
        self.userService.fetchUserBy(id: uid)
        self.avatarService.fetchAvatar(userId: uid)
    }
    
    var leadingItem: some View {
        HStack{
            Menu(content: {
                Button(action: { showProfileSheet = true }) {
                    Text("Profile")
                    Image(systemName: "person.crop.square")
                }
                Divider()
                Button(action: { showAlert = true }) {
                    Text("Sign Out")
                    Image(systemName: "figure.walk")
                }
            }, label: {
                RemoteImageView(url: avatarService.avatarUrl ?? URL(string: "https://www.americasfinestlabels.com/images/CCS400FO.jpg")!, placeholderImage: Image("placeholder"), transition: .custom(transition: .opacity, animation: .easeOut(duration: 0.5))).imageProcessing({image in
                    return image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }).frame(width: 40, height: 40)
                //                Image("avatar")
                //                    .resizable()
                //                    .frame(width: 40, height: 40)
                //                    .clipShape(Circle())
            }).frame(width: 40, height: 40)
            Text("\(fullName)")
                .font(.body)
                .foregroundColor(Color(.systemGray))
        }.sheet(isPresented: $showProfileSheet){
            ProfileSheet(authService: self.authService, userService: self.userService, avatarService: self.avatarService)
        }
        
    }
    
    var body: some View {
        NavigationView {
            VStack{
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        VStack(spacing: 24) {
                            ForEach(projectListViewModel.projectViewModels) { projectViewModel in
                                ProjectView(projectViewModel: projectViewModel, projectListViewModel: projectListViewModel)
                                    .padding([.leading, .trailing]).padding(.bottom, 12).animation(.easeIn)
                            }
                        }.frame(width: geometry.size.width, height: 124.0*CGFloat(projectListViewModel.projectViewModels.count))
                    }
                }
            }
            .sheet(isPresented: $showForm) {
                NewProjectSheet(projectListViewModel: projectListViewModel)
            }
            .navigationBarTitle("My Projects")
            .navigationBarItems(leading: leadingItem,
                                trailing:
                                    Button(action: { showForm.toggle() }) {
                                        FAText(iconName: "plus", size: 26)
                                    })
        }.navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Sign out?"), message: Text(""), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Yes"), action: {
                showAlert = false
                do {
                    try AuthService.signOut()
                    
                } catch {
                    
                }
            }))
        }.onReceive(userService.$user, perform: { user in
            fullName = ((user?.firstName ?? "") + " " + (user?.lastName ?? "")).trimmingCharacters(in: .whitespaces)
        })
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView(authService: AuthService())
    }
}

