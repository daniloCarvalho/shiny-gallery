#! /usr/bin/env Rscript

# read appUrl argument
args <- commandArgs(TRUE)
if (length(args) < 2)
  stop("Usage: ./import.R <code-path> <application-url> [<code-url>]\n", 
       "   code-path - path to application on disk (local)\n", 
       "   application-url - URL to deployed application (http or https) \n",
       "   code-url - optional; URL to hosted code. If missing, a gist will be created.")
codePath <- args[1]
appUrl <- args[2]

# Emit an error if the file is missing required fields or has values 
# incompatible with the gallery (i.e. the app must be set to be visible
# in showcase mode)
message("Checking DESCRIPTION... ", appendLF = FALSE)
descFile <- file.path(codePath, "DESCRIPTION")
if (!file.exists(descFile)) {
  stop("Shiny Gallery applications must have a DESCRIPTION file (expected at ", 
       descFile, ")")
}
desc <- read.dcf(descFile)
requiredCols <- c("Title", "Author", "AuthorUrl", "License", 
                  "DefaultShowcaseMode", "AllowShowcaseModeOverride", 
                  "Type", "Tags")
missingCols <- setdiff(requiredCols, colnames(desc))
if (length(missingCols) > 0) {
  stop("DESCRIPTION file is missing required field(s): ", 
       paste(missingCols, collapse = ", "))
}

requiredVals <- list(
  DefaultShowcaseMode = "1", 
  License = "MIT", 
  AllowShowcaseModeOverride = "TRUE",
  Type = "ShinyShowcase")

for (i in 1:length(requiredVals)) {
  if (desc[1,names(requiredVals)[i]] != requiredVals[i]) {
    stop("Incorrect value for ", names(requiredVals)[i], ": expected ", 
         requiredVals[i], ", actual ", desc[1, names(requiredVals[i])])
  }
}

message("OK")

# Create a filename-friendly version of the title. 
# In: "Hello, World!"  -> Out: "hello-world"
appKey <- tolower(desc[1,"Title"])
# Convert non-alphanumeric (word) characters to dashes
appKey <- gsub("\\W", "-", appKey)
# Collapse sequences of dashes to a single dash
appKey <- gsub("-+", "-", appKey)
# Don't begin or end with a dash
appKey <- gsub("^-|-$", "", appKey)

# Hit the app URL to make sure it returns something that looks vaguely 
# like a Shiny app. 
# TODO: Use downloader package instead
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
      stop(nchar(line), "-character line found in ", file, ":\n", lineNum, ":", line, 
           "\n", "Lines longer than 65 characters may be wrapped in side-by-side view.")
    }
  }
  message("OK")
}

# Check to see if the app's source contains a thumbnail.png, and take a
# snapshot with phantom.js if it doesn't; either way, save the thumbnail to
# images/thumbnails
thumbnailSrc <- file.path(codePath, "thumbnail.png")
thumbnailDest <- file.path("..", "images", "thumbnails", 
                           paste(appKey, ".png", sep=""))

if (file.exists(thumbnailSrc)) {
  message("Using included thumbnail ", thumbnailSrc, "... ", appendLF = FALSE)
  file.copy(thumbnailSrc, thumbnailDest)
  message("OK")
} else {
  message("Taking a screenshot for a thumbnail (takes 20 seconds)... ", appendLF = FALSE)
  result <- system(paste("../_dependencies/phantomjs-1.9.2 screenshot.js ", 
                         appUrl, "?showcase=0 ", thumbnailDest, sep = ""), 
                   intern = TRUE, ignore.stderr = TRUE, ignore.stdout = TRUE) 
  if (!file.exists(thumbnailDest)) {
    stop(result)
  } 
  message("OK")
}

message("Checking for existing gallery entry... ", appendLF = FALSE)
# Check to see if the app key already exists
existingFiles <- list.files("../_posts")

# Create a list of keys from files (YYYY-MM-DD-key-name.md => key-name)
existingKeys <- substring(existingFiles, 12, 
                          unlist(lapply(existingFiles, nchar)) - 3)
message("OK")

if (appKey %in% existingKeys) {
  appFileName <- existingFiles[which(existingKeys == appKey, arr.ind = TRUE)]
  message("    Using existing post '", appFileName, "'")
} else {
  appFileName <- paste(format(Sys.time(), "%Y-%0m-%0d"), "-", appKey, ".md", 
                       sep = "")
  message("    Creating new post '", appFileName, "'")
}

# TODO: Validate tags

# Create an anonymous gist containing the source files using the ruby
# gist utility

# TODO: If using an existing post, update the existing gist

if (length(args) > 2) {
  sourceUrl <- args[3]
  # TODO: Validate that source URL is reachable
} else {
  message("Uploading code... ", appendLF = FALSE)
  sourceUrl <- system(paste('gist -d "', desc[1,"Title"], '" ', 
                          file.path(codePath, "*.R"), sep = ""),
                      intern = TRUE)
  message("OK\n",
          "    Created ", sourceUrl)
}

# Write the post .md file based on the contents of DESCRIPTION. Note that
# if this is an update of an existing application we should be sure to 
# overwrite that .md rather than create a new one.

conn <- file(file.path("..", "_posts", appFileName), open = "wt")
writeLines(c('---', 
             'layout: app', 
             paste('title: "', desc[1,"Title"], '"', sep = ""),
             paste('date: ', format(Sys.time(), "%Y-%0m-%0d %H:%M:%S"), sep = ""),
             paste('tags:', desc[1,"Tags"]),
             paste('app_url:', appUrl), 
             paste('source_url:', sourceUrl), 
             paste('thumbnail: ',appKey, '.png', sep = ""), 
             '---'), 
           con = conn)
close(conn)

message("Import successfully completed.")
