library(tidyverse)
library(RSelenium)

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444L,
  browserName = "chrome"
)

webElem$sendKeysToElement(list("R Cran", key = "enter"))

remDr$close()
remDr$open()

remDr$navigate("https://www.ouedkniss.com/automobiles/1?hasPrice=true")

webElem <- remDr$findElement("css", "body")
webElem$sendKeysToElement(list(key = "end"))

webElems <- remDr$findElements(using = "css", "h2")[-1]

listings_titles <- unlist(lapply(webElems, function(x) {x$getElementText()}))

listings_titles

webElems[[1]]$clickElement()

webElems[[2]]

x = list(1,2,3)

webElem <- remDr$findElements(using = "class", value = "mx-2")

listings <- unlist(lapply(webElem, function(x) {x$getElementText()}))
