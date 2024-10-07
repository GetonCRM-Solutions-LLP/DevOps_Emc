var meta = document.createElement("meta");
meta.setAttribute("http-equiv", "Content-Security-Policy");
meta.setAttribute("content", "upgrade-insecure-requests");
document.getElementsByTagName('head')[0].appendChild(meta);