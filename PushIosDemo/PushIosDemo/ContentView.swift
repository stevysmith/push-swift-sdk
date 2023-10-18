import Push
import SwiftUI
import WalletConnectSign

struct ContentView: View {
  @State private var showAlert = false

  var body: some View {
    VStack {
      Text("Push Sdk Demo")
        .font(.title)
        .padding()

      Button(action: {
        showAlert = false
        //        connect()
        Task {
          await connect()
        }
      }) {
        Text("Conect Wallet Connect")
          .font(.headline)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
      .padding(.horizontal, 40.0)
      .alert(isPresented: $showAlert) {
        Alert(
          title: Text("Alert"), message: Text("Button clicked!"),
          dismissButton: .default(Text("OK")))
      }
    }
  }
}

func connect() async {
  do {
      let user: PushUser?
      
      if let _user = try await PushUser.get(
        account: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c", env: .STAGING) {
          user = _user
          var name = _user.profile.name ?? "User found: No Name"
          print("got user")
      } else {
          let newUser = try await PushUser.createUserEmpty(userAddress: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c", env: .STAGING)
              var name = newUser.profile.name ?? "User found: No Name"
          user = newUser
          print("created user")
      }
      
      let signer = try SignerPrivateKey(
          privateKey: "0xd5071223dcbf1cb824090bd98e0ddc807be00f1874fdd74bbd9225773a824123"
      )
      
      let typedSigner = try TypedSignerPrivateKey(privateKey: "0xd5071223dcbf1cb824090bd98e0ddc807be00f1874fdd74bbd9225773a824123")
      
      let pgpPrivateKey:String = try await PushUser.DecryptPGPKey(
       encryptedPrivateKey: user!.encryptedPrivateKey,
       signer: signer
     )
      
      let result:Bool = try await PushChannel.subscribe(
          option: PushChannel.SubscribeOption(
              signer: typedSigner,
              channelAddress: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c",
              env: .STAGING))
      
      let chats:[PushChat.Feeds] = try await PushChat.getChats(
        options: PushChat.GetChatsOptions(
          account: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c",
          pgpPrivateKey: pgpPrivateKey,
          toDecrypt: true,
          page: 1,
          limit: 5,
          env: ENV.STAGING
        ))
    
    print(user)
  } catch {
    print(error)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
