


#' DownloadL8S2
#'
#' @param Sites a dataframe with 3 columns : ID, x, y
#' @param StartDate
#' @param EndDate
#' @param Indices
#' @param Radius
#' @param Outname
#'
#' @return
#' @export
#'
#' @examples
DownloadL8S2 <- function(Sites,
                         StartDate,
                         EndDate,
                         Indices=c('NDVI'),
                         Radius=50,
                         Outname="Out.csv"
                         ) {

  #Read the template bash file
  tmp_bash_path <- system.file("templates", "geeDocker_R.sh", package = "L8S2")
  tmp_bash <- readLines(tmp_bash_path)

  #Save the sites in the tempdir
  tmp_dir <- tempdir(check = FALSE)
  write.csv(Sites, file.path(tmp_dir, "newloc.csv"), row.names = FALSE )

  all_bash_tags <- list()
  all_bash_tags$Hostdir <- tmp_dir
  all_bash_tags$SDate <-StartDate
  all_bash_tags$EDate <-EndDate
  all_bash_tags$Index <-paste(Indices, collapse = ",")
  all_bash_tags$rad <-Radius
  all_bash_tags$outfile <- Outname

  for (ntags in names(all_bash_tags)) {
    tmp_bash  <- gsub(pattern = paste0("@",ntags), replace =all_bash_tags[[ntags]], x = tmp_bash)
  }

  writeLines(tmp_bash, con=file.path(file.path(tmp_dir, "geeDocker_R.sh")))
}
