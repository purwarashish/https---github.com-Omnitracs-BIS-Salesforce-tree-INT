/**
 * An apex page controller that exposes the site login functionality
 */
public class SiteLoginController {
    public String username {get; set;}
    public String password {get; set;}

    public PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    
    public SiteLoginController () {}
       
}