function cookiesConfirmed() {
    // Hide the cookie message
    $('#cookie-footer').hide();
    // Set a date so the browser will persist the cookie for a year
    var d = new Date();
    d.setTime(d.getTime() + (365*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    // Add a cookie called cookies-accepted to the page
    document.cookie = "cookies-accepted=true;" + expires;
}
