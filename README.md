
[![Build Status](https://travis-ci.org/ropensci/rdat.svg)](https://travis-ci.org/ropensci/rdat)

# rdat
![dat](http://i.imgur.com/1iD2dEx.png)

_Software is pre-alpha. Not yet ready for testing or use with real world data_

rDat provides a programmatic interface to the [Dat project](https://github.com/maxogden/) (v `5.0.5`). The package makes data syncable and allows for automatic sync and updates of data sets

## Installation instructions

If you have not already installed `dat`, follow instructions here:

```
git clone https://github.com/maxogden/dat
cd dat
npm install .
sudo npm link
```

[More detailed instructions](https://github.com/maxogden/dat#install)

Then install the R package:

```r
library(devtools)
install_github("ropensci/rdat")
```

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)


## API

This api is experimental and hasn't been finalized or implemented. Stay tuned for updates

#### init
```
repo <- dat("cars", path = getwd())
```
Inits a dat in the current working directory

#### insert
```
# insert some data
repo$insert(cars[1:20,])
v1 <- repo$status()$version
v1
```
Inserts data from a data frame and gets the dat at a particular hash.

```
# insert more data
repo$insert(cars[21:25,])
v2 <- repo$status()$version
v2

```
Inserts more data

#### get
```
data1 <- repo$get(v1)
data2 <- repo$get(v2)
```
Get particular versions of the dataset.

#### diff
```
diff <- repo$diff(v1, v2)
diff$key
```
list changes in between versions

#### branching
```
# create fork
repo$checkout(v1)
repo$insert(cars[40:42,])
repo$forks()
v3 <- repo$status()$version
```

Fork a dataset from a particular version into a new breanch.

#### checkout
```
# go back
repo$checkout(v2)
repo$get()
```
Checkout the data at a particular version.

#### files
```
# store binary attachements
repo$write(serialize(iris, NULL), "iris")
unserialize(repo$read("iris"))
```
Save binary data (files) as attachements to the dataset.
