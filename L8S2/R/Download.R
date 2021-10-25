


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
##' @examples
##' \dontrun{
##' mysites <- data.frame(x= c(-88.20,-88.20),
##'y= c(40.06,42.06),
##'ID= c('EnergyFarm',"RandomFarm")
##')
##'RS <- DownloadL8S2(mysites,
##'                   '2020-01-01',
##'                   '2021-01-01')
##'
##' }
DownloadL8S2 <- function(Sites,
                         StartDate,
                         EndDate,
                         Indices=c('NDVI','EVI'),
                         Radius=50,
                         Outname="Out.csv"
                         ) {
  rs.out <- NULL
  #Read the template bash file
  tmp_bash_path <- system.file("templates", "geeDocker_R.sh", package = "L8S2")
  tmp_bash <- readLines(tmp_bash_path)

  #Save the sites in the tempdir
  tmp_dir <- tempdir(check = FALSE)
  unlink(file.path(tmp_dir, "newloc.csv"))
  unlink(file.path(tmp_dir, "geeDocker_R.sh"))
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

  print(tmp_dir)
  writeLines(tmp_bash, con=file.path(file.path(tmp_dir, "geeDocker_R.sh")))

  # Try to read the RS data after running a docker container
  rs.out <- tryCatch({
    # Running the command
    suppressMessages({
      suppressWarnings({
        statusL8S2 <- system(paste0("bash ", file.path(tmp_dir, "geeDocker_R.sh")))
      })
    })
    #Read the output file in case it exsits
      if(file.exists(file.path(tmp_dir, Outname))) {
       return(readr::read_csv(file.path(tmp_dir, Outname)))
      }
    },
    error = function(e) {
      print(onditionMessage(e))
    }
  )

  return(rs.out)


}
