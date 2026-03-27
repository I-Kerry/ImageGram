
import XCTest

final class imageGramUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
        
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("")
//        webView.swipeUp()
        // MARK: лучше нажать самому на экран после введения логина, у меня на симуляторе только так можно было скрыть клавиатуру, которая на полэкрана(свайпа, рандомный тап по экрану, нажатие кнопки на самой клаве не помогали)
        loginTextField.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("")
        
        webView.buttons["Login"].tap()
        
        print(app.debugDescription)
        
        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        
        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        sleep(3)
        app.swipeUp()
        sleep(3)
        let cellLike = tableQuery.children(matching: .cell).element(boundBy: 1)
        cellLike.buttons["likeButton"].tap()
//        app.buttons["likeButton"].tap()
        sleep(3)
        cellLike.buttons["likeButton"].tap()
//        app.buttons["likeButton"].tap()
        sleep(3)
        cellLike.tap()
        sleep(4)
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        let buttonBack = app.buttons["backButton"]
        buttonBack.tap()
//        app.buttons.firstMatch.tap()
    }
    
    func testProfile() throws {
        let table = app.tables
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
//        let image = app.images.children(matching: .image).element(boundBy: 0)
//        XCTAssertTrue(image.exists)
        sleep(2)
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["loginName"].exists)
        XCTAssertTrue(app.staticTexts["discription"].exists)
        
        let logoutButton = app.buttons["logoutButton"]
        logoutButton.tap()
        app.alerts["Bye, bye"].scrollViews.otherElements.buttons["Yes"].tap()
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.exists)
    }
}
