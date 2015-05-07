
[![Build Status](https://travis-ci.org/ropensci/rDat.svg)](https://travis-ci.org/ropensci/rDat)

# rDat
![dat](http://i.imgur.com/1iD2dEx.png)

_Software is pre-alpha. Not yet ready for testing or use with real world data_

rDat provides a programmatic interface to the [Dat project](https://github.com/maxogden/) (v `5.0.5`). The package makes data syncable and allows for automatic sync and updates of data sets

## Installation instructions

If you have not already installed `dat`, follow instructions here:

```
npm install dat -g
```

[More detailed instructions](https://github.com/maxogden/dat#install)

Then install the R package:

```r
library(devtools)
install_github("ropensci/rDat")
```

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)


## API
This api is experimental and hasn't been finalized or implemented. Stay tuned for updates

#### init
```
dat <- rDat.init()
```
Inits a dat in the current working directory

#### dat_clone
```
dat <- rDat.clone('ssh://path/to/dat')
```
Gets someone else's dat

#### dat_checkout
```
dat_checkout(dat, hash)
```
Gets the dat at a particular hash.

#### dat_push
```
dat_push(dat)
```
Pushes the data we've added to dat to peers

#### dat_pull
```
dat_pull(dat)
```
Syncs the changes of other peers to the local dat

#### dat_create_dataset
```
dataset <- create_dataset(dat, dataset_name)
```
Create an dat_dataset with the given name in the dat

#### dat_get_dataset
```
dataset <- get_dataset(dat, dataset_name)
```
Get an dat_dataset that already exists in the dat

## Dataset

#### dataset.get
```
dataframe <- dat_get(dataset)
```
Gets an entire table as a R.dataframe

#### dataset.add
```
dat_add(dataset, dataframe)
```
Add the dataframe to the dataset. This could create conflicts in the dat, but you don't have to worry about those yet.

#### dataset.get
```
row <- dat_get(dataset, key)
```
Gets a row from the dat with the particular key

#### dataset.add_file
```
dat_add_file(dataset, name, filepath)
```
Add a file to the dataset with a given name

#### dataset.get_file
```
dat_get_file(dataset, name, filepath)
```
Gets the file that's in the dataset with a given name to an output file (how is this defined?)

