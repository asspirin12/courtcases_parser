library(tidyverse)
library(rvest)
library(httr)
library(RSelenium)

# open https://bsr.sudrf.ru/bigs/portal.html and enter parameters 
# (in this case we're looking for "уголовные дела" with "экономическая экспертиза") 
# generate and copy a link
# enter data for PAGES (how many pages in search results)
# enter data for CASES (how many cases in search results)

PAGES <- 266
CASES <- 2651
cases_on_a_page <- 10 #always

#get links for all the pages
x <- seq(0, CASES, cases_on_a_page)  
pageLinks <- paste0("https://bsr.sudrf.ru/bigs/portal.html#%7B%22type%22:%22MULTIQUERY%22,%22multiqueryRequest%22:%7B%22queryRequests%22:%5B%7B%22type%22:%22Q%22,%22queryRequestRole%22:%22SIMPLE%22,%22request%22:%22%7B%5C%22query%5C%22:%5C%22%D1%8D%D0%BA%D0%BE%D0%BD%D0%BE%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B0%D1%8F%20%D1%8D%D0%BA%D1%81%D0%BF%D0%B5%D1%80%D1%82%D0%B8%D0%B7%D0%B0%5C%22,%5C%22type%5C%22:%5C%22NEAR%5C%22,%5C%22mode%5C%22:%5C%22SIMPLE%5C%22%7D%22,%22operator%22:%22AND%22%7D,%7B%22type%22:%22SQ%22,%22queryId%22:%227f9e8ff8-4bc8-46aa-bcbd-f2b3ed5f159f%22,%22operator%22:%22AND%22%7D%5D%7D,%22sorts%22:%5B%7B%22field%22:%22case_common_doc_result_date%22,%22order%22:%22desc%22%7D%5D,%22simpleSearchFieldsBundle%22:%22test24%22,%22groups%22:%5B%22%D0%A3%D0%B3%D0%BE%D0%BB%D0%BE%D0%B2%D0%BD%D1%8B%D0%B5%20%D0%B4%D0%B5%D0%BB%D0%B0%22%5D,%22start%22:", x,"%7D")

#start firefox
driver <- rsDriver(port = 4444L, browser = "firefox")
remDr <- driver[["client"]]

#parse links 
caseLinks <- lapply(
  1:PAGES,
  function(i) {
    remDr$navigate(pageLinks[i])
    Sys.sleep(30)
    doc <- remDr$getPageSource()
    unlist(doc) %>% 
      read_html() %>%
      html_nodes(".bgs-result .openCardLink") %>%
      html_attr("href") %>%
      unique(.)
  }
)

# stop the server
driver$server$stop()

#write links data to RDS
write_rds(caseLinks, "raw_data/caselinks.rds")


# #repeat for empty elemenets 4,6 54
# driver <- rsDriver(port = 4444L, browser = "firefox")
# remDr <- driver[["client"]]
# 
# remDr$navigate(pageLinks[6])
# doc <- remDr$getPageSource()
# x <- unlist(doc) %>% 
#   read_html() %>%
#   html_nodes(".bgs-result .openCardLink") %>%
#   html_attr("href") %>%
#   unique(.)
# caseLinks[[243]] <- x
# #driver$server$stop()
# 
# lapply(
#   1:242,
#   function (i) {
#     keep(caseLinks[[i]], grepl("c345b86edede19553233f879a64adfe4", caseLinks[[i]]))
#     }
# ) 