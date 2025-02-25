#設計模式相關問題  
##1. MVVM 和 MVC 的比較  
###◦ 問題:請解釋 MVVM 與 MVC 的區別,以及在 iOS 開發中何時使用哪一種架構?  
Ans.  
    MVC (Model-View-Controller)  
    Model: 處理資料來源的結構和相關自身邏輯  
    View: UI  
    Controller: `Model`跟`View`之間的呈現  
      
    MVVM (Model-View-ViewModel)  
    Model: 處理資料來源的結構和相關自身邏輯  
    View: UI  
    ViewModel: 在`ViewModel`中處理`Model`需要在`View`中顯示的資料，讓`View`可以單純地透過`ViewModel`提供的資料直接綁定在畫面上，`View`不用處理任何關於資料的邏輯。  
      
    iOS新專案目前皆慢慢趨向使用MVVM pattern來開發，因為`RxSwift`及`Combine`的流行，讓專案用綁定Reactive的方式減少耦合。  
    讓不同的`View`之間可以共用同一個`ViewModel`，來方便測試、減少彼此的耦合。  
      
###◦ MVVM 如何與 Combine 整合?  
Ans.  
    因為本人目前只有實作過`RxSwift`，所以用`RxSwift`來舉例，但與`Combine`之間邏輯基本上是一樣的。  
      
    假設現在有一個簡單的畫面邏輯，一個`View`裡面有個`UITextField`可以供使用者點擊後只能輸入數字，這些輸入的數字代表幫使用者骰幾個骰子，在畫面輸出骰出的數字總和`UILabel`。  
    首先initial一個`ViewModel`，他的初始化我會新增兩個變數`input`和`output`，這兩個變數用來處理`View`層傳來的相關參數。  
    根據上面的舉例，`input`會新增一個`Observer`來監聽傳入的數字參數(命名`inputCount`)，`output`會新增一個`String`型別的`Observer`(命名`outputSum`)。  
    這時在`View`層只需要綁定`UITextField`和`viewModel.input.inputCount`、顯示的`UILabel`和`viewModel.output.outputSum`，不在`View`層處理任何邏輯。  
    `ViewModel`中監聽`input.inputCount`傳來的參數，並在裡面做可能的防呆處理邏輯，並綁定`inputCount`和`outputSum`，把處理完的數字傳給`outputSum`即可。  
      
    這時`View`層不用管`ViewModel`裡面的任何邏輯，我們也可以把這個`ViewModel`拿去其他可能會使用到這個功能的其他畫面，以此方式實現低耦合的pattern design。  
      
  
##2. 單例模式的應用與風險  
###◦ 問題:描述單例模式在 iOS 中的常見應用場景,以及其潛在的風險與如何避免。  
Ans.  
    `Singleton`獨立於所有的畫面`View`之外，存在於全域的狀態，因此通常有機會會在所有地方被用到，舉凡  
    1. 執行網路請求: 除了單純的Request之外，`AuthorizationToken`之類的也可以直接更新或使用。  
    2. 多語系/幣別/UI: 可以把使用者所偏好的各種設置，存在一個`Singleton`中，讓任何需要此參數的畫面可以統一獲取。  
      
    但也因為`Singleton`全域可取得的原因，造成多個`Singleton`互相依賴的狀況也有可能發生，在A單例中使用B單例的參數，導致彼此耦合而測試困難也難以閱讀。  
    因為需要規範如果會發生這個狀況，有可能A和B單例中相互使用的參數或邏輯，可以拉到其中一方統一控管或是合併。  
      
##3. 依賴注入(Dependency Injection)  
###◦ 問題:在 iOS 開發中,如何使用依賴注入來降低模組間的耦合?請舉例說明。  
Ans.  
    在新增一個`Class`時，不要在每一個類似相同的`Class`去宣告初始一個同樣的`ViewModel`，讓這些相似的`Class`在初始的時候，把這個`ViewModel`當成此`Class`初始化的必要參數，讓這個`ViewModel`可以獨立於所有相似`Class`之外。  
    避免每個`Class`去新增雷同的`ViewModel`，導致重複的`ViewModel`類型。  
      
      
      
