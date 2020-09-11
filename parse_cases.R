library(rvest)
library(RSelenium)
library(stringr)
library(tidyverse)

#start a browser 
driver <- rsDriver(port = 4445L, browser = "firefox")
remDr <- driver[["client"]]

#load links
caseLinks <- readRDS("raw_data/caselinks.rds")
caseLinks <- unlist(caseLinks)

#navigate to the first link. it will open all the cases 
#and we will be able to switch between them 
remDr$navigate(caseLinks[1])

#parse data
text = list()
meta = list()
counter = ""
for (i in 1:2431) {
    webElem <- remDr$findElement("css selector", "iframe")
    remDr$switchToFrame(webElem)
    doc <- remDr$getPageSource()
    text[[i]] <- 
      unlist(doc) %>% 
      read_html() %>%
      html_nodes("p") %>%
      html_text()
    remDr$switchToFrame(NULL)
    doc <- remDr$getPageSource()
    meta[[i]] <- 
      unlist(doc) %>% 
      read_html() %>%
      html_nodes(".value-inner") %>%
      html_text()
    counter[i] <-
      unlist(doc) %>% 
      read_html() %>%
      html_nodes(".result-counter") %>%
      html_text()
    forward_button <- remDr$findElement("css selector", "span.to-right-red.forward-btn.yui-button.yui-btn-32")
    forward_button$clickElement()
    Sys.sleep(10)
  }

### stop the server ### 
driver$server$stop()

#save parsed data 
write_rds(text, "clean_data/cases_text_raw.rds")

# write parsed data to txt file (sample of first 100 cases)
for (i in 1:100) {
  write.table(text[[i]], paste0("clean_data/case", i, ".txt"))
}

# merge in terminal. command "cat *.txt > cases.txt"