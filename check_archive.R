library(rvest)
library(magrittr)
library(readr)

archive = read_csv("archive.csv", col_names = F)

names(archive) = c('Time', 'Title_url', 'Archive_url', 'Title')
archive$Time = substr(archive$Time, 5, nchar(archive$Time))
archive$Time = parse_datetime(archive$Time, format = "%b %d %H:%M:%S %Y")
archive$Time = archive$Time + 8*60*60

archive = archive[!duplicated(archive$Archive_url), ]
archive = archive[!is.na(archive$Title_url), ]

archive = archive[seq(dim(archive)[1],1),]

Get_title = function(url){
  tryCatch({
    read_html(url) %>%
      html_nodes("title") %>%
      html_text() %>%
      trimws()
  }, error = function(e) {
    print('check failure')
  })
}

N = ifelse(nrow(archive) >= 30, 30, nrow(archive))
archive = archive[1:N, ]

archive$check = sapply(archive$Title_url, Get_title)
archive$check = as.character(archive$check)
write.csv(archive, "archive2.csv", row.names = F)