#性能優化相關問題  
##1. 啟動時間優化  
###◦ 問題:假設一個 App 的啟動時間過長,您會如何進行性能分析並優化?  
Ans.  
    會使用Xcode的`Instruments`的`Time Profiler`來檢查是哪一部分花費較多時間，錄製當下啟動時到完整顯示畫面的階段，檢查是哪一段`method`拖延到了顯示時間。  
    當檢查出特定`function`時，在針對此`function`做優化，除了演算法之外也要調整在`AppDelegate`中`didFinishLaunchingWithOptions`做會阻塞主線程的request，  
    把這些會在主線程拖延的API獲取、資料解析用`global`非同步處理的方式，處理解析完畢後再用`main`來確實刷新主線程的UI。  
      
  
##2. 滾動性能優化  
###◦ 問題:在 UITableView 顯示大量圖片時,滾動體驗不流暢。您會如何進行調試和優化?  
Ans.  
    1. 用非同步的方式來加載各個`UITableViewCell`中的`UIImageView`，取得圖片 data 後，再到主線程刷新  
    ```  
    DispatchQueue.global(qos: .background).async {  
        guard let data = try? Data(contentsOf: URL(string: "")!) else { return }  
        let image = UIImage(data: data)  
        DispatchQueue.main.async {  
            cell.imageView?.image = image  
        }  
    }  
    ```  
      
    2. 若圖片是此畫面的主要顯示目標的話，除了先加上placeholder之外，也會推薦相關套件來顯示些動畫skeleton效果。  
  
  
##3. 內存管理  
###◦ 問題:如何檢測和解決 iOS App 中的內存洩漏問題?請描述 Instruments 的具體使用方法。  
Ans.  
    跟前述的檢查啟動時間問題一樣，`command+i`打開`Instruments`>`Leaks`，錄製需要檢查的畫面跳轉切換或是互動後，檢查紅色X的段落，查看`Call Tree`中哪一個`Class`的`function`有異常沒有被釋放。  
    要解決內存洩漏的方式除了要適時地釋放物件外，平常編寫時遇到所有的`closure`都要加上`weak self`避免物件在釋放後還持有對方的reference。  
      
  
#測試相關問題  
##1. 單元測試與 UI 測試  
###◦ 問題:在 iOS 開發中,如何有效地編寫單元測試?請舉例。  
Ans.  
    測試的時候，模擬使用者的各個動作來寫成各個測試`funcion`。  
    比方說App啟動、取得API、解析API回傳特定格式Model、用戶點擊各個按鈕、用戶下拉刷新動作等等，都可以寫成單一個`function`，來確保各個動作都是獨立運作並測試是否會輸出正確的資料。  
  
##2. Mock 與 Stub 的應用  
###◦ 問題:如何在網絡請求中使用 Mock 或 Stub 來測試?  
Ans.  
    在測試的時候新增不同個本地的測資檔案，模擬正確或是錯的的測試資料是否被正確的解析。  
    比方現在要測試首頁，首頁是根據API回傳的`json`來顯示排版，現在新增一個錯誤的格式來模擬後台因為更新而回傳新版的`json`格式，會用假的本地測資來讓測試的`function`執行，是否會解析成功或是報錯。  
  
##3. 測試驅動開發(TDD)  
###◦ 問題:在 iOS 開發中,如何應用 TDD? 它的優缺點是什麼?  
Ans.  
    主要的核心就是先寫測試再寫code，一步一步在錯誤後進行重構來完成整個功能邏輯。  
    優點: 從初始到完成都有經過測試，較完整  
    缺點: 慢，因為要一小塊一小塊來完成  
      
#架構設計相關問題  
##1. 模組化與微服務架構  
###◦ 問題:在大型 iOS 項目中,如何進行模組化設計?如何在不同模組間進行通信?  
Ans.  
    可以將這個整體大項目切成好幾個區塊，把各自功能獨立出來，把每個獨立成一個Project/Frameworks。  
    如此一來除了當前在進行的專案以外，如果要開發一個新的項目，就可以使用新項目的`workspace`來把需要使用的功能加進`submodules`中。  
    例如網路請求、登入登出模組之類  
      
  
