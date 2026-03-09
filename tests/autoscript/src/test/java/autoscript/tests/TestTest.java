package autoscript.tests;

import autoscript.base.BaseTest;
import com.microsoft.playwright.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class TestTest extends BaseTest {

    @Test
    @Order(1)
    void step01_step1() {
        page.navigate("https://demo.comes.co.kr/todo");
        page.waitForLoadState(com.microsoft.playwright.options.LoadState.NETWORKIDLE);

        try { page.locator("xpath=//input[@id=\"todo-title\"]").first().fill("ㅅㅅㅅ"); }
        catch (Exception e) { /* navigation or element not found */ }
    }

    @Test
    @Order(2)
    void step02_step1() {
        page.navigate("https://demo.comes.co.kr/todo");
        page.waitForLoadState(com.microsoft.playwright.options.LoadState.NETWORKIDLE);

        try { page.locator("xpath=//input[@id=\"todo-title\"]").first().fill("새로운 할일"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//textarea[@id=\"todo-desc\"]").first().fill("할일 설명"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"추가\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"전체\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"진행중\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//button[normalize-space()=\"완료\"]").first().click(); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//select[@id=\"todo-priority\"]").first().selectOption("high"); }
        catch (Exception e) { /* navigation or element not found */ }
        try { page.locator("xpath=//input[@placeholder=\"검색...\"]").first().fill("할일"); }
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
