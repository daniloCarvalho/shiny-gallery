#! /usr/bin/env Rscript

# read appUrl argument
args <- commandArgs(TRUE)
if (length(args) != 2)
  stop("Usage: ./import.R <code-path> <application-url>")
codePath <- args[1]
appUrl <- args[2]

# Emit an error if the file is missing required fields or has values 
# incompatible with the gallery (i.e. the app must be set to be visible
# in showcase mode)
message("Checking DESCRIPTION... ", appendLF = FALSE)
descFile <- file.path(codePath, "DESCRIPTION")
if (!file.exists(descFile)) {
  stop("Shiny Gallery applications must have a DESCRIPTION file (expected at ", 
       descFile)
}
desc <- read.dcf(descFile)
requiredCols <- c("Title", "Author", "AuthorUrl", "License", "DefaultShowcaseMode")
missingCols <- setdiff(requiredCols, colnames(desc))
if (length(missingCols) > 0) {
  stop("DESCRIPTION file is missing required field(s): ", 
       paste(missingCols, collapse = ", "))
}

if (as.numeric(desc[1,"DefaultShowcaseMode"]) != 1) {
  stop("Shiny Gallery applications must set DefaultShowcaseMode: 1 in the DESCRIPTION file.")
}

if (desc[1,"License"] != "MIT") {
  stop("Shiny Gallery application code must be released under the MIT license.")
}

message("OK")

# Hit the app URL to make sure it returns something that looks vaguely 
# like a Shiny app 
message("Testing app URL... ", appendLF = FALSE)
conn <- url(appUrl, open="r")
contents <- paste(readLines(conn, 25))
if (length(grep("shiny.js", contents)) == 0) {
  stop(appUrl, " doesn't appear to be a Shiny application.")
}
message("OK")

# Download the application's source files (ui.R, server.R, and global.R as 
# well as any files included in the Sources field of the DESCRIPTION).
# Verify that their line widths are <= 65. 
message("Checking code formatting: ")
files <- c("ui.R", "server.R", "global.R")
if ("Sources" %in% colnames(desc)) {
  files <- c(files, unlist(strsplit(desc[1,"Sources"], "\\s*,\\s*")))
}
files <- file.path(codePath, files)
files <- files[file.exists(files)]

for (file in files) {
  # Treat tabs as two spaces for indent
  lines <- gsub("\t", "  ", readLines(file))
  lineNum <- 0
  message("    ", file, "... ", appendLF = FALSE)
  for (line in lines) {
    lineNum <- lineNum + 1
    if (nchar(line) > 65) {
      stop("Found line over 65 characters long in ", file, ":\n", lineNum, ":", line, 
           "\n", "Lines longer than 65 characters may be wrapped in side-by-side view.")
    }
  }
  message("OK")
}

# Create an anonymous gist containing the source files using the ruby
# gist utility

# Check to see if the app's source contains a thumbnail.png, and take a
# snapshot with phantom.js if it doesn't; either way, save the thumbnail to
# images/thumbnails

# Write the post .md file based on the contents of DESCRIPTION. Note that
# if this is an update of an existing application we should be sure to 
# overwrite that .md rather than create a new one.