##2. 動態功能更新  
###◦ 問題:如何設計一個支援動態功能更新的 App,例如通過伺服器控制某些功能的開關?  
Ans.  
    我會把這個功能寫在`Singleton`的其中參數之中，當此`View`會根據`Singleton`的某`Bool`參數來顯示按鈕。  
    當使用者Trigger此畫面的某個動作(切換或是下拉刷新)時，request API後得到此`Bool`的參數後同時更新`Singleton`的參數，再根據`View`綁定的結果來更新畫面。  
    或是這個App有使用`WebSocket`跟後段做實時連線，也可以在這個連線的回傳中新增一個參數來即時更新此`Singleton`的`Bool`參數。  
  
##3. 離線模式設計  
###◦ 問題:如何設計一個支援離線模式的 App,例如在沒有網絡時,仍能瀏覽已加載的內容?  
Ans.  
    根據我在中國人壽客戶端的例子，我會這樣設計  
    1. 使用`json`來儲存顯示畫面時，透過API獲取的原始資料，其中會加上`TimeStamp`來註記此份資料的版本，再根據之後聯網後得到新的資料在做替換儲存。  
    2. 使用DB(RealmDB)來控管重要使用者資料，利用登入後檢查此使用者儲存在後端的資訊，檢查是否和本地端是相同與否，來下載更新本地離線DB，或是更新線上後台資料。  
    3. 使用Cache，來簡單記錄使用者的某些特定行為，比方說使用者頭貼或是畫面的偏好設定。  
  
##4. 多語言支援與本地化  
###◦ 問題:如何設計一個支援多語言的 iOS App?如何處理動態語言切換?  
Ans.  
    1. 使用`.strings`和`.xcstrings`來控管，會根據系統設置來顯示對應語言字串。  
    2. 使用一個`Singleton`來全域控管使用者當前的語言設置，新增一個`String`的`extension`來根據當前`Singleton`的設置回傳對應語言，要使用哪一個`.strings`語言檔。  
      
      
#開放式問題  
##1. 技術選型  
###◦ 問題:如果需要在一個 App 中引入一個新的第三方庫,您會如何評估這個庫是否合適?  
Ans.  
    1. 先查看這個三方套件是不是有人在維護，和他有幾個星星  
    2. 評估是否要因為某一個小功能而導致引入這個三方套件的容量會不會太大。  
      
  
##2. 實際問題解決  
###◦ 問題:描述您在過去的項目中遇到的最大挑戰,以及您是如何解決的。  
Ans.  
    過去遇到需要接一個新公司A的API，但A公司的給的資料回傳相當不符合iOS/Android的處理邏輯，也因為A公司後端不願意更改的們過時的SPEC，導致接起來相當痛苦。  
    時程的壓力也只能協同Android同事一起解析這個API格式，並同時記錄下相關文件，最終才慢慢根據這份文件整理出來相關功能。  
  
  
##3. 技術趨勢  
###◦ 問題:對於當前 iOS 開發中的新技術(如 SwiftUI 或 Async/Await),您有什麼看法?它們如何影響開發方式?  
Ans.  
    以SwiftUI來說，通常開發一個項目要考慮到使用者的iOS版本，需要向下相容到較舊版本的iOS，所以幾年前仍然以Swift為大宗。  
    但因為iOS慢慢更新，兩三年後SwiftUI會慢慢越來越吃重，可能越來越多開發者會偏好使用SwiftUI。  
    再從開發角度切入，SwiftUI與Combine結合，Reactive的方式也越來越淺顯易懂開發及偵錯都相對簡潔。  
      
    以async和await來說，可以大幅提升閱讀性，減少`closure``callback`的使用。  
      
    也許當下新的技術釋出的時候還用不太到(版本/專案不支援)，也因為剛釋出可能會有Bug，但根據時間除錯後，遲早會更新及需要新項目開發，學習新的技術對開發是相當好的。  
