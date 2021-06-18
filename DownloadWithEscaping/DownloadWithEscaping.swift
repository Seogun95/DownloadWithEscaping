//
//  DownloadWithEscaping.swift
//  DownloadWithEscaping
//
//  Created by Seogun Kim on 2021/06/17.
//

import SwiftUI

//MARK: MODEL
struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

//MARK: VIEWMODEL
class DownloadWithEscapingViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    
    init() {
        getPosts()
    }
    
    
    func getPosts() {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        downloadData(fromURL: url) { returnedData in
            if let data = returnedData {
                //newPost는 옵셔널 이기 때문에 guard
                guard let newPosts = try? JSONDecoder().decode([PostModel].self, from: data) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.posts = newPosts
                }
            } else {
                print("반환될 데이터가 존재하지 않습니다.")
            }
        }
    }
    
    func downloadData(fromURL url: URL, complectionHandler: @escaping (_ data: Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard
                let data = data,
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                    print("데이터 다운로드에 실패했습니다.")
                    complectionHandler(nil)
                    return
                }
            complectionHandler(data)
        }
        .resume()
        
    }
}

//MARK: BODY
struct DownloadWithEscaping: View {
    @StateObject var vm = DownloadWithEscapingViewModel()
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.posts) { post in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(post.title)
                            .font(Font.title.bold())
                        Text(post.body)
                            .foregroundColor(Color(UIColor.systemGray2))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .navigationBarTitle("Fack API DATA")
            .listStyle(PlainListStyle())
        }
    }
}


//MARK: PREVIEWS
struct DownloadWithEscaping_Previews: PreviewProvider {
    static var previews: some View {
        DownloadWithEscaping()
    }
}
