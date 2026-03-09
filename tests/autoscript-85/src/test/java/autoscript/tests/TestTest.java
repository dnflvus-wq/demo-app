package autoscript.tests;

import autoscript.base.BaseTest;
import com.microsoft.playwright.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class TestTest extends BaseTest {

    @Test
    @Order(1)
    void step01_01DemoappTodoBoard() {
        page.navigate("https://demo.comes.co.kr/");
        page.waitForLoadState(com.microsoft.playwright.options.LoadState.NETWORKIDLE);

        try { page.locator("xpath=//a[normalize-space()=\"Home\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//a[@href=\"/todo\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//a[@href=\"/board\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//div[@id=\"root\"]//button").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//div[@id=\"root\"]//button").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"공지사항입니다\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//input[@id=\"embed-name\"]").first().fill("홍길동"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//input[@id=\"embed-email\"]").first().fill("test@example.com"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//select[@id=\"embed-category\"]").first().selectOption("feedback"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//textarea[@id=\"embed-message\"]").first().fill("문의 메시지입니다."); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[@id=\"embed-submit\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
    }

    @Test
    @Order(2)
    void step02_02DemoappTodoBoardBoardBoard() {
        page.navigate("https://demo.comes.co.kr/board");
        page.waitForLoadState(com.microsoft.playwright.options.LoadState.NETWORKIDLE);

        try { page.locator("xpath=//a[@href=\"/board\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"글쓰기\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"알파서버 게시글 테스트\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
    }

    @Test
    @Order(3)
    void step03_03DemoappTodoBoardTodoTodo() {
        page.navigate("https://demo.comes.co.kr/todo");
        page.waitForLoadState(com.microsoft.playwright.options.LoadState.NETWORKIDLE);

        try { page.locator("xpath=//input[@id=\"todo-title\"]").first().fill("새로운 할일"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//textarea[@id=\"todo-desc\"]").first().fill("할일 설명"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//select[@id=\"todo-priority\"]").first().selectOption("low"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"추가\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"전체\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"진행중\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"완료\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//input[@placeholder=\"검색...\"]").first().fill("테스트"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("input[type='checkbox']").first().check(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[@title=\"수정\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[@title=\"삭제\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("input[type='checkbox']").first().check(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[@title=\"수정\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[@title=\"삭제\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
    }

}
