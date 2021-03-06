% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DataBackendMatrix.R
\docType{data}
\name{DataBackendMatrix}
\alias{DataBackendMatrix}
\title{DataBackend for Matrix}
\format{\link[R6:R6Class]{R6::R6Class} object inheriting from \link{DataBackend}.}
\description{
\link{DataBackend} for \CRANpkg{Matrix}. Data is stored as (sparse) matrix.
}
\section{Construction}{
\preformatted{DataBackendMatrix$new(data, primary_key = NULL)
}
\itemize{
\item \code{data} :: \code{\link[Matrix:Matrix]{Matrix::Matrix()}}.
\item \code{primary_key} :: \code{character(1)}\cr
Not supported by this backend. Rows are addresses by their \code{\link[=rownames]{rownames()}}.
If the matrix does not have row names, integer row indices are used.
}

Alternatively, use \link{as_data_backend} on a \code{\link[Matrix:Matrix]{Matrix::Matrix()}}.
}

\section{Fields}{



\itemize{
\item \code{nrow} :: \code{integer(1)}\cr
Number of rows (observations).
\item \code{ncol} :: \code{integer(1)}\cr
Number of columns (variables), including the primary key column.
\item \code{colnames} :: \code{character()}\cr
Returns vector of all column names, including the primary key column.
\item \code{rownames} :: \code{integer()} | \code{character()}\cr
Returns vector of all distinct row identifiers, i.e. the primary key column.
\item \code{hash} :: \code{character(1)}\cr
Returns a unique hash for this backend. This hash is cached.
\item \code{data_formats} :: \code{character()}\cr
Vector of supported data formats.
A specific format of these supported formats can be picked in the \code{$data()} method.
}
}

\section{Methods}{



\itemize{
\item \code{data(rows = NULL, cols = NULL, format = "data.table")}\cr
(\code{integer()} | \code{character()}, \code{character()}) -> \code{any}\cr
Returns a slice of the data in a specific format.
Currently, the only supported format is "data.table".
The rows must be addressed as vector of primary key values, columns must be referred to via column names.
Non-existing rows and columns are silently ignored.
\item \code{distinct(rows, cols)}\cr
(\code{integer()} | \code{character()}, \code{character()}) -> named \code{list()}\cr
Returns a named list of vectors of distinct values for each column specified.
Non-existing columns are silently ignored.
If \code{rows} is \code{NULL}, all possible distinct values will be returned, even if they do not occur.
This affects factor-like variables with empty levels.
\item \code{head(n = 6)}\cr
\code{integer(1)} -> \code{\link[data.table:data.table]{data.table::data.table()}}\cr
Returns the first up-to \code{n} rows of the data as \code{\link[data.table:data.table]{data.table::data.table()}}.
\item \code{missings(rows, cols)}\cr
(\code{integer()} | \code{character()}, \code{character()}) -> named \code{integer()}\cr
Returns the number of missing values per column in the specified slice of data.
Non-existing rows and columns are silently ignored.
}
}

\examples{
requireNamespace("Matrix")
data = Matrix::Matrix(sample(0:1, 20, replace = TRUE), ncol = 2)
colnames(data) = c("x1", "x2")
rownames(data) = paste0("row_", 1:10)

b = as_data_backend(data)
b$head()
b$data(b$rownames[1:3], b$colnames, data_format = "Matrix")
}
\seealso{
Other DataBackend: \code{\link{DataBackendDataTable}},
  \code{\link{DataBackend}}, \code{\link{as_data_backend}}
}
\concept{DataBackend}
\keyword{datasets}
