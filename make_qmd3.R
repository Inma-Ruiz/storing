make_qmd3 <- function(docx_path) {
  
  # store charts/pictures
  media_dir <- here::here("output")
  
  if (!dir.exists(media_dir)) {
    dir.create(media_dir, recursive = TRUE)
  }
  
  # temporary markdown file
  temp_md <- tempfile(fileext = ".md")
  on.exit(unlink(temp_md))
  
  # pandoc arguments
  args <- c(
    shQuote(docx_path),
    paste0("--extract-media=", shQuote(media_dir)),
    "-o", shQuote(temp_md)
  )
  
  # run pandoc
  pandoc_path <- file.path(rmarkdown::find_pandoc()$dir, "pandoc.exe")
  result <- system2(
    pandoc_path,
    args,
    stdout = TRUE,
    stderr = TRUE
  )
  
  if (!file.exists(temp_md)) {
    stop(
      "pandoc conversion failed:\n",
      paste(result, collapse = "\n")
    )
  }
  
  # read markdown
  content_lines <- readLines(temp_md, warn = FALSE)
  
  # force image paths to be relative
  content_lines <- gsub(
    "\\((.*[/\\\\])?media[/\\\\]",
    "(media/",
    content_lines
  )
  
  # replace split width/height image attributes with {width=100%}
  clean_lines <- character()
  i <- 1
  
  while (i <= length(content_lines)) {
    
    current <- content_lines[i]
    
    if (
      grepl("^!\\[\\]\\(", current) &&
      grepl("\\{width=", current) &&
      i < length(content_lines) &&
      grepl("^height=", trimws(content_lines[i + 1]))
    ) {
      
      current <- sub(
        "\\{width=.*$",
        "{width=100%}",
        current
      )
      
      clean_lines <- c(clean_lines, current)
      
      # skip the height line
      i <- i + 2
      
    } else {
      
      clean_lines <- c(clean_lines, current)
      i <- i + 1
      
    }
  }
  
  content_lines <- clean_lines
  
  # YAML front matter. Change it if you need different features
  front_matter <- c(
    "---",
    'title: "Title of the HTML Document"',
    "execute:",
    "  echo: false",
    "fig-cap-location: top",
    "format:",
    "  html:",
    '    title-block-banner: "header_image.svg"',
    "toc: true",
    'toc-title: "Contents"',
    "title-block-banner: true",
    "toc-depth: 3",
    "toc-location: left",
    "embed-resources: true",
    "css: style.css",
    "---"
  )
  
  # combine yaml + content
  output_lines <- c(
    front_matter,
    "",
    content_lines
  )
  
  # write qmd
  writeLines(
    output_lines,
    here::here("output", "report_to_render.qmd")
  )
  
  return(here::here("output"))
}